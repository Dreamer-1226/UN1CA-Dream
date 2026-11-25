# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# SEC Floating Feature configuration file for Galaxy S20 Ultra (SnapDragon) (z3q)

# Enable AOD live clock
SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_AOD_ITEM=activeclock=7,aodversion=7,clocktransition,coverboldfont

# Set default HFR Refresh Rate
SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE=120

# Enable seamless refresh rate feature
SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_MODE=2

# Enable extra brightness feature
SEC_FLOATING_FEATURE_LCD_SUPPORT_EXTRA_BRIGHTNESS=TRUE

# Charging
SEC_FLOATING_FEATURE_SETTINGS_CONFIG_ELECTRIC_RATED_VALUE=DC 9 V; 2.77 A / 10 v; 4.50 A

# Touch sensitivity (screen protector) toggle in Display settings
SEC_FLOATING_FEATURE_SETTINGS_SUPPORT_TOUCH_SENSTIVITY_MATERIAL=TRUE
SEC_FLOATING_FEATURE_SETTINGS_SUPPORT_TOUCH_GLOVE_MATERIAL=TRUE



# Gallery Best Face and RAW editing (Lightroom), as on S23

SEC_FLOATING_FEATURE_GALLERY_CONFIG_BEST_FACE_MODE=GENIMAGE

SEC_FLOATING_FEATURE_CAMERA_SUPPORT_GALLERY_LR=TRUE
SEC_FLOATING_FEATURE_CAMERA_SUPPORT_PRO_RGB_CONVERSION=TRUE


# Instant Slow-mo (see patches/instant_slowmo). No HDR: the decoder only emits 10-bit TP10
# for HDR and the FRUC is 8-bit.
SEC_FLOATING_FEATURE_CAMERA_SUPPORT_AIFRC=TRUE
SEC_FLOATING_FEATURE_CAMERA_CONFIG_AIFRC_SPEC=720,1,3840,2160,24,60

# Gallery long exposure for motion photos (libSlowShutter_jni -> libSlowShutter-core -> libFrucPSVTLib,
# all three in the system image). The donor only sets the _10BIT variant, so the menu never showed.
SEC_FLOATING_FEATURE_MMFW_SUPPORT_LONGEXPOSURE_EFFECT=TRUE
