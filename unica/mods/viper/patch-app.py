#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Apply reviewed source changes to a fresh extraction of the pinned app."""
from pathlib import Path
import shutil
import sys

here = Path(__file__).resolve().parent
app = Path(sys.argv[1]) / 'app/src/main'

def replace(path, old, new):
    text = path.read_text()
    if text.count(old) != 1:
        raise SystemExit(f'Unexpected upstream source: {path}: {old[:70]}')
    path.write_text(text.replace(old, new))

replace(app / 'AndroidManifest.xml', '    <application',
        '    <uses-permission android:name="android.permission.START_FOREGROUND_SERVICES_FROM_BACKGROUND" />\n\n    <application')
# Keep upstream's specialUse audio-processing service. Priv-app placement alone
# does not qualify for systemExempted on the dm3q framework.
replace(app / 'AndroidManifest.xml', 'android:allowBackup="true"',
        'android:allowBackup="true"\n        android:usesNonSdkApi="true"')
replace(app / 'AndroidManifest.xml', '        <provider', '''        <provider
            android:name=".unica.UnicaControlProvider"
            android:authorities="com.llsl.viper4android.unica"
            android:exported="true"
            android:permission="android.permission.WRITE_SECURE_SETTINGS" />

        <provider''')
destination = app / 'java/com/llsl/viper4android/unica'
destination.mkdir(parents=True)
shutil.copy2(here / 'UnicaControlProvider.kt', destination)

# The master switch is global, not part of a device's saved tuning profile.
service = app / 'java/com/llsl/viper4android/service/ViperService.kt'
replace(service,
        'get() = stateProvider?.invoke()?.masterEnable ?: lastUiState?.masterEnable ?: bootMasterEnabled',
        'get() = bootMasterEnabled')
replace(service, 'val state = currentDeviceState()\n                    stateProvider = null',
        'val state = currentDeviceState().copy(masterEnable = next)\n                    stateProvider = null')
# Keep service state current when the UI or a profile writes the master preference.
replace(service, '            startAudioOutputMonitor()', '''            launch {
                repository.getBooleanPreference(ViperRepository.PREF_MASTER_ENABLE).collect { enabled ->
                    bootMasterEnabled = enabled
                    val state = currentDeviceState().copy(masterEnable = enabled)
                    lastUiState = state
                    applyState(state, enabled)
                }
            }
            startAudioOutputMonitor()''')
# Global mode is the conservative default; per-app mode remains available.
repository = app / 'java/com/llsl/viper4android/data/repository/ViperRepository.kt'
replace(repository, 'import android.annotation.SuppressLint',
        'import android.content.Context\nimport android.net.Uri\nimport dagger.hilt.android.qualifiers.ApplicationContext\nimport android.annotation.SuppressLint')
replace(repository, '        private val dataStore: DataStore<Preferences>,',
        '        private val dataStore: DataStore<Preferences>,\n        @ApplicationContext private val context: Context,')
replace(repository, '            dataStore.edit { it[booleanPreferencesKey(key)] = value }',
        '''            dataStore.edit { it[booleanPreferencesKey(key)] = value }
            if (key == PREF_MASTER_ENABLE) {
                context.contentResolver.notifyChange(Uri.parse("content://com.llsl.viper4android.unica"), null)
            }''')
replace(repository, 'default: Boolean = false,', 'default: Boolean = key == PREF_GLOBAL_MODE,')
replace(app / 'java/com/llsl/viper4android/ui/screens/main/MainViewModel.kt',
        'repository.getBooleanPreference(PREF_GLOBAL_MODE, false).first()',
        'repository.getBooleanPreference(PREF_GLOBAL_MODE, true).first()')
print('Applied UN1CA Settings bridge and global master-state integration')
