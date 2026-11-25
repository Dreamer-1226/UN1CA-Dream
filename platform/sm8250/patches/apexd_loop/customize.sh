# I-170: Google Play system updates fail on 2.0.x ("apexd verification failed : Couldn't create
# dm-device for name=com.android.<module>_0.apex").
#
# Measured on a T970 (2.0.0-beta1, 11-23): apexd verifies a staged APEX by mapping the file's
# extents with a dm-linear target straight on /dev/block/by-name/userdata ("table=linear 0 7576
# /dev/block/by-name/userdata 330051584"). The 4.19 kernel refuses that while /data (sda36) is
# mounted from the same partition: "device-mapper: table: 253:4: linear: Device lookup failed",
# "DM_TABLE_LOAD failed ... Device or resource busy". Every module of every train failed that way.
#
# apexd only does this when apexd.config.use_fiemap is true (its default; no build.prop sets it).
# With it false apexd uses loop devices, as it already does for every APEX at boot. On the T970,
# resetprop apexd.config.use_fiemap false made the same 14 MB update stage ("Session staged" x4,
# 0 dm failures). A KernelSU system.prop came too late for the next boot's activation (apexd at
# 21.9 s: "No apex found in session"), which is why this goes into build.prop, set before init
# starts any service.
#
# All our targets run the 4.19 kernel, phones included.
SKIPUNZIP=1

SET_PROP "system" "apexd.config.use_fiemap" "false"
[ "$(GET_PROP "system" "apexd.config.use_fiemap")" = "false" ] \
    || ABORT "! apexd.config.use_fiemap did not land in system build.prop"
LOG "- apexd.config.use_fiemap=false: updated APEX files go through loop devices (I-170)"
