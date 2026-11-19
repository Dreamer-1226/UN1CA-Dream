# Instant Slow-mo on z3q. The donor asks the vendor MPP for AI FRC (type 7), which SM8250 does
# not have (the aifrc.dlc only carries an HTP v73 cache). The vendor ships a 2x FRUC (type 3,
# OpenCL on Adreno 650) behind an mpp V1 AIDL server, so libaplayer is pointed at that instead
# and libmppclient is taught to live with the V1 server.
_LIB="$WORK_DIR/system/system/lib64"

LOG_STEP_IN "- libaplayer: AI FRC -> vendor FRC"
# isAiFrcSupported(): IsSupported(7) -> IsSupported(3)
HEX_PATCH "$_LIB/libaplayer.so" "e1230091e0008052a1" "e123009160008052a1"
# createPostGenerator(): MppGenerator::Type AIFRC(4) -> FRC(2)
HEX_PATCH "$_LIB/libaplayer.so" "750200f99500805280" "750200f95500805280"
# isColorFormatRequired(): always request a decoder colour format (no UBWC into the V1 MPP)
HEX_PATCH "$_LIB/libaplayer.so" "52380494c0000034a1f7fff0" "5238049406000014a1f7fff0"
# setupVideo(): no useInputSurface (queueInput does not exist in mpp V1)
HEX_PATCH "$_LIB/libaplayer.so" "0008005458020036c1fbffb0" "0008005412000014c1fbffb0"
# APlayerWrapper::setVideoFrc(): (4, 0.25) -> (2, 0.5), the FRUC only interpolates 2x
HEX_PATCH "$_LIB/libaplayer.so" "3f0008eb810300540041201e" "3f0008eb1c0000140041201e"
HEX_PATCH "$_LIB/libaplayer.so" \
    "ebffff1768408cd2e00700f9c848aef26844dff2e850f8f2e00308aa5bbe0694" \
    "ebffff179f120071490080523401941a01102c1e280c281ee0ffff175bbe0694"
LOG_STEP_OUT

LOG_STEP_IN "- libmppclient: tolerate the mpp V1 server"
# BufferFlowControl::updateBufferParam(): calcBufferElevation is V5-only, keep the init value
HEX_PATCH "$_LIB/libmppclient.so" "a00000341500b05206000014" "a0000034f5031f2a06000014"
LOG_STEP_OUT

LOG_STEP_IN "- vendor libmppfrc: allow 4K input"
# FRCFactory::getMppCapability(): 1920x1088 -> 3840x2176 (4K30 verified on device)
HEX_PATCH "$WORK_DIR/vendor/lib64/libmppfrc.so" "0100000080070000400400006f77" "01000000000f0000800800006f77"
LOG_STEP_OUT

unset _LIB
