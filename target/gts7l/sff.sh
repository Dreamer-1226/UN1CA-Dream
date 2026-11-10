#
# Copyright (C) 2024 Salvo Giangreco
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# SEC Floating Feature configuration file for Galaxy Tab S7 (LTE) (gts7l / SM-T875)
#
# Derived 2026-08-05 from a full key diff of T875XXS8DXH2 stock system+vendor floating_feature
# against T870XXS8DXH1 — the tree this file descends from, itself derived from a full diff against
# the hardware-verified T970. The system files differ in EXACTLY FIVE keys (VOLUMEMONITOR_GAIN,
# CAMERA VENDOR_LIB_INFO, AUTO_ROTATION_OF_SMARTWIDGET, FCC_ID, SIOP filename), so every other
# line below is T875-measured by that diff, not assumed. The vendor floating_feature ships inside
# T875's own stock vendor partition and is not this file's business.
#
# The five deltas are marked "T875 DELTA" below. One is an absence: T870 stock carries
# FRAMEWORK_SUPPORT_AUTO_ROTATION_OF_SMARTWIDGET=TRUE and T875 stock does not — but the X810 donor
# does not carry the key either (checked 2026-08-05), so there is nothing to set or delete here.
#
# Panel story is identical to gts7lwifi: LTPS LCD, not AMOLED — every HDR/AMOLED/mdnie-hw key the
# donor (X810, AMOLED) advertises must be DELETED (empty value = --delete), or the framework
# promises panel features the hardware cannot do.

# Disable unsupported features (same set as gts7xlwifi)
SEC_FLOATING_FEATURE_AUDIO_CONFIG_MIC_POSITION=
SEC_FLOATING_FEATURE_AUDIO_SUPPORT_MICMODE_QUICK_PANEL=
SEC_FLOATING_FEATURE_AUDIO_SUPPORT_VOIP_VIA_SMART_MONITOR=
SEC_FLOATING_FEATURE_BATTERY_SUPPORT_BSOH_GALAXYDIAGNOSTICS=
SEC_FLOATING_FEATURE_BATTERY_SUPPORT_PASS_THROUGH=
SEC_FLOATING_FEATURE_BIXBY_SUPPORT_BIXBYKWD=
SEC_FLOATING_FEATURE_CAMERA_CONFIG_AIFRC_SPEC=
SEC_FLOATING_FEATURE_CAMERA_CONFIG_GALAXYRAW_PLATFORM_VERSION=
SEC_FLOATING_FEATURE_CAMERA_CONFIG_SDK_FEATURE_INFO=
SEC_FLOATING_FEATURE_CAMERA_SUPPORT_30FPS_ALL_PORTRAITVIDEO=
SEC_FLOATING_FEATURE_CAMERA_SUPPORT_4K_PORTRAITVIDEO=
SEC_FLOATING_FEATURE_CAMERA_SUPPORT_AFSKIP=
SEC_FLOATING_FEATURE_CAMERA_SUPPORT_AIFRC=
SEC_FLOATING_FEATURE_CAMERA_SUPPORT_AI_HIGH_RESOLUTION=
SEC_FLOATING_FEATURE_CAMERA_SUPPORT_GALLERY_LR=
SEC_FLOATING_FEATURE_CAMERA_SUPPORT_HIGH_RESOLUTION_MEMORY_CHECK=
SEC_FLOATING_FEATURE_CAMERA_SUPPORT_HYPERLAPSE_VDISONOFF=
SEC_FLOATING_FEATURE_CAMERA_SUPPORT_LOGICAL_CAMERA=
SEC_FLOATING_FEATURE_CAMERA_SUPPORT_PRO_RGB_CONVERSION=
SEC_FLOATING_FEATURE_CAMERA_SUPPORT_VDIS_PORTRAITVIDEO=
SEC_FLOATING_FEATURE_COMMON_CONFIG_EMBEDDED_SIM_SLOTSWITCH=
SEC_FLOATING_FEATURE_COMMON_SUPPORT_COLOR_LENS=
SEC_FLOATING_FEATURE_GRAPHICS_SUPPORT_AUTO_CONTROL_DEFAULT=
SEC_FLOATING_FEATURE_LCD_SUPPORT_MDNIE_HW=
SEC_FLOATING_FEATURE_LOCKSCREEN_CONFIG_SUBDISPLAY_POLICY=
SEC_FLOATING_FEATURE_MMFW_SUPPORT_LONGEXPOSURE_EFFECT=
SEC_FLOATING_FEATURE_SYSTEM_SUPPORT_LOW_HEAT_MODE=
SEC_FLOATING_FEATURE_VIDEO_CONFIG_VIDEO_CLIPPING_MODE=

