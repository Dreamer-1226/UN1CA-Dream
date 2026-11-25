SKIPUNZIP=1

LOG_STEP_IN "- dex2oat: background work on little cores (0,1,2,3), SystemUI compiled with speed at boot"
SET_PROP "system" "dalvik.vm.background-dex2oat-cpu-set" "0,1,2,3"
grep -qxF "dalvik.vm.background-dex2oat-cpu-set=0,1,2,3" "$WORK_DIR/system/system/build.prop" \
    || ABORT "[$TARGET_CODENAME] dalvik.vm.background-dex2oat-cpu-set did not land in system build.prop"
# See module.prop. Costs one SystemUI compile (about 135 MB of odex in /data/dalvik-cache) on the first boot
# after a flash or an update; every later boot finds it up to date.
SET_PROP "system" "dalvik.vm.systemuicompilerfilter" "speed"
grep -qxF "dalvik.vm.systemuicompilerfilter=speed" "$WORK_DIR/system/system/build.prop" \
    || ABORT "[$TARGET_CODENAME] dalvik.vm.systemuicompilerfilter did not land in system build.prop"
LOG_STEP_OUT
