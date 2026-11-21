# shellcheck disable=SC2034
SKIPUNZIP=1

# An app built against an older IProcessObserver (Shizuku's server) has no 5-arg
# onProcessStarted, so the binder dispatch throws AbstractMethodError and the app
# dies at start. Catch it around the call. The dispatch registers differ between
# donors (S23, the tablet's X810), so wrap whatever call is there instead of
# applying a fixed-line patch.
DECODE_APK "system" "system/framework/framework.jar"
_IPO="$(RESOLVE_SMALI "system" "system/framework/framework.jar" 'smali/android/app/IProcessObserver$Stub.smali')"
[ -f "$_IPO" ] || ABORT "IProcessObserver\$Stub.smali not found in framework.jar"
LOG "- Catching AbstractMethodError around IProcessObserver.onProcessStarted"
python3 "$MODPATH/wrap_ipo.py" "$_IPO" || ABORT "Failed to patch IProcessObserver\$Stub"
unset _IPO
