#!/usr/bin/env bash
# Install the standalone MinsOS-derived report collector in decoded Settings.
set -euo pipefail

[ "$#" = 1 ] || { echo "Usage: $0 <decoded-SecSettings.apk>" >&2; exit 1; }
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
apk=$1
manifest="$apk/AndroidManifest.xml"
page="$apk/res/xml/unica_top_settings.xml"
package=io/mesalabs/unica/reports
activity=io.mesalabs.unica.reports.BugReport
theme=Theme.Settings.RoutineActionActivity
fail() { echo "S20 problem report integration failed: $*" >&2; exit 1; }

if [ ! -f "$manifest" ] || [ ! -f "$page" ]; then
    fail "Missing Settings manifest or UN1CA page"
fi
grep -q 'package="com.android.settings"' "$manifest" || fail "Unexpected Settings package"
grep -rqF "<style name=\"$theme\"" "$apk/res/values" || fail "Missing stock report dialog theme"
[ "$(grep -c '</application>' "$manifest")" = 1 ] || fail "Expected one application closing tag"
[ "$(grep -c '</PreferenceScreen>' "$page")" = 1 ] || fail "Expected one UN1CA PreferenceScreen"

dex_index=1
report_dex=
for dir in "$apk"/smali "$apk"/smali_classes*; do
    [ -d "$dir" ] || continue
    name=${dir##*/}
    if [ "$name" != smali ]; then
        index=${name#smali_classes}
        [[ "$index" =~ ^[0-9]+$ ]] || continue
        [ "$index" -le "$dex_index" ] || dex_index=$index
    fi
    if [ -d "$dir/$package" ]; then
        [ -z "$report_dex" ] || fail "Report classes occur in multiple dex directories"
        report_dex=$dir
    fi
done
report_dex=${report_dex:-"$apk/smali_classes$((dex_index + 1))"}

# Resource names are unique to the collector. Reapplication reuses its own file.
for resources in "$source_dir"/res/*/unica_bugreport_strings.xml; do
    locale=$(basename "$(dirname "$resources")")
    directory="$apk/res/$locale"
    if [ ! -f "$directory/unica_bugreport_strings.xml" ] && [ -d "$directory" ]; then
        if grep -rq 'name="unica_bugreport_' "$directory"; then
            fail "Report resource names already exist in $locale"
        fi
    fi
done

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cp "$manifest" "$tmp/manifest"
cp "$page" "$tmp/page"
if grep -qF "android:name=\"$activity\"" "$manifest"; then
    grep -F "android:name=\"$activity\"" "$manifest" | grep -q 'android:exported="false"' \
        || fail "Report activity must not be exported"
    grep -F "android:name=\"$activity\"" "$manifest" | grep -qF "android:theme=\"@style/$theme\"" \
        || fail "Unexpected report activity theme"
else
    awk -v activity="$activity" -v theme="$theme" '
        /<\/application>/ {
            print "        <activity android:name=\"" activity "\" android:exported=\"false\" android:label=\"@string/unica_bugreport_title\" android:theme=\"@style/" theme "\" />"
        }
        { print }
    ' "$manifest" > "$tmp/manifest"
fi
if ! grep -q 'android:key="unica_bugreport"' "$page"; then
    awk -v activity="$activity" '
        /<\/PreferenceScreen>/ {
            print "    <Preference android:title=\"@string/unica_bugreport_title\" android:key=\"unica_bugreport\">"
            print "        <intent android:targetPackage=\"com.android.settings\" android:targetClass=\"" activity "\" />"
            print "    </Preference>"
        }
        { print }
    ' "$page" > "$tmp/page"
fi

mkdir -p "$report_dex/$package"
cp "$source_dir/smali/$package/"*.smali "$report_dex/$package/"
for resources in "$source_dir"/res/*/unica_bugreport_strings.xml; do
    locale=$(basename "$(dirname "$resources")")
    mkdir -p "$apk/res/$locale"
    cp "$resources" "$apk/res/$locale/"
done
cat "$tmp/manifest" > "$manifest"
cat "$tmp/page" > "$page"
