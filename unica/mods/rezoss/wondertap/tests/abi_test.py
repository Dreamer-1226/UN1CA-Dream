#!/usr/bin/env python3
# Copyright (c) 2026 Rezoss
# SPDX-License-Identifier: GPL-3.0-or-later
"""Host-only ABI and isolated packaging regressions; no device access."""
import contextlib
import gzip
import io
import os
from pathlib import Path
import shutil
import struct
import sys
import tempfile
import unittest
from unittest.mock import patch

BASE = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BASE))
import abi
import prepare


def module(imports=None, exports=None):
    imports = imports if imports is not None else {"module_layout": 1}
    exports = exports or {}
    shnames = b"\0.shstrtab\0.strtab\0.symtab\0__versions\0"
    strings = b"\0" + b"".join(("__crc_" + n).encode() + b"\0" for n in exports)
    symbols = bytes(24)
    for name, crc in exports.items():
        symbols += struct.pack("<IBBHQQ", strings.index(("__crc_" + name).encode()),
                               0x10, 0, 0xfff1, crc, 0)
    versions = b"".join(struct.pack("<Q", crc) + n.encode().ljust(56, b"\0")
                        for n, crc in imports.items())
    data = bytearray(64)
    rows = [bytes(64)]
    for name, payload, kind, link, size in [
            (".shstrtab", shnames, 3, 0, 0), (".strtab", strings, 3, 0, 0),
            (".symtab", symbols, 2, 2, 24), ("__versions", versions, 1, 0, 0)]:
        rows.append(struct.pack("<IIQQQQIIQQ", shnames.index(name.encode()), kind,
                                0, 0, len(data), len(payload), link, 0, 1, size))
        data += payload
    offset = len(data)
    data += b"".join(rows)
    data[:6] = b"\x7fELF\x02\x01"
    struct.pack_into("<HH", data, 16, 1, 183)
    struct.pack_into("<Q", data, 40, offset)
    struct.pack_into("<HHH", data, 58, 64, len(rows), 1)
    return bytes(data)


def image(release="5.15.999-custom", config="CONFIG_MODVERSIONS=y\n"):
    data = bytearray(64)
    data[56:60] = b"ARM\x64"
    return bytes(data) + b"Linux version " + release.encode() + b" test\0IKCFG_ST" + gzip.compress(config.encode())


class AbiTests(unittest.TestCase):
    def test_module_imports_and_exports(self):
        self.assertEqual(abi.module_abi(module(exports={"provider": 23})),
                         ({"module_layout": 1}, {"provider": 23}))

    def test_missing_version_metadata_refused(self):
        with self.assertRaisesRegex(ValueError, "__versions"):
            abi.module_abi(module(imports={}))

    def test_wrong_architecture_and_truncation(self):
        data = bytearray(module())
        struct.pack_into("<H", data, 18, 62)
        with self.assertRaisesRegex(ValueError, "ARM64"):
            abi.module_abi(data)
        with self.assertRaisesRegex(ValueError, "section table"):
            abi.module_abi(module()[:65])

    def test_crc_mismatch_is_specific(self):
        with self.assertRaisesRegex(ValueError, "wonder.ko: ABI CRC mismatch for function"):
            abi.check_imports("wonder.ko", {"function": 1}, {"function": 2})

    def test_missing_symbol_is_specific(self):
        with self.assertRaisesRegex(ValueError, "wonder.ko: missing ABI symbol function"):
            abi.check_imports("wonder.ko", {"function": 1}, {})

    def test_patch_release_and_custom_suffix_allowed(self):
        policy = {"release_family": "5.15", "required_config": {"CONFIG_MODVERSIONS": "y"}}
        for release in ("5.15.220-original", "5.15.223-g4e2f2450", "5.15.999-custom"):
            self.assertEqual(abi.kernel_profile(image(release), policy), release)

    def test_wrong_family_and_config_refused(self):
        policy = {"release_family": "5.15", "required_config": {"CONFIG_MODVERSIONS": "y"}}
        with self.assertRaisesRegex(ValueError, "family"):
            abi.kernel_profile(image("6.1.99-custom"), policy)
        with self.assertRaisesRegex(ValueError, "CONFIG_MODVERSIONS=n"):
            abi.kernel_profile(image(config=""), policy)
        with self.assertRaisesRegex(ValueError, "embedded configuration"):
            abi.kernel_profile(image().split(b"IKCFG_ST")[0], policy)

    def test_unknown_export_layout_refused(self):
        with self.assertRaisesRegex(ValueError, "export table"):
            abi.kernel_exports(image())

    def test_recursive_preloaded_provider(self):
        policy = {"release_family": "5.15", "required_config": {"CONFIG_MODVERSIONS": "y"}}
        first = module({"module_layout": 1, "first": 2})
        providers = {"first.ko": module({"module_layout": 1, "second": 3}, {"first": 2}),
                     "second.ko": module(exports={"second": 3})}
        with patch.object(abi, "kernel_exports", return_value={"module_layout": 1}):
            with contextlib.redirect_stdout(io.StringIO()):
                abi.validate(image(), policy, {"wonder.ko": first}, providers)
            with self.assertRaisesRegex(ValueError, "missing ABI symbol second"):
                abi.validate(image(), policy, {"wonder.ko": first}, {"first.ko": providers["first.ko"]})
            with self.assertRaisesRegex(ValueError, "ABI CRC mismatch for first"):
                abi.validate(image(), policy, {"wonder.ko": first},
                             {"first.ko": module(exports={"first": 99})})

    def test_invalid_cpio_refused(self):
        with self.assertRaisesRegex(ValueError, "CPIO"):
            abi.cpio_entries(b"not an archive" * 20)

    def test_duplicate_providers_refused(self):
        policy = {"release_family": "5.15", "required_config": {"CONFIG_MODVERSIONS": "y"}}
        with patch.object(abi, "kernel_exports", return_value={"module_layout": 1}):
            with self.assertRaisesRegex(ValueError, "duplicate ABI symbol provider"):
                abi.validate(image(), policy, {"one.ko": module(exports={"same": 2}),
                                               "two.ko": module(exports={"same": 2})})


