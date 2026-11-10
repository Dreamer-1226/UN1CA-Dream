# shellcheck disable=SC2034
SKIPUNZIP=1

# Developer options re-runs itself forever once opened.
#
# WHAT IT LOOKS LIKE. Open Settings > Developer options and scrolling stutters badly. Leave the
# screen and it does not stop: every other Settings screen is now slow too, and the Settings
# process keeps burning CPU until something kills it. Measured on v0.2.1, idle, no finger on the
# glass:
#
#                                 never opened dev options      after opening it
#   getActiveDevices(A2DP)                   0 / 10 s              657 / 10 s
#   SystemPropPoker                          0 / 10 s            1,034 / 10 s
#   total logcat lines                     869 / 10 s           76,073 / 10 s
#   janky frames while scrolling              7.8 %              42 - 49 %
#
# WHY. It is a feedback loop, and both halves are in the app:
#
#   DevelopmentSettingsDashboardFragment.onCreateView
#       SystemProperties.addChangeCallback(mSystemPropertiesChanged)     <- $4
#   $4.run()
#       runOnUiThread(DashboardFragment::updatePreferenceStates)
#   updatePreferenceStates()
#       BluetoothStackLogPreferenceController.updateState(pref)
#           setBluetoothLogLevelIndex(getBluetoothLogLevelIndex())
#               setBluetoothLogTag(value)
#                   SystemProperties.set("persist.log.tag.bluetooth", value)   <- writes on READ
#   ...which is a property change, which fires $4 again.
#
# BluetoothMaxConnectedAudioDevicesPreferenceController.updateState does the same thing more
# directly: it reads its property and writes the identical value straight back. Both keys are on
# the screen (development_settings.xml lines 15 and 106), so both feed the loop.
#
# Each turn of the loop is expensive out of all proportion. updatePreferenceStates walks every
# controller on a ~200-entry screen; six Bluetooth codec controllers each make a synchronous
# BluetoothAdapter.getActiveDevices() binder round trip ON THE UI THREAD, and setBluetoothLogTag
# calls SystemPropPoker, which pokes every registered binder service - one of which, Knox's
# mdm.remotedesktop, throws SecurityException, while others answer UNKNOWN_TRANSACTION. That is
# where the FAILED BINDER TRANSACTION spam and "ActivityThread: Too many transaction errors" come
# from; they are downstream noise, not the cause.
#
# WHAT THIS CHANGES. One instruction. addChangeCallback becomes removeChangeCallback, so the
# fragment never subscribes; removing a callback that was never added is a list remove that finds
# nothing. Identical signature (Ljava/lang/Runnable;)V, same register, so nothing shifts.
#
# Why here and not on the preferences. Deleting the two offending entries from
# res/xml/development_settings.xml also works, and was the first plan - but it costs the user two
# real developer options, and it only holds until some other controller writes a property while
# refreshing. Cutting the subscription ends the loop whoever writes, and every one of the ~200
# preferences keeps working.
#
# What is actually lost: while you SIT ON the screen, a preference no longer live-updates when an
# unrelated system property changes underneath it. Its own summary still updates when you change
# it, and everything refreshes on re-entry. That is the whole cost.
#
# Do not "improve" this by nulling onCreateView or stripping the callback class - onCreateView
# builds the view and registers three other receivers the screen needs.

LOG_STEP_IN "- Developer options refresh loop"

_APK="system/priv-app/SecSettings/SecSettings.apk"
_SMALI="smali_classes2/com/android/settings/development/DevelopmentSettingsDashboardFragment.smali"
_ADD="invoke-static {v0}, Landroid/os/SystemProperties;->addChangeCallback(Ljava/lang/Runnable;)V"
_DEL="invoke-static {v0}, Landroid/os/SystemProperties;->removeChangeCallback(Ljava/lang/Runnable;)V"

SMALI_PATCH "system" "$_APK" "$_SMALI" "replace" \
    'onCreateView(Landroid/view/LayoutInflater;Landroid/view/ViewGroup;Landroid/os/Bundle;)Landroid/view/View;' \
    "$_ADD" \
    "$_DEL"

# SMALI_PATCH logs a warning and RETURNS 0 when the method or the line is not found - it is built
# to tolerate the X810 8.5 dex splits moving things around. That is the wrong behaviour for this
# patch: a silent skip ships a ROM whose developer options still spin, and nothing in the build
# output says so. Assert on the file.
_EP="$(RESOLVE_SMALI "system" "priv-app/SecSettings/SecSettings.apk" "$_SMALI")"
[ -f "$_EP" ] || ABORT "! $_SMALI not found - SecSettings dex layout changed, re-check which
      classesN.dex defines DevelopmentSettingsDashboardFragment"
if grep -qF "$_ADD" "$_EP"; then
    ABORT "! addChangeCallback is still there - the refresh loop would ship unfixed"
fi
grep -qF "$_DEL" "$_EP" \
    || ABORT "! neither add nor removeChangeCallback is in the class - the patch hit the wrong file"
# Two calls now: ours in onCreateView and the original in onDestroyView. Count them WITHOUT the
# register, because the two do not share one: onCreateView had the callback in v0, onDestroyView
# holds it in p0. Matching the full "invoke-static {v0}, ..." line found one and aborted a build
# over a patch that had in fact applied correctly.
_N="$(grep -c 'Landroid/os/SystemProperties;->removeChangeCallback' "$_EP")"
[ "$_N" = "2" ] || ABORT "! expected 2 removeChangeCallback calls, found $_N"

LOG "- SystemProperties change callback no longer subscribed; the screen refreshes on entry only"
unset _APK _SMALI _ADD _DEL _EP _N
LOG_STEP_OUT
