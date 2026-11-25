#!/usr/bin/env python3
"""I-172: HIDL <=1.3 requiresSecureDecoder fallback for system/lib64/libmediadrm.so.

From MinsOS by kmu1757 (https://xdaforums.com/m/kmu1757.13119493/,
https://gitlab.com/minsos1/MinsOS); the SM-S911N profile was added for UN1CA.

All SM8250 targets (Tab S7 family + S20 family) ship vendor Widevine on
android.hardware.drm@1.3::IDrmFactory (Widevine CDM 16.0.0), so
DrmHalHidl::mPluginV1_4 ([this, #152]) is always NULL. Stock AOSP
DrmHalHidl::requiresSecureDecoder() returns DrmStatus(OK) without touching
*required when mPluginV1_4 == NULL; libmedia_jni initializes required=false, so
MediaDrm.requiresSecureDecoder("video/...") silently returns false.

Apps that rely on MediaDrm.requiresSecureDecoder() (e.g. YouTube) then pick
non-secure OMX.qcom.video.decoder.vp9 instead of .vp9.secure; 480p SD keys
allow clear output, while 1080p HD keys are rejected by Widevine TA
validate_key_control_for_decrypt (TA Result 20, OEMCryptoResult 13, WVCdm 178,
ERROR_DRM_CANNOT_HANDLE), forcing L3 / 480p fallback.

This patch extends the PT_LOAD (R E) segment into its trailing same-page zero
padding right after .plt and hooks both DrmHalHidl::requiresSecureDecoder
overloads at `ldr x21, [x21, #152]`. When mPluginV1_4 != NULL, execution
resumes immediately on the original v1.4 path. When mPluginV1_4 == NULL, a
fallback helper mirrors donor AIDL Widevine (libwvaidl.so
WVDrmPlugin::requiresSecureDecoder): for video/* MIME types (case-insensitive)
at kSecurityLevelMax(1), kSecurityLevelHwSecureDecode(5), or
kSecurityLevelHwSecureAll(6), it calls this->getPropertyStringInternal(
String8("securityLevel"), value) (gLock is already held by the caller) and sets
*required = true iff status == OK and value == "L1".

Usage:
  apply_drm_secure_decoder.py <path/to/libmediadrm.so>
  apply_drm_secure_decoder.py --verify <path/to/libmediadrm.so>
"""

import struct
import sys

# ELF64 constants
ELF_MAGIC = b"\x7fELF\x02\x01\x01"  # ELF64 little-endian v1
EM_AARCH64 = 183
PT_LOAD = 1
PF_X = 1
PF_W = 2
PF_R = 4

# Original hook instruction: `ldr x21, [x21, #152]`
ORIG_HOOK_INSN = bytes.fromhex("b54e40f9")

