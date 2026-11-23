# shellcheck disable=SC2034
SKIPUNZIP=1

case "$TARGET_CODENAME" in
    x1q|y2q|z3q) ;;
    *) return 0 ;;
esac

_RC="$WORK_DIR/vendor/etc/init/init.vendor.rilcommon.rc"
if [ ! -f "$_RC" ]; then
    LOGW "init.vendor.rilcommon.rc not found, skipping the overseas dual-SIM setup"
    unset _RC
    return 0
fi
if [ "$(grep -c '^    exec_start sim_config$' "$_RC")" != 1 ] \
        || ! grep -q '^service sim_config /vendor/bin/secril_config_svc' "$_RC"; then
    LOGW "init.vendor.rilcommon.rc does not start sim_config exactly once, skipping the overseas dual-SIM setup"
    unset _RC
    return 0
fi

LOG "- Selecting single or dual SIM by model (SM-G9810/G9860/G9880: dual)"
# Drop rilcommon's "exec_start sim_config"; our rc runs it for the single-SIM
# models only.
EVAL "sed -i '/^    exec_start sim_config\$/d' \"$_RC\""
grep -q '^service sim_config ' "$_RC" || ABORT "init.vendor.rilcommon.rc lost the sim_config service"

ADD_TO_WORK_DIR "$MODPATH/files" "vendor" "etc/init/unica_overseas_dualsim.rc" 0 0 644 "u:object_r:vendor_configs_file:s0"

for _S in "@1.5::IRadio/slot2" "@2.2::ISehRadio/slot2"; do
    grep -q "<fqname>$_S</fqname>" "$WORK_DIR/vendor/etc/vintf/manifest.xml" \
        || LOGW "vendor manifest does not declare $_S; the second SIM will not come up"
done

unset _RC _S
