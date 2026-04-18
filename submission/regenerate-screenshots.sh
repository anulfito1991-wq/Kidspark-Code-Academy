#!/usr/bin/env bash
# One-shot App Store screenshot regeneration.
#
# Runs the ScreenshotCaptureUITests UI test on both required device sizes,
# extracts the named XCTAttachments from each .xcresult bundle, and drops
# them into submission/screenshots/<device>/<NN-name>.png.
#
# Prereqs:
#   - iPhone 17 Pro Max and iPad Pro 13-inch (M5) simulators installed
#   - Xcode 26+ (for iOS 26.4 simulator runtimes)
#
# Usage:
#   ./submission/regenerate-screenshots.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IPHONE_NAME="iPhone 17 Pro Max"
IPAD_NAME="iPad Pro 13-inch (M5)"
SCHEME="Code app for kids"
TEST="Code app for kidsUITests/ScreenshotCaptureUITests/test_captureSubmissionScreens"

find_udid() {
  xcrun simctl list devices available \
    | grep -F "$1" \
    | head -1 \
    | sed -E 's/.*\(([-A-F0-9]+)\).*/\1/'
}

IPHONE_UDID="$(find_udid "$IPHONE_NAME")"
IPAD_UDID="$(find_udid "$IPAD_NAME")"

if [ -z "$IPHONE_UDID" ] || [ -z "$IPAD_UDID" ]; then
  echo "!! Missing simulators. iPhone='$IPHONE_UDID' iPad='$IPAD_UDID'"
  exit 1
fi

# Normalize status bars on both sims (9:41, full wifi+battery, no carrier).
for U in "$IPHONE_UDID" "$IPAD_UDID"; do
  xcrun simctl boot "$U" 2>/dev/null || true
  xcrun simctl status_bar "$U" override \
    --time "9:41" --dataNetwork "wifi" --wifiMode "active" --wifiBars 3 \
    --cellularMode "notSupported" --batteryState "charged" --batteryLevel 100
done

run_device() {
  local udid="$1" label="$2" out="$3"
  local result="/tmp/kidspark-results-$label.xcresult"
  local stage="/tmp/kidspark-attach-$label"
  rm -rf "$result" "$stage"

  echo "==> Running test on $label…"
  cd "$PROJECT_DIR/Code app for kids"
  xcodebuild test \
    -project "Code app for kids.xcodeproj" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,id=$udid" \
    -only-testing:"$TEST" \
    -resultBundlePath "$result" >/dev/null

  xcrun xcresulttool export attachments --path "$result" --output-path "$stage" >/dev/null
  mkdir -p "$out"

  python3 - "$out" "$stage" <<'PY'
import json, shutil, os, re, sys
out, root = sys.argv[1], sys.argv[2]
with open(f"{root}/manifest.json") as f:
    manifest = json.load(f)
for t in manifest:
    for a in t.get("attachments", []):
        name = a.get("suggestedHumanReadableName", "")
        m = re.match(r"^(\d{2}-[a-z0-9\-]+)_", name)
        if not m: continue
        label = m.group(1)
        src = os.path.join(root, a["exportedFileName"])
        dst = os.path.join(out, f"{label}.png")
        if os.path.exists(src):
            shutil.copyfile(src, dst)
            print("   saved", os.path.basename(dst))
PY
}

run_device "$IPHONE_UDID" "iphone" "$PROJECT_DIR/submission/screenshots/iphone-6.9"
run_device "$IPAD_UDID"   "ipad"   "$PROJECT_DIR/submission/screenshots/ipad-13"

# Clear status bar overrides.
for U in "$IPHONE_UDID" "$IPAD_UDID"; do
  xcrun simctl status_bar "$U" clear || true
done

echo
echo "Done."
echo "  iPhone shots: $PROJECT_DIR/submission/screenshots/iphone-6.9/"
echo "  iPad shots:   $PROJECT_DIR/submission/screenshots/ipad-13/"
