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

# SEC Floating Feature configuration file for Galaxy Tab S7 (Wi-Fi) (gts7lwifi / SM-T870)
#
# Derived 2026-08-02 from a full key diff of T870XXS8DXH1 stock system+vendor floating_feature
# against T970XXS7DXH1 (the hardware-verified gts7xlwifi tree's device). Every line that differs
# from target/gts7xlwifi/sff.sh cites the stock evidence. The big theme: this panel is an LTPS
# LCD, not AMOLED - every HDR/AMOLED/mdnie-hw key the donor (X810, AMOLED) advertises must be
# DELETED (empty value = SET_FLOATING_FEATURE_CONFIG --delete), or the framework promises panel
# features the hardware cannot do.

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
# T870 stock carries NONE of these (diffed 2026-08-02); the T970/T976B trees set the first two
# TRUE because their AMOLED really is HDR10+. Advertising HDR on this LCD would route HDR video
# down a display path the panel cannot serve.
SEC_FLOATING_FEATURE_COMMON_SUPPORT_HDR_EFFECT=
SEC_FLOATING_FEATURE_MMFW_SUPPORT_HW_HDR=
SEC_FLOATING_FEATURE_MMFW_SUPPORT_HDR10PLUS_PLAYBACK=
SEC_FLOATING_FEATURE_LCD_SUPPORT_AMOLED_DISPLAY=
SEC_FLOATING_FEATURE_MMFW_SUPPORT_DISABLE_PANEL_DIA=
# T870 stock ships HDR2SDR=TRUE instead (tone-map HDR content down for the LCD)
SEC_FLOATING_FEATURE_MMFW_SUPPORT_HDR2SDR=TRUE

# Audio (identical between T870 and T970 stock - verified in the diff)
SEC_FLOATING_FEATURE_AUDIO_CONFIG_INTERPRETER=0
SEC_FLOATING_FEATURE_AUDIO_CONFIG_MULTI_MIC=2
SEC_FLOATING_FEATURE_AUDIO_CONFIG_SOUNDALIVE_VERSION=eq_custom,uhq_onoff,karaoke,adapt,spk_stereo,dvfs_35_percent
SEC_FLOATING_FEATURE_AUDIO_CONFIG_VOLUMEMONITOR_GAIN=3
# Situation volume curves (stv_*). Stock Tab S7 firmware (One UI 5.1.1) has no such key, so the UN1CA merge deletes
# the donor's TRUE; without it SystemUI asks the legacy getter for device 0, gets 1.0, and plays the charging tone at
# the same level whenever system volume is above 0 (I-94, GitLab #3). The curves ship via unica-mods/shared/volume_tables.
# Checked on a T970 on 2026-10-30 with a test module: the tone took stv_charger_connection and followed system volume.
SEC_FLOATING_FEATURE_AUDIO_SUPPORT_SITUATION_EXTENSION=TRUE

# Fingerprint: capacitive sensor in the power key (T870 stock), NOT in-display optical.
# Display selfmask stays disabled like the 12.4" trees (it backs FOD/AOD masking).
SEC_FLOATING_FEATURE_BIOAUTH_CONFIG_FINGERPRINT_FEATURES=capacitive_powerkey_tablet
SEC_FLOATING_FEATURE_LCD_SUPPORT_SELFMASK=0
SEC_FLOATING_FEATURE_LCD_CONFIG_SELFMASK_VERSION=0

# Bixby (same as 12.4")
SEC_FLOATING_FEATURE_BIXBY_CONFIG_CUSTOM_FIRMWARE=0
SEC_FLOATING_FEATURE_BIXBY_SUPPORT_CUSTOM_WAKEUP=2

