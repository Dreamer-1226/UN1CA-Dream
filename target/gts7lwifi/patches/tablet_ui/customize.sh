# shellcheck disable=SC2034
SKIPUNZIP=1

LOG_STEP_IN "- Enabling One UI tablet UX"
# The first donor (Galaxy S22) reported characteristics=phone, and One UI then renders phone UX.
# Set tablet UX on BOTH system and product: some apps (Settings, Edge panel, Samsung
# Keyboard) read the product value, so system-only left them on the phone layout.
SET_PROP "system" "ro.build.characteristics" "tablet"
SET_PROP "product" "ro.build.characteristics" "tablet"
# Density: STOCK 340 on the 11", deliberately NOT the 12.4" trees' 320. 320 there is a MinsOS
# choice surviving from the S22-donor era; this is a new device with no such history, so it keeps
# what T870XXS8DXH1 ships (measured 2026-08-02: ro.sf.lcd_density=340). At 340 the 2560x1600
# panel is sw752dp - still far above sw720dp, so tablet resource buckets apply.
SET_PROP "vendor" "ro.sf.lcd_density" "340"
LOG_STEP_OUT

LOG_STEP_IN "- Fixing the oversized One UI Edge panel"
# The Edge panel is the ONE part of the UI that ignores the real Configuration: One UI Home
# (TouchWizHome_2017) rebuilds a synthetic one from a hardcoded codename -> reference-smallestWidth
# table in M9/j.smali <clinit>, keyed on ro.product.vendor.device. Our vendor partition is stock
# T870/T875, so that prop reads "gts7lwifi" or "gts7l", and the table only goes back to the Tab S8 era (gts8/gts9p/
# gts10p/... - 36 keys, no gts7*). Exact get() misses, the contains() fallback misses too, so the
# PHONE defaults stand: M9.j.b = 0x168 (360dp) and M9.j.c = 1.0f. M9/c.h() then does
# cfg.smallestScreenWidthDp = M9.j.b + createConfigurationContext(), which drops the edge panel
# alone into the sw360dp phone resource buckets, and scales every edge dimen by
# M9.j.c * (realSw / M9.j.b) * 1.064 = 1.0 * (876/360) * 1.064 = 2.589 instead of ~1.29.
# Confirmed against on-device uiautomator measurements (density 320, 1dp = 2px):
#   ripple_size 31dp * 2.589 = 80.3dp  vs measured 80.5x80dp
#   menu_button_height 51dp * 2.589 = 132dp vs measured 132dp
#   margin_top_show_label 23dp * 2.589 = 59.6dp vs measured 59.5dp
# Fix (gts7lwifi flavor): rename the (unused here) "gts9p" table key to "gts7l" so
# "gts7lwifi".contains("gts7l") hits it, giving M9.j.b = 0x338 (824) and M9.j.c = 1.1415f.
# 824 is also exactly the table's reference for the 11" Tab S8 ("gts8"), the same panel size as
# this device, so the reference class is right even though the c-multiplier is gts9p's -
# PROVISIONAL until measured on a T870 (the 12.4" fix was verified on-device; this one is the
# same mechanism at 11" numbers). "gts9p" occurs exactly once in the whole APK.
# NOTE: SMALI_PATCH's const-string branch adds the quotes itself (smali_utils.sh:
# sub("\"" STR "\"", ...)), so VALUE is the bare string content - passing a whole
# `const-string vN, "..."` line would silently no-op.
SMALI_PATCH "system" "system/priv-app/TouchWizHome_2017/TouchWizHome_2017.apk" \
    "smali_classes4/M9/j.smali" "replace" \
    '<clinit>()V' \
    'gts9p' \
    'gts7l'