# Verified donor profiles. Every anchor and PT_LOAD layout is re-checked before
# patching or verifying; unrecognized donor builds are refused rather than
# patched blind.
PROFILES = [
    {
        "name": "SM-X810_KOO_FZK2 (One UI 9 tablet)",
        "size": 605152,
        "rx_off": 0x37000,
        "rx_vaddr": 0x37000,
        "rx_filesz": 0x541A0,
        "next_load": 0x8C000,
        "hook2": 0x4407C,
        "ok2": 0x4412C,
        "hook3": 0x44290,
        "ok3": 0x44354,
        "get_prop_internal": 0x3C7D8,
        "plt_delete_sz": 0x88398,      # operator delete(void*, size_t) (_ZdlPvm)
        "plt_s8_def": 0x88A10,         # android::String8::String8()
        "plt_s8_cstr": 0x88A40,        # android::String8::String8(const char*)
        "plt_s8_dtor": 0x88A58,        # android::String8::~String8()
        "anchors": [
            (0x44074, "f30308aa1c110194"),                 # mov x19,x8; bl lock
            (0x44080, "750500b400e4006f"),                 # cbz x21,ok2; movi v0
            (0x4412C, "7f7e00a97f0a00f9"),                 # stp xzr,xzr,[x19]; str xzr,[x19,#16]
            (0x44288, "f30308aa97100194"),                 # mov x19,x8; bl lock
            (0x44294, "150600b400e4006fe80a0051"),         # cbz x21,ok3; movi v0; sub w8,w23,#2
            (0x44354, "7f7e00a97f0a00f9"),                 # stp xzr,xzr,[x19]; str xzr,[x19,#16]
            (0x3C7D8, "3f2303d5ff0303d1fd7b09a9"),         # getPropertyStringInternal prologue
            (0x88398, "300000f0110645f9"),                 # _ZdlPvm@plt
            (0x88A10, "300000f0111a46f9"),                 # String8()@plt
            (0x88A40, "300000f0112246f9"),                 # String8(const char*)@plt
            (0x88A58, "300000f0112646f9"),                 # ~String8()@plt
        ],
    },
    {
        "name": "SM-S948N_KOO_BZK1 (One UI 9 phone)",
        "size": 633824,
        "rx_off": 0x38000,
        "rx_vaddr": 0x38000,
        "rx_filesz": 0x541A0,
        "next_load": 0x90000,
        "hook2": 0x4507C,
        "ok2": 0x4512C,
        "hook3": 0x45290,
        "ok3": 0x45354,
        "get_prop_internal": 0x3D7D8,
        "plt_delete_sz": 0x89398,
        "plt_s8_def": 0x89A10,
        "plt_s8_cstr": 0x89A40,
        "plt_s8_dtor": 0x89A58,
        "anchors": [
            (0x45074, "f30308aa1c110194"),
            (0x45080, "750500b400e4006f"),
            (0x4512C, "7f7e00a97f0a00f9"),
            (0x45288, "f30308aa97100194"),
            (0x45294, "150600b400e4006fe80a0051"),
            (0x45354, "7f7e00a97f0a00f9"),
            (0x3D7D8, "3f2303d5ff0303d1fd7b09a9"),
            (0x89398, "500000d0110645f9"),
            (0x89A10, "500000d0111a46f9"),
            (0x89A40, "500000d0112246f9"),
            (0x89A58, "500000d0112646f9"),
        ],
    },
    {
        # UN1CA S20/Note20 (ssch71): same code as X810 FZK2, different .plt and segment sizes.
        "name": "SM-S911N (One UI 9 phone, UN1CA sm8250 donor)",
        "size": 601064,
        "rx_off": 0x37000,
        "rx_vaddr": 0x37000,
        "rx_filesz": 0x53F50,
        "next_load": 0x8B000,
        # .plt ends 0xb0 bytes before the RW segment, too little for the cave. Put it in the
        # first (R) segment's zero tail instead (0x3663c..0x37000) and mark that segment R E,
        # the classic layout where headers and text share one executable segment.
        "cave_seg_off": 0x0,
        "cave_seg_filesz": 0x3663C,
        "cave_limit": 0x37000,
        "hook2": 0x4407C,
        "ok2": 0x4412C,
        "hook3": 0x44290,
        "ok3": 0x44354,
        "get_prop_internal": 0x3C7D8,
        "plt_delete_sz": 0x88148,
        "plt_s8_def": 0x887C0,
        "plt_s8_cstr": 0x887F0,
        "plt_s8_dtor": 0x88808,
        "anchors": [
            (0x44074, "f30308aa88100194"),
            (0x44080, "750500b400e4006f"),
            (0x4412C, "7f7e00a97f0a00f9"),
            (0x44288, "f30308aa03100194"),
            (0x44294, "150600b400e4006fe80a0051"),
            (0x44354, "7f7e00a97f0a00f9"),
            (0x3C7D8, "3f2303d5ff0303d1fd7b09a9"),
            (0x88148, "300000d0110645f9"),
            (0x887C0, "300000d0111a46f9"),
            (0x887F0, "300000d0112246f9"),
            (0x88808, "300000d0112646f9"),
        ],
    },
    {
        "name": "SM-X810_KOO_EZI2 (One UI 8.5 tablet)",
        "size": 597112,
        "rx_off": 0x37000,
        "rx_vaddr": 0x37000,
        "rx_filesz": 0x52A38,
        "next_load": 0x8A000,
        "hook2": 0x4409C,
        "ok2": 0x4414C,
        "hook3": 0x442B0,
        "ok3": 0x44374,
        "get_prop_internal": 0x3C7A0,
        "plt_delete_sz": 0x86C48,
        "plt_s8_def": 0x872C0,
        "plt_s8_cstr": 0x872F0,
        "plt_s8_dtor": 0x87308,
        "anchors": [
            (0x44094, "f30308aa400b0194"),
            (0x440A0, "750500b400e4006f"),
            (0x4414C, "7f7e00a97f0a00f9"),
            (0x442A8, "f30308aabb0a0194"),
            (0x442B4, "150600b400e4006fe80a0051"),
            (0x44374, "7f7e00a97f0a00f9"),
            (0x3C7A0, "3f2303d5ff0303d1fd7b09a9"),
            (0x86C48, "300000f011ea44f9"),
            (0x872C0, "300000d011fe45f9"),
            (0x872F0, "300000d0110646f9"),
            (0x87308, "300000d0110a46f9"),
        ],
    },
]


