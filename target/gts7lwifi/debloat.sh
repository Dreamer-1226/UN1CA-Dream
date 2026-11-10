#
# Copyright (C) 2024 BlackMesa123
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

# Debloat list for Galaxy Tab S7+ (WIFI|LTE|5G) (gts7xl|gts7xlwifi)
# - Add entries inside the specific partition containing that file (<PARTITION>_DEBLOAT+="")
# - DO NOT add the partition name at the start of any entry (eg. "/system/dpolicy_system")
# - DO NOT add a slash at the start of any entry (eg. "/dpolicy_system")

# Camera SDK
SYSTEM_DEBLOAT+="
system/etc/default-permissions/default-permissions-com.samsung.android.globalpostprocmgr.xml
system/etc/default-permissions/default-permissions-com.samsung.petservice.xml
system/etc/default-permissions/default-permissions-com.samsung.videoscan.xml
system/etc/permissions/privapp-permissions-com.samsung.android.globalpostprocmgr.xml
system/etc/permissions/privapp-permissions-com.samsung.petservice.xml
system/etc/permissions/privapp-permissions-com.samsung.videoscan.xml
system/priv-app/GlobalPostProcMgr
system/priv-app/PetService
system/priv-app/VideoScan
"

# Apps debloat
SYSTEM_DEBLOAT+="
system/priv-app/SohService
"

# AOD: removed. The S22 AOD crash-loops even with ClockPack present (its own clock
# lookup still hits an empty list). The keyguard reads clock faces from ClockPack
# directly, so with AOD gone + ClockPack added (see patches/clockpack) the lock-screen
# clock/widgets render correctly (confirmed on device, matches the Jeys port).
SYSTEM_DEBLOAT+="
system/priv-app/AODService_v80
"

# system_ext clean-up
SYSTEM_DEBLOAT+="
system/etc/permissions/org.carconnectivity.android.digitalkey.rangingintent.xml
system/etc/permissions/org.carconnectivity.android.digitalkey.secureelement.xml
"
SYSTEM_EXT_DEBLOAT+="
framework/org.carconnectivity.android.digitalkey.rangingintent.jar
framework/org.carconnectivity.android.digitalkey.secureelement.jar
priv-app/com.qualcomm.qti.services.systemhelper
"

# Telemetry. unica/debloat.sh:191-193 lists DeviceQualityAgent36, DiagMonAgent95 and SOAgent76, but
# the X810 donor ships them as 37, 97 and 77 (EZF1 and EZI2 alike), so those three upstream lines
# match nothing and _debloat drops its "File not found" quietly. Measured on a T970 running 1.1.3
# (ops/v114_baseline/20260926_1531): diagmonagent stays resident at adj -800, dqagent and soagent
# start twice during every boot and get killed, and DIAGMON writes 472 lines in 20 minutes.
SYSTEM_DEBLOAT+="
system/priv-app/DeviceQualityAgent37
system/priv-app/DiagMonAgent97
system/priv-app/SOAgent77
"