# LCD panel, not AMOLED - delete every HDR/AMOLED key the X810 donor advertises.
# T875 stock carries NONE of these (same as T870, confirmed in the 2026-08-05 diff); the
# T970/T976B trees set the first two TRUE because their AMOLED really is HDR10+. Advertising HDR
# on this LCD would route HDR video down a display path the panel cannot serve.
SEC_FLOATING_FEATURE_COMMON_SUPPORT_HDR_EFFECT=
SEC_FLOATING_FEATURE_MMFW_SUPPORT_HW_HDR=
SEC_FLOATING_FEATURE_MMFW_SUPPORT_HDR10PLUS_PLAYBACK=
SEC_FLOATING_FEATURE_LCD_SUPPORT_AMOLED_DISPLAY=
SEC_FLOATING_FEATURE_MMFW_SUPPORT_DISABLE_PANEL_DIA=
# Stock ships HDR2SDR=TRUE instead (tone-map HDR content down for the LCD)
SEC_FLOATING_FEATURE_MMFW_SUPPORT_HDR2SDR=TRUE

# Audio
SEC_FLOATING_FEATURE_AUDIO_CONFIG_INTERPRETER=0
SEC_FLOATING_FEATURE_AUDIO_CONFIG_MULTI_MIC=2
SEC_FLOATING_FEATURE_AUDIO_CONFIG_SOUNDALIVE_VERSION=eq_custom,uhq_onoff,karaoke,adapt,spk_stereo,dvfs_35_percent
# T875 DELTA: stock ships 0 here where T870 ships 3 (2026-08-05 diff).
SEC_FLOATING_FEATURE_AUDIO_CONFIG_VOLUMEMONITOR_GAIN=0
# Situation volume curves (stv_*). Stock Tab S7 firmware (One UI 5.1.1) has no such key, so the UN1CA merge deletes
# the donor's TRUE; without it SystemUI asks the legacy getter for device 0, gets 1.0, and plays the charging tone at
# the same level whenever system volume is above 0 (I-94, GitLab #3). The curves ship via unica-mods/shared/volume_tables.
# Checked on a T970 on 2026-10-30 with a test module: the tone took stv_charger_connection and followed system volume.
SEC_FLOATING_FEATURE_AUDIO_SUPPORT_SITUATION_EXTENSION=TRUE

# Fingerprint: capacitive sensor in the power key (T875 stock, same as T870), NOT in-display
# optical. Display selfmask stays disabled like the 12.4" trees (it backs FOD/AOD masking).
SEC_FLOATING_FEATURE_BIOAUTH_CONFIG_FINGERPRINT_FEATURES=capacitive_powerkey_tablet
SEC_FLOATING_FEATURE_LCD_SUPPORT_SELFMASK=0
SEC_FLOATING_FEATURE_LCD_CONFIG_SELFMASK_VERSION=0

# Bixby (same as 12.4")
SEC_FLOATING_FEATURE_BIXBY_CONFIG_CUSTOM_FIRMWARE=0
SEC_FLOATING_FEATURE_BIXBY_SUPPORT_CUSTOM_WAKEUP=2