# Camera - T870 stock values. CAMID set is identical to the 12.4" (wide=0, uw=2, no tele);
# VENDOR_LIB_INFO is T870's OWN stock string (mfhdr/llhdr are arcsoft v4 here, v1 on T970 -
# the solution libs live in the stock vendor we ship, so the list must match THIS vendor)
# plus image_codec.samsung.v2 on the end, which stock does not carry.
# That token is not optional: unica/patches/legacy/customize.sh:189 appends
# image_codec.samsung.v1 whenever the merged list names no image_codec at all, and the One UI 8.5
# camera app knows only v2 (its dex carries v2 and no v1). Shipping v1 makes NodeFactory fall back
# to ImageCodecDummyNode, which throws from initialize() and kills video mode - measured on a T970
# on 2026-08-14 and on y2q on 2026-08-12. Declaring v2 here is what stops the v1 append.
# Until 2026-08-14 this file declared no image_codec, so it shipped the appended v1 and this model
# had the same latent fault; nobody reported it because no 11-inch owner had a v1.0.0 build yet.
SEC_FLOATING_FEATURE_CAMERA_CONFIG_AI_HIGH_RESOLUTION_MAX_CAPTURE=1
SEC_FLOATING_FEATURE_CAMERA_CONFIG_CAMID_TELE_STANDARD_CROP=-1
SEC_FLOATING_FEATURE_CAMERA_CONFIG_CAMID_UW=2
SEC_FLOATING_FEATURE_CAMERA_CONFIG_CAMID_WIDE=0
SEC_FLOATING_FEATURE_CAMERA_CONFIG_NIGHT_FRONT_DISPLAY_FLASH_TRANSPARENT=50
SEC_FLOATING_FEATURE_CAMERA_CONFIG_PERSONALIZATION=CoolOriWarm
SEC_FLOATING_FEATURE_CAMERA_CONFIG_UW_DISTORTION_CORRECTION=0,109,2,19010101,4032,3024,0,0,0,0
SEC_FLOATING_FEATURE_CAMERA_CONFIG_VENDOR_LIB_INFO=beauty.samsung.v4,face_landmark.arcsoft.v2_1,facial_attribute.samsung.v1,super_night.mpi.v2,event_detection.samsung.v2,food.samsung.v1,selfie_correction.samsung.v1,mfhdr.arcsoft.v4,llhdr.arcsoft.v4,swuwdc.arcsoft.v1,human_tracking.arcsoft.v2_1,single_bokeh.samsung.v2,smart_scan.samsung.v2,image_enhance.arcsoft.v1,localtm.samsung.v1_1,scene_detection.samsung.v1,image_codec.samsung.v2
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
# T870-only: front sensor S5K5E9 software lens distortion correction (stock key)
SEC_FLOATING_FEATURE_COMMON_CONFIG_SWLENS_DISTORTION_CORRECTION=gts7,S5K5E9

# Display - LTPS LCD. All from T870 stock:
#   MDNIE_MODE 0 (vs AMOLED 65303), HFR mode 2 with 60/48/96/120 (the LCD has MORE rungs than
#   the 12.4" AMOLED's 60/120), dark-mode replace color #FF171717 (vs #FF121212), screen mode
#   type 1 (vs 0). BLUE_FILTER_ADAPTIVE_MODE stays 0: stock ships 0 and whether this LCD's
#   mdnie can do the adaptive curve is unverified - flip to 2 only after testing on hardware.
SEC_FLOATING_FEATURE_COMMON_CONFIG_MDNIE_MODE=0
SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_MODE=2
SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE=120
SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE=60,48,96,120
# No ..._REFRESH_RATE_NS line, though T870 stock carries NS=60. It cannot survive: this file adds
# it, and UN1CA's product_feature patch deletes it again a few hundred log lines later, while the
# framework.jar half of that same patch SKIPs on this donor ("X810 8.5 smali mismatch"). Traced in
# the 2026-08-02 build log at lines 280 (add), 314 (replace), 950 (delete), 952 (skip). The 12.4"
# tree never had the key and its 120 Hz works, so the honest thing is not to ask for it. Do not
# re-add it without checking that the deletion at line 950 stopped happening.
SEC_FLOATING_FEATURE_LCD_CONFIG_NIGHT_DIM=0
SEC_FLOATING_FEATURE_LCD_SUPPORT_BLUE_FILTER_ADAPTIVE_MODE=0
SEC_FLOATING_FEATURE_LCD_CONFIG_REPLACE_COLOR_FOR_DARKMODE=#FF171717
SEC_FLOATING_FEATURE_LCD_SUPPORT_SCREEN_MODE_TYPE=1

# Frameworks
SEC_FLOATING_FEATURE_FRAMEWORK_SUPPORT_TSP_STATE_MANAGER=deadzone_v2,change_ratio
SEC_FLOATING_FEATURE_SYSTEM_CONFIG_SIOP_POLICY_FILENAME=siop_gts7lwifi_sm8250

