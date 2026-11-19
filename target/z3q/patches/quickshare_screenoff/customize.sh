# Screen-off Quick Share discovery runs a custom 55/3120 BLE scan (~1.8% duty). On b5q a GMS
# screen-off scan lifts the controller to 160/3120, but z3q's QCA controller gets no GMS
# screen-off scan, so the 55 window is all there is and no REQUEST_0x01 from a searching phone
# is ever received. Raise the window to 160.
_APK="system/app/MdxKitService/MdxKitService.apk"
[ -f "$WORK_DIR/system/$_APK" ] || ABORT "! /system/$_APK not found"
DECODE_APK "system" "$_APK"

_DIR="$APKTOOL_DIR/system/${_APK//system\//}"
LOG "- Raising the screen-off scan window in /system/$_APK"
python3 - "$_DIR" <<'PY' || ABORT "! screen-off scan window not found (MdxKitService changed?)"
import os, re, sys
rx = re.compile(r'(const/16 v5, 0xc30\n(?:[ \t]*\n|[ \t]*\.line \d+\n)*[ \t]*const/16 p0, )0x37\n')
hits = []
for root, _, files in os.walk(sys.argv[1]):
    for f in files:
        if f.endswith(".smali"):
            p = os.path.join(root, f)
            s = open(p, encoding="utf-8").read()
            n = len(rx.findall(s))
            if n:
                hits.append((p, s, n))
if len(hits) != 1 or hits[0][2] != 1:
    sys.exit("%d matches" % sum(h[2] for h in hits))
p, s, _ = hits[0]
open(p, "w", encoding="utf-8").write(rx.sub(r"\g<1>0xa0\n", s))
print(os.path.relpath(p, sys.argv[1]))
PY

unset _APK _DIR