# ---------------------------------------------------------------------------
# Minimal AArch64 assembler (fixed-width 32-bit instructions + label fixups)
# ---------------------------------------------------------------------------
class Arm64Asm:
    def __init__(self, base_addr):
        self.base = base_addr
        self.words = []      # list of int or (kind, target_label_or_addr, aux)
        self.labels = {}
        self.tail = bytearray()

    @property
    def pc(self):
        return self.base + 4 * len(self.words)

    def label(self, name):
        assert name not in self.labels
        self.labels[name] = self.pc

    def emit(self, word):
        self.words.append(word & 0xFFFFFFFF)

    def emit_fixup(self, kind, target, aux=0):
        self.words.append((kind, target, aux))

    def paciasp(self):
        self.emit(0xD503233F)

    def autiasp(self):
        self.emit(0xD50323BF)

    def ret(self):
        self.emit(0xD65F03C0)

    def b(self, target):
        self.emit_fixup("b", target)

    def bl(self, target):
        self.emit_fixup("bl", target)

    def cbz_x(self, rt, target):
        self.emit_fixup("cbz_x", target, rt)

    def cbnz_w(self, rt, target):
        self.emit_fixup("cbnz_w", target, rt)

    def tbz_w(self, rt, bit, target):
        self.emit_fixup("tbz_w", target, (rt, bit))

    def b_cond(self, cond, target):
        # cond: eq=0, ne=1, hi=8
        self.emit_fixup("b_cond", target, cond)

    def adr(self, rd, target):
        self.emit_fixup("adr", target, rd)

    def mov_x(self, rd, rm):
        self.emit(0xAA0003E0 | (rm << 16) | rd)

    def mov_w(self, rd, rm):
        self.emit(0x2A0003E0 | (rm << 16) | rd)

    def mov_x_sp(self, rd):
        self.emit(0x910003E0 | rd)

    def movz_w(self, rd, imm16):
        assert 0 <= imm16 <= 0xFFFF
        self.emit(0x52800000 | (imm16 << 5) | rd)

    def add_x_imm(self, rd, rn, imm12):
        assert 0 <= imm12 <= 0xFFF
        self.emit(0x91000000 | (imm12 << 10) | (rn << 5) | rd)

    def sub_x_imm(self, rd, rn, imm12):
        assert 0 <= imm12 <= 0xFFF
        self.emit(0xD1000000 | (imm12 << 10) | (rn << 5) | rd)

    def sub_w_imm(self, rd, rn, imm12):
        assert 0 <= imm12 <= 0xFFF
        self.emit(0x51000000 | (imm12 << 10) | (rn << 5) | rd)

    def cmp_w_imm(self, rn, imm12):
        assert 0 <= imm12 <= 0xFFF
        self.emit(0x7100001F | (imm12 << 10) | (rn << 5))

    def orr_w_0x20(self, rd, rn):
        # 32-bit bitmask imm 0x20: N=0, immr=27 (0x1b), imms=0
        self.emit(0x321B0000 | (rn << 5) | rd)

    def and_x_not1(self, rd, rn):
        # 64-bit bitmask imm ~1 (0xfffffffffffffffe): N=1, immr=63, imms=62
        self.emit(0x927FF800 | (rn << 5) | rd)

    def ldr_x(self, rt, rn, off):
        assert off % 8 == 0 and 0 <= off // 8 <= 0xFFF
        self.emit(0xF9400000 | ((off // 8) << 10) | (rn << 5) | rt)

    def ldr_w(self, rt, rn, off):
        assert off % 4 == 0 and 0 <= off // 4 <= 0xFFF
        self.emit(0xB9400000 | ((off // 4) << 10) | (rn << 5) | rt)

    def ldrb(self, rt, rn, off):
        assert 0 <= off <= 0xFFF
        self.emit(0x39400000 | (off << 10) | (rn << 5) | rt)

    def str_x(self, rt, rn, off):
        assert off % 8 == 0 and 0 <= off // 8 <= 0xFFF
        self.emit(0xF9000000 | ((off // 8) << 10) | (rn << 5) | rt)

    def strb(self, rt, rn, off):
        assert 0 <= off <= 0xFFF
        self.emit(0x39000000 | (off << 10) | (rn << 5) | rt)

    def stp_x(self, rt1, rt2, rn, off):
        assert off % 8 == 0 and -512 <= off <= 504
        imm7 = (off // 8) & 0x7F
        self.emit(0xA9000000 | (imm7 << 15) | (rt2 << 10) | (rn << 5) | rt1)

    def ldp_x(self, rt1, rt2, rn, off):
        assert off % 8 == 0 and -512 <= off <= 504
        imm7 = (off // 8) & 0x7F
        self.emit(0xA9400000 | (imm7 << 15) | (rt2 << 10) | (rn << 5) | rt1)

    def add_rodata(self, name, raw_bytes):
        # Emit after all instructions; align label to 4 bytes
        assert len(self.tail) % 4 == 0
        self.labels[name] = ("tail", len(self.tail))
        self.tail.extend(raw_bytes)
        while len(self.tail) % 4 != 0:
            self.tail.append(0)

    def _resolve(self, target):
        if isinstance(target, int):
            return target
        val = self.labels[target]
        if isinstance(val, tuple) and val[0] == "tail":
            return self.base + 4 * len(self.words) + val[1]
        return val

    def build(self):
        out = bytearray()
        for idx, item in enumerate(self.words):
            pc = self.base + 4 * idx
            if isinstance(item, int):
                w = item
            else:
                kind, target, aux = item
                tgt = self._resolve(target)
                delta = tgt - pc
                if kind in ("b", "bl"):
                    assert delta % 4 == 0 and -(1 << 27) <= delta < (1 << 27)
                    op = 0x14000000 if kind == "b" else 0x94000000
                    w = op | ((delta >> 2) & 0x03FFFFFF)
                elif kind == "cbz_x":
                    assert delta % 4 == 0 and -(1 << 20) <= delta < (1 << 20)
                    w = 0xB4000000 | (((delta >> 2) & 0x7FFFF) << 5) | aux
                elif kind == "cbnz_w":
                    assert delta % 4 == 0 and -(1 << 20) <= delta < (1 << 20)
                    w = 0x35000000 | (((delta >> 2) & 0x7FFFF) << 5) | aux
                elif kind == "tbz_w":
                    rt, bit = aux
                    assert delta % 4 == 0 and -(1 << 15) <= delta < (1 << 15)
                    w = 0x36000000 | ((bit & 0x1F) << 19) | (((delta >> 2) & 0x3FFF) << 5) | rt
                elif kind == "b_cond":
                    assert delta % 4 == 0 and -(1 << 20) <= delta < (1 << 20)
                    w = 0x54000000 | (((delta >> 2) & 0x7FFFF) << 5) | aux
                elif kind == "adr":
                    assert -(1 << 20) <= delta < (1 << 20)
                    immlo = delta & 0x3
                    immhi = (delta >> 2) & 0x7FFFF
                    w = 0x10000000 | (immlo << 29) | (immhi << 5) | aux
                else:
                    raise ValueError(f"unknown fixup {kind}")
            out.extend(struct.pack("<I", w))
        out.extend(self.tail)
        # Pad total cave size to 16-byte multiple
        while len(out) % 16 != 0:
            out.append(0)
        return bytes(out)


def encode_b(src, dst):
    delta = dst - src
    assert delta % 4 == 0 and -(1 << 27) <= delta < (1 << 27)
    return struct.pack("<I", 0x14000000 | ((delta >> 2) & 0x03FFFFFF))


def build_patch_payload(prof):
    """Assemble the code cave and both hook branch words for a profile."""
    seg_off = prof.get("cave_seg_off", prof["rx_off"])
    limit = prof.get("cave_limit", prof["next_load"])
    old_end = seg_off + prof.get("cave_seg_filesz", prof["rx_filesz"])
    cave_base = (old_end + 15) & ~15
    a = Arm64Asm(cave_base)
    SP = 31
    XZR = 31
    WZR = 31
    EQ, NE, HI = 0, 1, 8

    # Entry 1: 2-arg DrmHalHidl::requiresSecureDecoder(const char*, bool*)
    #   x21=this, x22=mime, x20=required, x19=DrmStatus* (gLock already held)
    a.label("cave_2arg")
    a.ldr_x(8, 21, 152)                 # x8 = this->mPluginV1_4
    a.cbz_x(8, "fb_2arg")
    a.mov_x(21, 8)                      # restore x21 = mPluginV1_4
    a.b(prof["hook2"] + 8)              # resume original @1.4 path
    a.label("fb_2arg")
    a.mov_x(0, 21)                      # this
    a.mov_x(1, 22)                      # mime
    a.movz_w(2, 1)                      # kSecurityLevelMax (1)
    a.mov_x(3, 20)                      # required
    a.bl("fallback_helper")
    a.b(prof["ok2"])                    # DrmStatus(OK), unlock gLock, ret

    # Entry 2: 3-arg DrmHalHidl::requiresSecureDecoder(const char*, SecurityLevel, bool*)
    #   x21=this, x22=mime, w23=level, x20=required, x19=DrmStatus* (gLock held)
    a.label("cave_3arg")
    a.ldr_x(8, 21, 152)                 # x8 = this->mPluginV1_4
    a.cbz_x(8, "fb_3arg")
    a.mov_x(21, 8)                      # restore x21 = mPluginV1_4
    a.b(prof["hook3"] + 8)              # resume original @1.4 path
    a.label("fb_3arg")
    a.mov_x(0, 21)                      # this
    a.mov_x(1, 22)                      # mime
    a.mov_w(2, 23)                      # level
    a.mov_x(3, 20)                      # required
    a.bl("fallback_helper")
    a.b(prof["ok3"])                    # DrmStatus(OK), unlock gLock, ret

    # Helper: void fallback_helper(const DrmHalHidl* this, const char* mime,
    #                              uint32_t level, bool* required)
    # Stack frame (0x60 bytes):
    #   [sp+0x00] String8 name (8B)
    #   [sp+0x08] String8 value (8B)
    #   [sp+0x10..0x37] DrmStatus st (40B: int32 mStatus @+0, std::string @+16)
    #   [sp+0x40..0x4f] saved x29, x30
    #   [sp+0x50..0x5f] saved x19, x20
    a.label("fallback_helper")
    a.paciasp()
    a.sub_x_imm(SP, SP, 0x60)
    a.stp_x(29, 30, SP, 0x40)
    a.stp_x(19, 20, SP, 0x50)
    a.add_x_imm(29, SP, 0x40)

    a.cbz_x(3, "done")                  # if (required == nullptr) return
    a.strb(WZR, 3, 0)                   # *required = false
    a.cbz_x(1, "done")                  # if (mime == nullptr) return

    # Case-insensitive "video/" prefix check (NUL-safe byte by byte)
    for idx, ch in enumerate(b"video"):
        a.ldrb(8, 1, idx)
        a.orr_w_0x20(8, 8)
        a.cmp_w_imm(8, ch)
        a.b_cond(NE, "done")
    a.ldrb(8, 1, 5)
    a.cmp_w_imm(8, ord("/"))
    a.b_cond(NE, "done")

    # Require secure decoder only for kSecurityLevelMax(1),
    # kSecurityLevelHwSecureDecode(5), or kSecurityLevelHwSecureAll(6).
    a.cmp_w_imm(2, 1)
    a.b_cond(EQ, "query_prop")
    a.sub_w_imm(8, 2, 5)
    a.cmp_w_imm(8, 1)
    a.b_cond(HI, "done")

    a.label("query_prop")
    a.mov_x(19, 0)                      # x19 = this
    a.mov_x(20, 3)                      # x20 = required

    # String8 name("securityLevel") at [sp+0x00]
    a.mov_x_sp(0)
    a.adr(1, "str_securityLevel")
    a.bl(prof["plt_s8_cstr"])

    # String8 value() at [sp+0x08]
    a.add_x_imm(0, SP, 0x08)
    a.bl(prof["plt_s8_def"])

    # Defensive zero-init of DrmStatus st at [sp+0x10..0x37]
    a.stp_x(XZR, XZR, SP, 0x10)
    a.stp_x(XZR, XZR, SP, 0x20)
    a.str_x(XZR, SP, 0x30)

    # st = this->getPropertyStringInternal(name, value)
    a.mov_x(0, 19)
    a.mov_x_sp(1)
    a.add_x_imm(2, SP, 0x08)
    a.add_x_imm(8, SP, 0x10)            # AAPCS64 indirect result pointer
    a.bl(prof["get_prop_internal"])

    # Require st.mStatus == 0 (OK) and value.string() == "L1\0"
    a.ldr_w(8, SP, 0x10)
    a.cbnz_w(8, "cleanup_st")
    a.ldr_x(9, SP, 0x08)                # String8::mString (const char* at +0)
    a.cbz_x(9, "cleanup_st")
    a.ldrb(10, 9, 0)
    a.cmp_w_imm(10, ord("L"))
    a.b_cond(NE, "cleanup_st")
    a.ldrb(10, 9, 1)
    a.cmp_w_imm(10, ord("1"))
    a.b_cond(NE, "cleanup_st")
    a.ldrb(10, 9, 2)
    a.cbnz_w(10, "cleanup_st")
    a.movz_w(10, 1)
    a.strb(10, 20, 0)                   # *required = true

    # Destroy DrmStatus::mErrMsg (libc++ std::string at st+16 == [sp+0x20])
    a.label("cleanup_st")
    a.ldrb(8, SP, 0x20)
    a.tbz_w(8, 0, "cleanup_s8")         # bit 0 == 0 -> SSO (no heap alloc)
    a.ldr_x(8, SP, 0x20)                # long cap | 1
    a.ldr_x(0, SP, 0x30)                # heap pointer (st+32)
    a.and_x_not1(1, 8)                  # size_t cap = x8 & ~1
    a.bl(prof["plt_delete_sz"])         # operator delete(ptr, cap)

    # Destroy String8 value, then String8 name
    a.label("cleanup_s8")
    a.add_x_imm(0, SP, 0x08)
    a.bl(prof["plt_s8_dtor"])
    a.mov_x_sp(0)
    a.bl(prof["plt_s8_dtor"])

    a.label("done")
    a.ldp_x(19, 20, SP, 0x50)
    a.ldp_x(29, 30, SP, 0x40)
    a.add_x_imm(SP, SP, 0x60)
    a.autiasp()
    a.ret()

    a.add_rodata("str_securityLevel", b"securityLevel\x00")
    cave_bytes = a.build()
    new_end = cave_base + len(cave_bytes)
    assert new_end <= limit, (
        f"cave overflow: {hex(new_end)} > {hex(limit)}"
    )

    cave_2arg = a.labels["cave_2arg"]
    cave_3arg = a.labels["cave_3arg"]
    hook2_insn = encode_b(prof["hook2"], cave_2arg)
    hook3_insn = encode_b(prof["hook3"], cave_3arg)
    new_filesz = new_end - seg_off

    return {
        "old_end": old_end,
        "cave_base": cave_base,
        "new_end": new_end,
        "new_filesz": new_filesz,
        "cave_bytes": cave_bytes,
        "hook2_insn": hook2_insn,
        "hook3_insn": hook3_insn,
        "cave_2arg": cave_2arg,
        "cave_3arg": cave_3arg,
        "fallback_helper": a.labels["fallback_helper"],
    }


def find_rx_phdr(data, want_off=None):
    """Validate ELF64 AArch64 header and locate the executable PT_LOAD PHDR
    (or, with want_off, the PT_LOAD at that file offset)."""
    if len(data) < 64 or data[:7] != ELF_MAGIC:
        return None, "not an ELF64 little-endian binary"
    e_machine = struct.unpack_from("<H", data, 18)[0]
    if e_machine != EM_AARCH64:
        return None, f"not AArch64 (e_machine={e_machine})"
    e_phoff = struct.unpack_from("<Q", data, 32)[0]
    e_phentsize, e_phnum = struct.unpack_from("<HH", data, 54)
    if e_phentsize != 56 or e_phoff + e_phentsize * e_phnum > len(data):
        return None, "invalid ELF program header table"

    rx_phdr = None
    load_vaddrs = []
    for i in range(e_phnum):
        off = e_phoff + i * e_phentsize
        p_type, p_flags, p_offset, p_vaddr, p_paddr, p_filesz, p_memsz, p_align = (
            struct.unpack_from("<IIQQQQQQ", data, off)
        )
        if p_type == PT_LOAD:
            load_vaddrs.append((p_offset, p_vaddr, p_filesz, p_memsz, p_flags, off))
            if want_off is not None:
                if p_offset == want_off:
                    rx_phdr = (off, p_offset, p_vaddr, p_filesz, p_memsz, p_align, p_flags)
            elif (p_flags & (PF_R | PF_W | PF_X)) == (PF_R | PF_X):
                if rx_phdr is not None:
                    return None, "multiple R E PT_LOAD segments"
                rx_phdr = (off, p_offset, p_vaddr, p_filesz, p_memsz, p_align, p_flags)
    if rx_phdr is None:
        return None, "no R E PT_LOAD segment found"
    return (rx_phdr, load_vaddrs), None


def match_profile(data):
    for prof in PROFILES:
        if len(data) != prof["size"]:
            continue
        if all(
            bytes(data[o : o + len(h) // 2]).hex() == h for o, h in prof["anchors"]
        ):
            return prof
    return None


def inspect_state(data):
    """Return (state, prof, payload, rx_phdr_off, detail)."""
    prof = match_profile(data)
    if prof is None:
        return "unknown", None, None, None, f"unrecognized libmediadrm.so (size={len(data)})"

    res, err = find_rx_phdr(data, prof["rx_off"])
    if err:
        return "invalid", None, None, None, err
    rx_phdr, load_vaddrs = res
    ph_off, p_offset, p_vaddr, p_filesz, p_memsz, _p_align, _p_flags = rx_phdr
    if (_p_flags & (PF_R | PF_W | PF_X)) != (PF_R | PF_X):
        return "invalid", prof, None, ph_off, "text PT_LOAD is not R E"
    if p_filesz != prof["rx_filesz"]:
        if "cave_seg_off" in prof:
            return "invalid", prof, None, ph_off, f"text PT_LOAD filesz {hex(p_filesz)} changed"

    # Segment that hosts the cave (the text segment itself unless the profile says otherwise)
    seg_off = prof.get("cave_seg_off", prof["rx_off"])
    if seg_off != prof["rx_off"]:
        res2, err = find_rx_phdr(data, seg_off)
        if err:
            return "invalid", prof, None, None, err
        ph_off, c_offset, c_vaddr, c_filesz, c_memsz, _a, c_flags = res2[0]
        if c_offset != c_vaddr or c_filesz != c_memsz or (c_flags & PF_W):
            return "invalid", prof, None, ph_off, "unexpected cave PT_LOAD"
        seg_x = bool(c_flags & PF_X)
        orig_ok = c_filesz == prof["cave_seg_filesz"] and not seg_x
        cave_filesz, want_x = c_filesz, seg_x
    else:
        orig_ok = p_filesz == prof["rx_filesz"]
        cave_filesz, want_x = p_filesz, True

    if p_offset != prof["rx_off"] or p_vaddr != prof["rx_vaddr"] or p_filesz != p_memsz:
        return (
            "invalid",
            prof,
            None,
            ph_off,
            f"unexpected R E PT_LOAD (off={hex(p_offset)} vaddr={hex(p_vaddr)} "
            f"filesz={hex(p_filesz)} memsz={hex(p_memsz)})",
        )

    # Confirm no subsequent PT_LOAD starts before prof["next_load"]
    for lo, lv, _fs, _ms, _fl, _o in load_vaddrs:
        if lo > p_offset and (lo < prof["next_load"] or lv < prof["next_load"]):
            return "invalid", prof, None, ph_off, "overlapping next PT_LOAD segment"

    pay = build_patch_payload(prof)
    cur_h2 = bytes(data[prof["hook2"] : prof["hook2"] + 4])
    cur_h3 = bytes(data[prof["hook3"] : prof["hook3"] + 4])
    cur_pad = bytes(data[pay["old_end"] : pay["cave_base"]])
    cur_cave = bytes(data[pay["cave_base"] : pay["new_end"]])

    if (
        cave_filesz == pay["new_filesz"]
        and want_x
        and cur_h2 == pay["hook2_insn"]
        and cur_h3 == pay["hook3_insn"]
        and all(b == 0 for b in cur_pad)
        and cur_cave == pay["cave_bytes"]
    ):
        return "patched", prof, pay, ph_off, "ok"

    if (
        orig_ok
        and cur_h2 == ORIG_HOOK_INSN
        and cur_h3 == ORIG_HOOK_INSN
        and all(b == 0 for b in cur_pad)
        and all(b == 0 for b in cur_cave)
    ):
        return "stock", prof, pay, ph_off, "ok"

    return (
        "corrupt",
        prof,
        pay,
        ph_off,
        f"unexpected state (filesz={hex(p_filesz)}, h2={cur_h2.hex()}, h3={cur_h3.hex()})",
    )


def main():
    args = sys.argv[1:]
    verify_only = False
    if args and args[0] == "--verify":
        verify_only = True
        args = args[1:]
    if len(args) != 1:
        sys.stderr.write("usage: apply_drm_secure_decoder.py [--verify] <libmediadrm.so>\n")
        return 2

    path = args[0]
    with open(path, "rb") as f:
        data = bytearray(f.read())

    state, prof, pay, ph_off, detail = inspect_state(data)

    if verify_only:
        if state == "patched":
            print(
                f"OK: {prof['name']} carries I-172 requiresSecureDecoder fallback "
                f"(cave {hex(pay['cave_base'])}..{hex(pay['new_end'])}, "
                f"{len(pay['cave_bytes'])}B)"
            )
            return 0
        sys.stderr.write(
            f"FAIL: {path} is NOT patched for I-172 (state={state}: {detail})\n"
        )
        return 1

    if state == "patched":
        print(
            f"- libmediadrm.so already carries I-172 requiresSecureDecoder fallback "
            f"({prof['name']})"
        )
        return 0

    if state != "stock":
        sys.stderr.write(
            f"! libmediadrm.so refused (state={state}: {detail})\n"
        )
        return 1

    # Extend PT_LOAD (R E) p_filesz and p_memsz into trailing same-page zeros
    struct.pack_into("<QQ", data, ph_off + 32, pay["new_filesz"], pay["new_filesz"])
    p_flags = struct.unpack_from("<I", data, ph_off + 4)[0]
    struct.pack_into("<I", data, ph_off + 4, p_flags | PF_X)
    # Write cave + both hook branches
    data[pay["cave_base"] : pay["new_end"]] = pay["cave_bytes"]
    data[prof["hook2"] : prof["hook2"] + 4] = pay["hook2_insn"]
    data[prof["hook3"] : prof["hook3"] + 4] = pay["hook3_insn"]

    with open(path, "wb") as f:
        f.write(data)

    # Mandatory readback verification from disk
    with open(path, "rb") as f:
        back = f.read()
    r_state, r_prof, r_pay, _r_ph, r_detail = inspect_state(back)
    if r_state != "patched":
        sys.stderr.write(
            f"! libmediadrm.so readback failed after write (state={r_state}: {r_detail})\n"
        )
        return 1

    print(
        f"- libmediadrm.so patched (I-172 HIDL 1.3 requiresSecureDecoder fallback, "
        f"{r_prof['name']}, cave {hex(r_pay['cave_base'])}..{hex(r_pay['new_end'])})"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