# Samsung Gallery app (identical in stock diff)
SEC_FLOATING_FEATURE_GALLERY_CONFIG_AI_EXPANSION=AI_Timelapse
SEC_FLOATING_FEATURE_GALLERY_CONFIG_FACE_CLUSTER_VERSION=SRCB_V3
SEC_FLOATING_FEATURE_GALLERY_CONFIG_IMAGE_TAGGER_VERSION=V516
SEC_FLOATING_FEATURE_GALLERY_CONFIG_ZOOM_TYPE=ZOOM_5K

# Lockscreen - T870 stock supports VIDEO only (no MOTION on this panel/gen)
SEC_FLOATING_FEATURE_LOCKSCREEN_CONFIG_WALLPAPER_STYLE=VIDEO

# S-Pen. Three of these four keys are answers to the Air Command crash both T870 testers hit:
#     NullPointerException: void U2.j.k(android.content.Context)  at G2.j.h
# reproduced on the maintainer's T970 on 2026-08-02 by overlaying the T870 values, and absent
# again once the overlay was removed. The rule that came out of it: the code reading these keys is
# the X810 One UI 8 donor's Air Command, so a value has to name something THAT build implements.
#
# Note what the difference is NOT. Both devices' stock values are equally old - the T970's
# `sticky` is just as much an Android 13 value as the T870's `canvas` - so this is not "old string
# meets new framework". It is one specific capability token: the donor's Air Command has whatever
# `sticky` names and apparently has nothing behind `canvas`, so a lookup returns null and the
# service dies on it. Which token, not which era.
#
# VERSION 72, not stock's 42. This was already 72 in the builds that have run on a T870 - checked
# in the work_dir, not assumed - so 42 was never on those devices and cannot be the crash. (An
# earlier note in ops/ listed the version as 42; that number came from stock firmware, not from the
# shipped ROM.) It stays 72 because the donor's own value is 72 and the 12.4" port runs it.
#
# BLE spec sticky, not stock's canvas. This is the crash. It is the one key that differs between
# every crashing configuration and every working one: T970 (sticky) has zero such crashes across
# months; both T870s (canvas) crash; the T970 crashed twice within minutes of being given canvas
# and stopped when it was taken away. The crashing component is the BLE remote S-Pen service,
# which is precisely what this string configures.
#   Residual uncertainty, stated plainly: the overlay test changed VERSION and BLE together, so
#   in isolation it proved "one of the two". The field evidence above is what exonerates VERSION.
#   Not yet verified: that a T870's own pen still does everything with sticky. Ask a tester to
#   exercise Air Command / air actions after this build - if something is missing, the answer is
#   to find which token differs, not to go back to canvas.
#
# GARAGE SPEC without position/tip_direction. The donor's parser rejects them out loud - the
# testers' logcat carries, on every parse:
#     E [AirCmd]_SpenGarageSpecParser: parseSpec : unknown key - position
#     E [AirCmd]_SpenGarageSpecParser: parseSpec : unknown key - tip_direction
# and then reports a spec that never contained them. They are T870-stock keys this system does
# not know, so sending them is noise at best. Dropping them is NOT what fixes the crash: the
# reproduction on the T970 used the 12.4" garage spec and crashed anyway.
SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_SPEN_VERSION=72
SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_SPEN_GARAGE_SPEC=type=attach, bundled=true, unbundled_spec=remote
SEC_FLOATING_FEATURE_COMMON_SUPPORT_BLE_SPEN=TRUE
SEC_FLOATING_FEATURE_COMMON_CONFIG_BLE_SPEN_SPEC=sticky,button,airmotion
SEC_FLOATING_FEATURE_SETTINGS_CONFIG_SPEN_FCC_ID=A3LEJPT870

# Device specific (brand/FCC from T870 stock; electric rating identical to 12.4" - verified)
SEC_FLOATING_FEATURE_SECURITY_SUPPORT_STRONGBOX=TRUE
SEC_FLOATING_FEATURE_SECURITY_SUPPORT_STRONGBOX_API=TRUE
SEC_FLOATING_FEATURE_SETTINGS_CONFIG_BRAND_NAME=Galaxy Tab S7
SEC_FLOATING_FEATURE_SETTINGS_CONFIG_FCC_ID=A3LSMT870
SEC_FLOATING_FEATURE_SYSTEM_SUPPORT_ENHANCED_CPU_RESPONSIVENESS=TRUE
SEC_FLOATING_FEATURE_SETTINGS_CONFIG_ELECTRIC_RATED_VALUE=DC 9 V; 1.67 A / DC 10 V; 4.5 A