# Camera - T875 stock values. CAMID set is identical to the 12.4" (wide=0, uw=2, no tele).
# T875 DELTA: VENDOR_LIB_INFO is T875's OWN stock string - mfhdr/llhdr are arcsoft v1 here,
# where T870 stock says v4 (and T970 also says v1). The solution libs live in the stock vendor we
# ship, so the list must match THIS vendor, not the sibling's.
# image_codec.samsung.v2 is appended to that stock string and is not optional: without an
# image_codec entry, unica/patches/legacy/customize.sh:189 appends v1, and the One UI 8.5 camera
# app knows only v2, so video mode dies on ImageCodecDummyNode. See target/gts7xlwifi/sff.sh.
SEC_FLOATING_FEATURE_CAMERA_CONFIG_AI_HIGH_RESOLUTION_MAX_CAPTURE=1
SEC_FLOATING_FEATURE_CAMERA_CONFIG_CAMID_TELE_STANDARD_CROP=-1
SEC_FLOATING_FEATURE_CAMERA_CONFIG_CAMID_UW=2
SEC_FLOATING_FEATURE_CAMERA_CONFIG_CAMID_WIDE=0
SEC_FLOATING_FEATURE_CAMERA_CONFIG_NIGHT_FRONT_DISPLAY_FLASH_TRANSPARENT=50
SEC_FLOATING_FEATURE_CAMERA_CONFIG_PERSONALIZATION=CoolOriWarm
SEC_FLOATING_FEATURE_CAMERA_CONFIG_UW_DISTORTION_CORRECTION=0,109,2,19010101,4032,3024,0,0,0,0
SEC_FLOATING_FEATURE_CAMERA_CONFIG_VENDOR_LIB_INFO=beauty.samsung.v4,face_landmark.arcsoft.v2_1,facial_attribute.samsung.v1,super_night.mpi.v2,event_detection.samsung.v2,food.samsung.v1,selfie_correction.samsung.v1,mfhdr.arcsoft.v1,llhdr.arcsoft.v1,swuwdc.arcsoft.v1,human_tracking.arcsoft.v2_1,single_bokeh.samsung.v2,smart_scan.samsung.v2,image_enhance.arcsoft.v1,localtm.samsung.v1_1,scene_detection.samsung.v1,image_codec.samsung.v2
SEC_FLOATING_FEATURE_CAMERA_CONFIG_VERSION_FILTER_PROVIDER=5
SEC_FLOATING_FEATURE_CAMERA_CONFIG_WIDE_DISTORTION_CORRECTION=0,0,0,0,0,0,0,0,0,0
# Same two document scan solutions the 12.4-inch builds ship (the T970 reads AI_DEWARPING,SHADOW_REMOVAL and
# saves straightened scans). Stock 5.1.1 has no such key at all, so it says nothing either way. Not yet
# confirmed on an 11-inch tablet.
SEC_FLOATING_FEATURE_CAMERA_DOCUMENTSCAN_SOLUTIONS=AI_DEWARPING,SHADOW_REMOVAL
SEC_FLOATING_FEATURE_SAIV_CONFIG_MIDAS=UPSCALE,LOWLIGHT,HDR,DEBLUR,MOIRE,DENOISE_DEBLUR,UPSCALE_DEBLUR,PHOTOPOLISH,SHADOW,REFLECTION,UWDC
SEC_FLOATING_FEATURE_CAMERA_GRAW_CONFIG_MFP_PIPELINE_MODE=V1
SEC_FLOATING_FEATURE_VISION_CONFIG_RELIGHTING_SOLUTION=arcsoft_effectonly.v1
# Gallery Recap stories (quarterly/yearly, people and pets). The donor sets RECAP; the merge drops any
# donor key the T970 One UI 5 file lacks, so it never reached the build. StoryService is the only reader
# and curates in-app over the Gallery database (no native library, no NPU). 10-02 feature sweep.
SEC_FLOATING_FEATURE_VISION_CONFIG_STORYGEN=RECAP
# Front sensor S5K5E9 software lens distortion correction (stock key, same as T870)
SEC_FLOATING_FEATURE_COMMON_CONFIG_SWLENS_DISTORTION_CORRECTION=gts7,S5K5E9

