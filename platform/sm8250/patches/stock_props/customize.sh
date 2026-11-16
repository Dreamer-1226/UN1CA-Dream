EVAL "uniq \"$WORK_DIR/system/system/build.prop\" \"$WORK_DIR/system/system/tmp\" && mv -f \"$WORK_DIR/system/system/tmp\" \"$WORK_DIR/system/system/build.prop\""
LOG "- Adding \"debug.codec2.stop_hal_before_surface\" prop with \"1\" in /system/system/build.prop"
EVAL "sed -i \"/spatializer_enabled=true/a debug.codec2.stop_hal_before_surface=1\" \"$WORK_DIR/system/system/build.prop\""
EVAL "sed -i \"/stop_hal_before_surface/i ro.audio.spatializer_enabled=true\" \"$WORK_DIR/system/system/build.prop\""
EVAL "sed -i \"/PRODUCT_SYSTEM_DEFAULT_PROPERTIES/a ####################################\" \"$WORK_DIR/system/system/build.prop\""



# product/etc/build.prop above is a whole file taken from an S22 Ultra (b0qxxx,

# SM-S908E, y2qksx, Android 16). Keep its feature props, but make the

# partition identity match this device and this ROM's system build.

LOG "- Matching /product identity props to the target device and source build"

SET_PROP "product" "ro.product.product.model" "$(GET_PROP "vendor" "ro.product.vendor.model")"

SET_PROP "product" "ro.product.product.name" "$(GET_PROP "vendor" "ro.product.vendor.name")"

for p in fingerprint id version.incremental version.release version.release_or_codename version.sdk version.sdk_full; do

    v="$(GET_PROP "system" "ro.system.build.$p")"

    if [ "$v" ]; then

        SET_PROP "product" "ro.product.build.$p" "$v"

    else

        SET_PROP "product" "ro.product.build.$p" --delete

    fi

done

unset p v

