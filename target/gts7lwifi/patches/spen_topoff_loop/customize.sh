# shellcheck disable=SC2034
SKIPUNZIP=1

# S Pen attached at 100 percent, tablet on battery: AirCommand re-arms "additional charge" about once
# a minute, forever.
#
# WHAT IT COSTS. Measured on 1.1.4 (ops/proposals/spen_charging_wakelock_20260930.md, 57 minutes on
# battery, screen off, pen attached and full): "Starting additional charge for 100% battery level"
# 100 times an hour, wakelock AirCmd:SpenCharging 292 s an hour (the top app wakelock), AirCommand
# CPU 62 s an hour, and every pen report fans out as a broadcast that wakes Settings Intelligence in
# two users and redraws the battery widget. The Wacom charging the pen for the minute itself is on
# top of that and is not in batterystats.
#
# WHY. When the pen's 1-minute START charge ends it reports DISCHARGING and Battery:100 over BLE.
# The BLE driver calls every listener with (new level, old level) without comparing them, and the
# charge controller (BleSpenGenericChargeController, obfuscated K2/i.a) re-arms on every report:
# a 60 s wakelock, then one second later, at 100 percent with no charger, STOP(5) + START(3) - the
# pen charges for another minute, reports 100 again, and round it goes. 97.6 percent of the reports
# in the capture were 100 -> 100.
#
# Stock T970 (AirCommand 7.2.30.2) has the same class, branch and command values, so this is an
# improvement on stock, not a port fix. No floating feature changes it: the donor knows only the
# "sticky" and "builtin" pen types, anything else drops to NONBLE and loses every BLE pen feature.
#
# WHAT THIS CHANGES. Three instructions at the top of the listener: an unchanged report of 100
# returns. A level that moves (100 -> 90, 90 -> 100), attaching the pen, a BLE reconnect, plugging
# or unplugging the charger, the temperature cut-off lifting, and DISCHARGING below 100 still re-arm
# exactly as before - those come through other paths or with a changed level.
#
# The anchor is the listener's own log string, not .locals or a label: apktool decodes the method
# with .locals 2 (baksmali says .registers 6), and its labels are renumbered on every decode.

LOG_STEP_IN "- S Pen 100% top-off loop"

_APK="system/priv-app/AirCommand/AirCommand.apk"
_SMALI="smali/K2/i.smali"
_ANCHOR='const-string v0, "onBatteryLevelChanged : "'

SMALI_PATCH "system" "$_APK" "$_SMALI" "replace" \
    'a(LY2/g;II)V' \
    "$_ANCHOR" \
    "    if-ne p2, p3, :minsos_level_changed\n\n    const/16 v0, 0x64\n\n    if-ne p2, v0, :minsos_level_changed\n\n    return-void\n\n    :minsos_level_changed\n    $_ANCHOR"

# SMALI_PATCH returns 0 on a missing class, method or line. The obfuscated names move with every
# AirCommand update, so assert on the file instead of trusting the call.
_EP="$(RESOLVE_SMALI "system" "priv-app/AirCommand/AirCommand.apk" "$_SMALI")"
[ -f "$_EP" ] || ABORT "! $_SMALI not found - re-derive with ops/spen_topoff/derive.sh (the class holding
      \"onBatteryLevelChanged : \" and \"BleSpenGenericChargeController\")"
grep -qF '"BleSpenGenericChargeController"' "$_EP" \
    || ABORT "! $_SMALI is no longer the S Pen charge-controller listener"
[ "$(grep -c ':minsos_level_changed' "$_EP")" = "3" ] \
    || ABORT "! 100 -> 100 guard not applied - the S Pen top-off loop would ship"

LOG "- S Pen charge controller no longer re-arms on an unchanged 100% report"
unset _APK _SMALI _ANCHOR _EP
LOG_STEP_OUT