_EP="$(RESOLVE_SMALI "system" "priv-app/TouchWizHome_2017/TouchWizHome_2017.apk" "smali_classes4/M9/j.smali")"
# The launcher keys the edge-panel scale off a table of device codenames, and this patch swaps the
# donor's entry for ours. A newer donor may not carry that table at all: measured on one, the APK
# holds no gts* codename string anywhere, while the donor this ROM ships from has nine. That is a
# different situation from "the patch silently failed on the donor we build against", which is what
# this abort exists to catch, so keep aborting for our donor and downgrade to a loud warning
# elsewhere. The One UI 8.5 launcher this ROM ships is that case: none of its dex holds a gts*
# string, and on a T970 running v1.2.0 the edge panel is not oversized (2026-10-06), so the bug
# this step fixed was the older launcher's and there is nothing left to patch.
if ! grep -q '"gts7l"' "$_EP"; then
    _OU="$(GET_PROP "system" "ro.build.version.oneui" 2>/dev/null || echo 0)"
    if [ "${_OU:-0}" -gt 80000 ]; then
        LOG "- Edge panel scale fix not needed: this One UI $_OU launcher has no codename table (the oversized panel was an older launcher's bug)"
    else
        ABORT "[$TARGET_CODENAME] Edge panel scale fix did NOT apply - M9/j.smali codename table changed"
    fi
    unset _OU
fi
unset _EP
LOG_STEP_OUT

LOG_STEP_IN "- Samsung Camera"
# The donor's own camera app, unless MINSOS_JEYS_CAMERA=1.
#
# This used to copy the camera APK out of the Jeys One UI 8 port unconditionally, because the
# S22 donor's camera crashed on this device's front sensor crop (2608x1956). That donor is gone:
# the system now comes from the X810, a tablet, which ships its own camera build - and the actual
# root cause was fixed since, in patches/camera, by giving the ROM the T970's own 8 MP front
# resolutions instead of the donor's 12 MP ones. So the swap is very likely redundant, and it is
# 66 MB of a third party's file redistributed inside every zip.
#
# Kept behind a flag rather than deleted until the donor's own app is confirmed on hardware:
# camera regressions are not visible in a build log.
if [ "${MINSOS_JEYS_CAMERA:-0}" = "1" ]; then
    CAM_DIR="$WORK_DIR/system/system/priv-app/SamsungCamera"
    if [ -f "$CAM_DIR/SamsungCamera.apk" ] && [ -f "$MODPATH/SamsungCamera.apk" ]; then
        cp "$MODPATH/SamsungCamera.apk" "$CAM_DIR/SamsungCamera.apk"
        rm -rf "$CAM_DIR/oat"
        LOG "- Samsung Camera replaced with the Jeys port's build"
    else
        LOG "! Samsung Camera missing, skipping swap"
    fi
else
    _CAM="$WORK_DIR/system/system/priv-app/SamsungCamera/SamsungCamera.apk"
    [ -f "$_CAM" ] || ABORT "! no SamsungCamera.apk in the work dir - the donor stopped shipping one"
    LOG "- keeping the donor's own build ($(stat -c%s "$_CAM") bytes)"
    unset _CAM
fi
# NOTE: wallpaper-res is NOT swapped here - it is re-added from the pa2qxxx prebuilt and
# recompiled after patches, so a copy here is overwritten. The wallpaper picker crash is
# a separate InfinityWallpaper (live) engine issue to diagnose from device logcat.
LOG_STEP_OUT

# NOTE: Air Command needs nothing from us any more. It used to be swapped by overwriting the b0q
# (S22 Ultra) prebuilt at prebuilts/samsung/b0qxxx/system/priv-app/AirCommand/AirCommand.apk with
# the gts7xlwifi build, because unica/patches/spen installs the b0q S-Pen suite when the DONOR has
# no S-Pen. The X810 donor is a tablet that ships its own, so that whole branch is skipped now -
# the build log shows "S Pen blobs" with nothing under it - and the ROM carries the donor's own
# AirCommand. The overwritten prebuilt is dead weight in the build tree, not something we ship.
