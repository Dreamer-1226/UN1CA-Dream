# Copyright (c) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later

# SEC Floating Feature configuration file for Galaxy S20+ (SnapDragon) (y2q)

# Enable AOD live clock
SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_AOD_ITEM=activeclock=7,aodversion=7,clocktransition,coverboldfont

# Set default HFR Refresh Rate
SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE=120

# Enable seamless refresh rate feature
SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_MODE=2

# Enable extra brightness feature
SEC_FLOATING_FEATURE_LCD_SUPPORT_EXTRA_BRIGHTNESS=TRUE

# Touch sensitivity (screen protector) toggle in Display settings
SEC_FLOATING_FEATURE_SETTINGS_SUPPORT_TOUCH_SENSTIVITY_MATERIAL=TRUE
SEC_FLOATING_FEATURE_SETTINGS_SUPPORT_TOUCH_GLOVE_MATERIAL=TRUE



# Gallery Best Face and RAW editing (Lightroom), as on S23

SEC_FLOATING_FEATURE_GALLERY_CONFIG_BEST_FACE_MODE=GENIMAGE

SEC_FLOATING_FEATURE_CAMERA_SUPPORT_GALLERY_LR=TRUE
SEC_FLOATING_FEATURE_CAMERA_SUPPORT_PRO_RGB_CONVERSION=TRUE


# Gallery long exposure for motion photos (libSlowShutter_jni -> libSlowShutter-core -> libFrucPSVTLib,
# all three in the system image). The donor only sets the _10BIT variant, so the menu never showed.
SEC_FLOATING_FEATURE_MMFW_SUPPORT_LONGEXPOSURE_EFFECT=TRUE
