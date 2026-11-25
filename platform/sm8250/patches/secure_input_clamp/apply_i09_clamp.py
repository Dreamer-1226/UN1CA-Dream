#!/usr/bin/env python3
# Protected playback secure-input clamp (MinsOS I-09) for system/lib64/libstagefright.so,
# re-derived for the S911N (One UI 9) donor. Original analysis, cave code and the X810 profiles:
# MinsOS by kmu1757 (https://xdaforums.com/m/kmu1757.13119493/, https://gitlab.com/minsos1/MinsOS).
#
# The secure OMX decoder receives the full secure ION allocation as nFilledLen, parses the stale
# tail and corrupts the picture (Netflix shows L1, then the frame breaks up). The real access-unit
# size is the subsample sum, known in ACodecBufferChannel::queueSecureInputBuffer, while the value
# the vendor decoder parses is omxBuffer.mRangeLength, set in ACodec::BaseState::onInputBufferFilled.
#
# Cave 1 (hooked at a `mov x8,#-1` in queueSecureInputBuffer): if the input is secure (w23 bit 0),
#   sums the SubSample array (x24, count x22) and stores it in the SecureBuffer's unused mPointer
#   slot (+0x28) of the BufferInfo at x20; then replays the displaced insn and returns.
# Cave 2 (hooked at `ldr x8,[x24,#160]` right before IOMXNode::emptyBuffer): if the buffer carries a
#   non-zero sum, writes it to mRangeLength ([sp,#0x20], OMXBuffer at sp+0x18) and clears the slot.
# Both caves sit in the zero padding before __cfi_check. The S911N code matches X810 FZK2 shifted
# by 0x18 in both functions; the cave gap and field offsets are the same.
#
# Gated on file size and byte anchors around both hooks and the cave gap; anything else is
# refused (exit 1) and left untouched.
import struct, sys


def b(src, dst):
    d = dst - src
    assert d % 4 == 0 and -(1 << 27) <= d < (1 << 27)
    return struct.pack("<I", 0x14000000 | ((d >> 2) & 0x3FFFFFF)).hex()


# Cave bodies without their final branch back (identical to MinsOS FZK2).
CAVE1 = ("d7010036e9031faa0a0080d2160100b40b0f0a8b6c3540298c010d0b29010c8b4a050091"
         "5f0116eb41ffff548a0640f94a0000b4491500f908008092")
CAVE2 = "8a0240f9ca0000b4491540f9890000b4e92300b95f1500f91f2003d5085340f9"

PROFILES = [
    {
        "name": "SM-S911N (One UI 9)",
        "size": 2681240,
        "hook1": 0xfbed4,  # mov x8,#-1 in queueSecureInputBuffer
        "hook2": 0xcb710,  # ldr x8,[x24,#160] in BaseState::onInputBufferFilled
        "cave1": 0xb9ee0,
        "cave2": 0xb9f30,
        "anchors": [
            (0xfbec4, "e00308aa"),                                  # mov x0,x8
            (0xfbecc, "fc1300f9b63340f9"),                          # str x28,[sp,#32]; ldr x22,[x29,#96]
            (0xfbed8, "a8031df8df0600f1a1000054080340b968000035080740b9"),
            (0xcb6e8, "80698ad2d80240f9a8835cf8202dbbf2971e40b900c5d6f2e10318aae80300f92048fbf2"),
            (0xcb714, "e10b40b9e2630091e31340b9e40340f9e00316aae503172a00013fd6"),
            (0xb9ebc, "00f59ed2809ba5f2e035caf2a0e5f7f2"),
            (0xba000, "5f2403d5"),
        ],
    },
]


def regions(p):
    c1 = CAVE1 + b(p["cave1"] + len(CAVE1) // 2, p["hook1"] + 4)
    c2 = CAVE2 + b(p["cave2"] + len(CAVE2) // 2, p["hook2"] + 4)
    return [
        (p["hook1"], b(p["hook1"], p["cave1"]), "08008092"),
        (p["hook2"], b(p["hook2"], p["cave2"]), "085340f9"),
        (p["cave1"], c1, "00" * (len(c1) // 2)),
        (p["cave2"], c2, "00" * (len(c2) // 2)),
    ]


def main():
    path = sys.argv[1]
    data = bytearray(open(path, "rb").read())
    hx = lambda o, n: bytes(data[o:o + n]).hex()
    for p in PROFILES:
        if len(data) == p["size"] and all(hx(o, len(h) // 2) == h for o, h in p["anchors"]):
            break
    else:
        sys.stderr.write("! libstagefright.so (size %d) is not a known donor build - refusing\n" % len(data))
        return 1
    regs = regions(p)
    cur = [hx(o, len(new) // 2) for o, new, _ in regs]
    if cur == [new for _, new, _ in regs]:
        print("- libstagefright.so already carries the secure-input clamp (%s)" % p["name"])
        return 0
    for (o, _, want), got in zip(regs, cur):
        if got != want:
            sys.stderr.write("! region 0x%x is %s, expected %s - refusing\n" % (o, got, want))
            return 1
    for o, new, _ in regs:
        nb = bytes.fromhex(new)
        data[o:o + len(nb)] = nb
    open(path, "wb").write(data)
    back = open(path, "rb").read()
    if any(back[o:o + len(new) // 2].hex() != new for o, new, _ in regs):
        sys.stderr.write("! libstagefright.so did not read back with the clamp written\n")
        return 1
    print("- libstagefright.so patched (secure-input clamp, %s)" % p["name"])
    return 0


if __name__ == "__main__":
    sys.exit(main())