@unittest.skipUnless(os.environ.get("WONDERTAP_TEST_WORK"), "Set WONDERTAP_TEST_WORK for firmware integration")
class IntegrationTests(unittest.TestCase):
    def test_export_parser_matches_reference_build(self):
        reference = os.environ.get("WONDERTAP_REFERENCE_BUILD")
        if not reference:
            self.skipTest("Set WONDERTAP_REFERENCE_BUILD for export-parser calibration")
        reference = Path(reference)
        expected = {row.split()[1]: int(row.split()[0], 16)
                    for row in (reference / "Module.symvers").read_text().splitlines()
                    if row.split()[2] == "vmlinux"}
        self.assertEqual(abi.kernel_exports((reference / "arch/arm64/boot/Image").read_bytes()), expected)

    def fixture(self, temp):
        source = Path(os.environ["WONDERTAP_TEST_WORK"]).resolve()
        work = Path(temp) / "work"
        (work / "kernel").mkdir(parents=True)
        (work / "kernel/vendor_boot.img").symlink_to(source / "kernel/vendor_boot.img")
        modules = work / "vendor_dlkm/lib/modules"
        modules.mkdir(parents=True)
        for path in (source / "vendor_dlkm/lib/modules").iterdir():
            if path.is_file():
                (modules / path.name).symlink_to(path)
        return source, work

    def test_actual_kernel_and_loader_graph(self):
        with tempfile.TemporaryDirectory(prefix="wondertap-policy-test-") as temp:
            source, work = self.fixture(temp)
            (work / "kernel/boot.img").symlink_to(source / "kernel/boot.img")
            stage, backup = Path(temp) / "stage", Path(temp) / "backup"
            prepare.prepare(BASE, work, stage, backup)
            destination = stage / "vendor_dlkm/lib/modules"
            self.assertTrue((destination / "wonder.ko").is_file())
            load = (destination / "modules.load").read_text().splitlines()
            self.assertLess(load.index("s23u_wonder_provider.ko"), load.index("qca_cld3_kiwi_v2.ko"))
            self.assertLess(load.index("qca_cld3_kiwi_v2.ko"), load.index("wonder.ko"))
            self.assertTrue(list(backup.glob("stock-*/manifest.json")))

    def test_abi_failure_before_any_staging_or_backup(self):
        with tempfile.TemporaryDirectory(prefix="wondertap-policy-test-") as temp:
            source, work = self.fixture(temp)
            (work / "kernel/boot.img").symlink_to(source / "kernel/boot.img")
            stage, backup = Path(temp) / "stage", Path(temp) / "backup"
            with patch.object(abi, "kernel_exports", return_value={}):
                with self.assertRaisesRegex(ValueError, "missing ABI symbol"):
                    prepare.prepare(BASE, work, stage, backup)
            self.assertFalse(stage.exists())
            self.assertFalse(backup.exists())

    def test_corrupt_stock_dependency_still_refused(self):
        with tempfile.TemporaryDirectory(prefix="wondertap-policy-test-") as temp:
            source, work = self.fixture(temp)
            (work / "kernel/boot.img").symlink_to(source / "kernel/boot.img")
            dependency = work / "vendor_dlkm/lib/modules/cfg80211.ko"
            dependency.unlink()  # Remove only this temporary symlink.
            dependency.write_bytes(b"corrupt test dependency")
            with self.assertRaisesRegex(ValueError, "Unvalidated vendor dependency: cfg80211.ko"):
                prepare.prepare(BASE, work, Path(temp) / "stage", Path(temp) / "backup")
            self.assertFalse((Path(temp) / "stage").exists())
            self.assertFalse((Path(temp) / "backup").exists())

    def test_corrupt_candidate_still_refused(self):
        with tempfile.TemporaryDirectory(prefix="wondertap-policy-test-") as temp:
            source, work = self.fixture(temp)
            (work / "kernel/boot.img").symlink_to(source / "kernel/boot.img")
            fake = Path(temp) / "base"
            payload = fake / "vendor_dlkm/lib/modules"
            payload.mkdir(parents=True)
            shutil.copy2(BASE / "manifest.json", fake / "manifest.json")
            (payload / "wonder.ko").write_bytes(b"corrupt test candidate")
            with self.assertRaisesRegex(ValueError, "Candidate module checksum mismatch: wonder.ko"):
                prepare.prepare(fake, work, Path(temp) / "stage", Path(temp) / "backup")
            self.assertFalse((Path(temp) / "stage").exists())
            self.assertFalse((Path(temp) / "backup").exists())


if __name__ == "__main__":
    unittest.main()
