#!/usr/bin/env bash
# KidSpark Academy — screenshot capture helper.
#
# Boots the target simulator, normalizes the status bar (9:41, full battery,
# full Wi-Fi, no carrier text), and waits for you to tap through the app to
# each target screen. Press ENTER in the terminal to snap, type 'q' ENTER
# to quit.
#
# Usage:
#   ./submission/capture-screenshots.sh                    # default: 6.9"
#   DEVICE="iPhone 11 Pro Max" ./submission/capture-screenshots.sh  # 6.5"

set -euo pipefail

DEVICE="${DEVICE:-iPhone 17 Pro Max}"
SCHEME="Code app for kids"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$PROJECT_DIR/submission/screenshots/$DEVICE"
mkdir -p "$OUT_DIR"

echo "==> Target device: $DEVICE"
echo "==> Output dir:    $OUT_DIR"

# 1. Find or create a simulator of the right type.
UDID=$(xcrun simctl list devices available | awk -v d="$DEVICE" '
  /-- iOS/ { ios=1; next }
  ios && $0 ~ d {
    match($0, /\(([-A-F0-9]+)\)/, a); print a[1]; exit
  }' || true)

if [ -z "$UDID" ]; then
  echo "!! No available simulator named '$DEVICE'."
  echo "   Create one via Xcode > Settings > Platforms, or:"
  echo "   xcrun simctl create 'kidspark-cap' 'com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max'"
  exit 1
fi
echo "==> UDID: $UDID"

# 2. Boot + open Simulator window.
xcrun simctl boot "$UDID" 2>/dev/null || true
open -a Simulator

# 3. Demo-mode status bar (required for Apple review).
xcrun simctl status_bar "$UDID" override \
  --time "9:41" \
  --dataNetwork "wifi" \
  --wifiMode "active" \
  --wifiBars 3 \
  --cellularMode "notSupported" \
  --batteryState "charged" \
  --batteryLevel 100

# 4. Build and install.
echo "==> Building…"
cd "$PROJECT_DIR/Code app for kids"
xcodebuild -project "Code app for kids.xcodeproj" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,id=$UDID" \
  -configuration Debug \
  -derivedDataPath build \
  build >/dev/null
APP="$(find build -name '*.app' -path '*Debug-iphonesimulator*' | head -1)"
xcrun simctl install "$UDID" "$APP"
xcrun simctl launch "$UDID" com.kidspark.academy >/dev/null

# 5. Interactive capture loop.
cat <<'EOF'

-------------------------------------------------------------
Tap through the app to reach each screen, then:
  ENTER  = snap a screenshot
  q then ENTER = quit

Suggested order (name them in order 01-…05-…):
  01-home, 02-lesson, 03-progress, 04-paywall-gate, 05-parents
-------------------------------------------------------------
EOF

i=1
while true; do
  read -r -p "screenshot $(printf '%02d' $i) > " input || break
  [ "${input:-}" = "q" ] && break
  label="$(printf '%02d' $i)"
  out="$OUT_DIR/${label}-$(date +%s).png"
  xcrun simctl io "$UDID" screenshot "$out"
  echo "   saved: $out"
  i=$((i+1))
done

# 6. Clear the status bar override so it doesn't stick.
xcrun simctl status_bar "$UDID" clear
echo "==> Done. Files in: $OUT_DIR"
