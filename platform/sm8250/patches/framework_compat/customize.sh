# The SystemUI patches below edit classes of the S23 (qssi) SystemUI. Other
# sources (the Tab S9+ on tab-qssi) lay them out differently, so only apply
# them on the qssi source.
if [[ "$TARGET_OS_SINGLE_SYSTEM_IMAGE" == "qssi" ]]; then
    for p in "$MODPATH"/qssi-patches/SystemUI/*.patch; do
        APPLY_PATCH "system_ext" "priv-app/SystemUI/SystemUI.apk" "$p" || return 1
    done
    unset p
fi
