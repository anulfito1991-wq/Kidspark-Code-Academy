#!/usr/bin/env bash
# KidSpark Academy — one-shot screenshot prep for App Store submission.
#
# Boots the two simulator sizes Apple requires in 2026:
#   - iPhone 17 Pro Max  (6.9" — cascades down to all smaller iPhones)
#   - iPad Pro 13" (M5)  (13" — cascades down to smaller iPads)
#
# Builds once per device family, installs, normalizes the status bar to
# Apple's demo state (9:41, full battery, full Wi-Fi, no carrier), and
# launches the app on both. Then hands control to a capture loop: pick
# which device to shoot, tap through the app in its Simulator window,
# press ENTER to snap.
#
# Outputs:
#   submission/screenshots/iphone-6.9/NN-<name>.png
#   submission/screenshots/ipad-13/NN-<name>.png
#
# Usage:
#   ./submission/capture-all.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IPHONE_NAME="iPhone 17 Pro Max"
IPAD_NAME="iPad Pro 13-inch (M5)"
BUNDLE_ID="com.kidspark.academy"
SCHEME="Code app for kids"

IPHONE_OUT="$PROJECT_DIR/submission/screenshots/iphone-6.9"
IPAD_OUT="$PROJECT_DIR/submission/screenshots/ipad-13"
mkdir -p "$IPHONE_OUT" "$IPAD_OUT"

# --- Helpers ---------------------------------------------------------------

find_udid() {
  # macOS /usr/bin/awk does not support 3-arg match(), so use grep+sed.
  local name="$1"
  xcrun simctl list devices available \
    | grep -F "$name" \
    | head -1 \
    | sed -E 's/.*\(([-A-F0-9]+)\).*/\1/'
}

prep_sim() {
  local udid="$1" label="$2"
  echo "==> Booting $label ($udid)…"
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl status_bar "$udid" override \
    --time "9:41" \
    --dataNetwork "wifi" \
    --wifiMode "active" \
    --wifiBars 3 \
    --cellularMode "notSupported" \
    --batteryState "charged" \
    --batteryLevel 100
}

build_install_launch() {
  local udid="$1" label="$2"
  echo "==> Building + installing for $label…"
  cd "$PROJECT_DIR/Code app for kids"
  xcodebuild -project "Code app for kids.xcodeproj" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,id=$udid" \
    -configuration Debug \
    -derivedDataPath "build-$label" \
    build >/dev/null
  local app
  app="$(find "build-$label" -name '*.app' -path '*Debug-iphonesimulator*' | head -1)"
  xcrun simctl install "$udid" "$app"
  xcrun simctl launch "$udid" "$BUNDLE_ID" >/dev/null
}

# --- Resolve simulators ----------------------------------------------------

IPHONE_UDID="$(find_udid "$IPHONE_NAME")"
IPAD_UDID="$(find_udid "$IPAD_NAME")"

if [ -z "$IPHONE_UDID" ]; then
  echo "!! '$IPHONE_NAME' simulator not found. Open Xcode > Settings > Platforms and add it."
  exit 1
fi
if [ -z "$IPAD_UDID" ]; then
  echo "!! '$IPAD_NAME' simulator not found. Open Xcode > Settings > Platforms and add it."
  exit 1
fi

echo "iPhone UDID: $IPHONE_UDID"
echo "iPad   UDID: $IPAD_UDID"
open -a Simulator

# --- Prep both -------------------------------------------------------------

prep_sim "$IPHONE_UDID" "iphone"
prep_sim "$IPAD_UDID"   "ipad"
build_install_launch "$IPHONE_UDID" "iphone"
build_install_launch "$IPAD_UDID"   "ipad"

# --- Interactive capture loop ---------------------------------------------

cat <<'BANNER'

-------------------------------------------------------------
Both simulators are ready. KidSpark is already launched on
each. Arrange both Simulator windows side-by-side.

Commands:
   i <label>   snap iPhone  (e.g. "i 01-home")
   p <label>   snap iPad    (e.g. "p 01-home")
   q           quit

Suggested sequence (shoot the same 5 on each device):
   01-home          Learn tab + streak + languages
   02-lesson        Mid-lesson with XP + code-fill or MCQ
   03-progress      Progress tab / visual language tree
   04-paywall-gate  Pro tab with the parental gate visible
   05-parents       Parent Dashboard after PIN unlock
-------------------------------------------------------------
BANNER

snap() {
  local udid="$1" out_dir="$2" label="$3"
  local slug
  slug="${label:-screenshot}"
  local file="$out_dir/${slug}.png"
  xcrun simctl io "$udid" screenshot "$file"
  echo "   saved: $file"
}

while true; do
  read -r -p "cmd > " line || break
  case "$line" in
    q|quit|exit) break ;;
    i\ *) snap "$IPHONE_UDID" "$IPHONE_OUT" "${line#i }" ;;
    p\ *) snap "$IPAD_UDID"   "$IPAD_OUT"   "${line#p }" ;;
    "") ;;
    *) echo "   usage: 'i <label>' | 'p <label>' | 'q'" ;;
  esac
done

# Clear status bar overrides so they don't stick on the sims.
xcrun simctl status_bar "$IPHONE_UDID" clear || true
xcrun simctl status_bar "$IPAD_UDID"   clear || true

echo
echo "Done."
echo "  iPhone shots: $IPHONE_OUT"
echo "  iPad shots:   $IPAD_OUT"
