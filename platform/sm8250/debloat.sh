# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# Overlays
SYSTEM_DEBLOAT+="
system/app/WifiRROverlayAppH2E
system/app/WifiRROverlayAppLls
"
PRODUCT_DEBLOAT+="
overlay/SoftapOverlayQC
"

# mAFPC
SYSTEM_DEBLOAT+="
system/bin/mafpc_write
"

# Google
PRODUCT_DEBLOAT+="
priv-app/Velvet
"

#Auto Blocker
SYSTEM_DEBLOAT+="
system/app//Rampart
"

# GameDriver
SYSTEM_DEBLOAT+="
system/priv-app/GameDriver-SM8550
"

# system_ext clean-up
SYSTEM_EXT_DEBLOAT+="
app/QCC
etc/permissions/com.qti.location.sdk.xml
etc/permissions/com.qualcomm.location.xml
etc/permissions/privapp-permissions-com.qualcomm.location.xml
framework/com.qti.location.sdk.jar
priv-app/com.qualcomm.location
"

#I don't need
SYSTEM_DEBLOAT+="
system/app/BookmarkProvider
system/app/Fast
system/app/KidsHome_Installer
system/app/Rampart
system/app/SmartManager_v6_DeviceSecurity
system/priv-app/AREmoji
system/priv-app/HybridRadio
system/priv-app/QRreader
system/priv-app/SOAgent77
system/priv-app/SPPPushClient
system/priv-app/SamsungMagnifier3
system/priv-app/SwiftkeyIme
system/priv-app/SwiftkeySetting
"