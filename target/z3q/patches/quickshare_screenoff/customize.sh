# mdx.kit's location differs between donors, so look it up instead of hardcoding it.
_MDX="$(grep -rl --include=AndroidManifest.xml 'package="com.samsung.android.mdx.kit"' "$APKTOOL_DIR" 2>/dev/null | head -n 1)"
_APK="$(cd "$WORK_DIR/system" && find system/app system/priv-app -name '*.apk' -exec sh -c \
    'unzip -p "$1" AndroidManifest.xml 2>/dev/null | grep -aq "c.o.m...s.a.m.s.u.n.g...a.n.d.r.o.i.d...m.d.x...k.i.t" && echo "$1"' _ {} \; | head -n 1)"
[ -n "$_APK" ] || ABORT "! com.samsung.android.mdx.kit not found in /system"
APPLY_PATCH "system" "$_APK" "$MODPATH/0001-Raise-screen-off-scan-window.patch"
unset _MDX _APK