# Display - LTPS LCD, all values confirmed identical to T870 in the 2026-08-05 diff:
#   MDNIE_MODE 0 (vs AMOLED 65303), HFR mode 2 with 60/48/96/120 (the LCD has MORE rungs than
#   the 12.4" AMOLED's 60/120), dark-mode replace color #FF171717 (vs #FF121212), screen mode
#   type 1 (vs 0). BLUE_FILTER_ADAPTIVE_MODE stays 0: stock ships 0 and whether this LCD's
#   mdnie can do the adaptive curve is unverified - flip to 2 only after testing on hardware.
SEC_FLOATING_FEATURE_COMMON_CONFIG_MDNIE_MODE=0
SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_MODE=2
SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE=120
SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE=60,48,96,120
# No ..._REFRESH_RATE_NS line - same reasoning as gts7lwifi/sff.sh documents: this file would add
# it and UN1CA's product_feature patch deletes it again later in the same build, so the honest
# thing is not to ask for it.
SEC_FLOATING_FEATURE_LCD_CONFIG_NIGHT_DIM=0
SEC_FLOATING_FEATURE_LCD_SUPPORT_BLUE_FILTER_ADAPTIVE_MODE=0
SEC_FLOATING_FEATURE_LCD_CONFIG_REPLACE_COLOR_FOR_DARKMODE=#FF171717
SEC_FLOATING_FEATURE_LCD_SUPPORT_SCREEN_MODE_TYPE=1

# Frameworks
SEC_FLOATING_FEATURE_FRAMEWORK_SUPPORT_TSP_STATE_MANAGER=deadzone_v2,change_ratio
# T875 DELTA: its stock names its own SIOP policy (T870 stock: siop_gts7lwifi_sm8250). The file
# itself ships in dvfs/siop_model.xml, extracted from T875's SamsungDeviceHealthManagerService.apk
# res/raw/siop_gts7l_sm8250.xml on 2026-08-05.
SEC_FLOATING_FEATURE_SYSTEM_CONFIG_SIOP_POLICY_FILENAME=siop_gts7l_sm8250

# Samsung Gallery app (identical in the stock diff)
SEC_FLOATING_FEATURE_GALLERY_CONFIG_AI_EXPANSION=AI_Timelapse
SEC_FLOATING_FEATURE_GALLERY_CONFIG_FACE_CLUSTER_VERSION=SRCB_V3
SEC_FLOATING_FEATURE_GALLERY_CONFIG_IMAGE_TAGGER_VERSION=V516
SEC_FLOATING_FEATURE_GALLERY_CONFIG_ZOOM_TYPE=ZOOM_5K

# Lockscreen - stock supports VIDEO only (no MOTION on this panel/gen), same as T870
SEC_FLOATING_FEATURE_LOCKSCREEN_CONFIG_WALLPAPER_STYLE=VIDEO

# S-Pen. Identical to gts7lwifi ON MEASUREMENT: the 2026-08-05 diff shows every S-Pen key equal
# between T875 and T870 stock, including SPEN_FCC_ID=A3LEJPT870 (the pen is the pen). The full
# story of why BLE spec says `sticky` and not stock's `canvas` - the Air Command crash both T870
# testers hit, reproduced and un-reproduced on the maintainer's T970 - lives in
# target/gts7lwifi/sff.sh; the reasoning transfers verbatim because the stock values are equal.
SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_SPEN_VERSION=72
SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_SPEN_GARAGE_SPEC=type=attach, bundled=true, unbundled_spec=remote
SEC_FLOATING_FEATURE_COMMON_SUPPORT_BLE_SPEN=TRUE
SEC_FLOATING_FEATURE_COMMON_CONFIG_BLE_SPEN_SPEC=sticky,button,airmotion
SEC_FLOATING_FEATURE_SETTINGS_CONFIG_SPEN_FCC_ID=A3LEJPT870

# Device specific (brand from stock; electric rating identical to 12.4" - verified)
# T875 DELTA: the tablet's own FCC ID.
SEC_FLOATING_FEATURE_SECURITY_SUPPORT_STRONGBOX=TRUE
SEC_FLOATING_FEATURE_SECURITY_SUPPORT_STRONGBOX_API=TRUE
SEC_FLOATING_FEATURE_SETTINGS_CONFIG_BRAND_NAME=Galaxy Tab S7
SEC_FLOATING_FEATURE_SETTINGS_CONFIG_FCC_ID=A3LSMT875
SEC_FLOATING_FEATURE_SYSTEM_SUPPORT_ENHANCED_CPU_RESPONSIVENESS=TRUE
SEC_FLOATING_FEATURE_SETTINGS_CONFIG_ELECTRIC_RATED_VALUE=DC 9 V; 1.67 A / DC 10 V; 4.5 A
