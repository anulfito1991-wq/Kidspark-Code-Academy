#!/usr/bin/env python3
"""Upload all 10 App Store screenshots to App Store Connect via the REST API.

Requires an API key with App Manager access under
`private_keys/AuthKey_<KEY_ID>.p8`. Everything else is stdlib.
"""

import base64, hashlib, json, os, subprocess, sys, time
import urllib.request, urllib.error

KEY_ID     = "KDFPL64CHR"
ISSUER     = "51549305-fc95-4dc5-a0bb-41060f7b0a57"
KEY_PATH   = "private_keys/AuthKey_KDFPL64CHR.p8"
APP_ID     = "6762496898"
VERSION_ID = "afc4e171-d1d1-4894-9b98-cdbbef7bb38a"
LOC_ID     = "9ad65bbd-5056-4891-a91e-451705f909f0"

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

DEVICES = [
    ("APP_IPHONE_67",         os.path.join(ROOT, "submission/screenshots/iphone-6.7")),
    ("APP_IPAD_PRO_3GEN_129", os.path.join(ROOT, "submission/screenshots/ipad-12.9")),
]
FILES = ["01-home.png", "02-lesson.png", "03-progress.png",
         "04-paywall-gate.png", "05-parents.png"]


# --- JWT signing ----------------------------------------------------------

def _b64url(b): return base64.urlsafe_b64encode(b).rstrip(b"=").decode()

def _jwt():
    header  = {"alg": "ES256", "kid": KEY_ID, "typ": "JWT"}
    payload = {"iss": ISSUER, "iat": int(time.time()),
               "exp": int(time.time()) + 1200, "aud": "appstoreconnect-v1"}
    si = f"{_b64url(json.dumps(header,separators=(',',':')).encode())}.{_b64url(json.dumps(payload,separators=(',',':')).encode())}"
    der = subprocess.run(
        ["openssl", "dgst", "-sha256", "-sign", KEY_PATH, "-binary"],
        input=si.encode(), capture_output=True, check=True,
    ).stdout
    # Convert DER ECDSA signature to fixed 32+32 R||S.
    i = 2 if der[1] < 0x80 else 3
    rl = der[i+1]; r = der[i+2:i+2+rl]; j = i+2+rl
    sl = der[j+1]; s = der[j+2:j+2+sl]
    rs = r.lstrip(b"\x00").rjust(32, b"\x00") + s.lstrip(b"\x00").rjust(32, b"\x00")
    return f"{si}.{_b64url(rs)}"


def api(method, path, body=None):
    """Call App Store Connect and return parsed JSON (or None for 204)."""
    url = f"https://api.appstoreconnect.apple.com{path}"
    hdrs = {"Authorization": f"Bearer {_jwt()}"}
    data = None
    if body is not None:
        data = json.dumps(body).encode()
        hdrs["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=data, method=method, headers=hdrs)
    try:
        resp = urllib.request.urlopen(req, timeout=60)
        raw = resp.read()
        return json.loads(raw.decode()) if raw else None
    except urllib.error.HTTPError as e:
        sys.stderr.write(f"HTTP {e.code} on {method} {path}\n{e.read().decode()}\n")
        raise


# --- Screenshot set helpers ----------------------------------------------

def create_set(display_type):
    return api("POST", "/v1/appScreenshotSets", {
        "data": {
            "type": "appScreenshotSets",
            "attributes": {"screenshotDisplayType": display_type},
            "relationships": {
                "appStoreVersionLocalization": {
                    "data": {"type": "appStoreVersionLocalizations", "id": LOC_ID}
                }
            },
        }
    })["data"]

def reserve_screenshot(set_id, filename, size):
    return api("POST", "/v1/appScreenshots", {
        "data": {
            "type": "appScreenshots",
            "attributes": {"fileName": filename, "fileSize": size},
            "relationships": {
                "appScreenshotSet": {
                    "data": {"type": "appScreenshotSets", "id": set_id}
                }
            },
        }
    })["data"]

def upload_chunks(ops, file_bytes):
    for op in ops:
        offset = int(op.get("offset", 0))
        length = int(op.get("length", len(file_bytes)))
        chunk = file_bytes[offset:offset + length]
        hdrs = {h["name"]: h["value"] for h in op.get("requestHeaders", [])}
        req = urllib.request.Request(op["url"], data=chunk,
                                     method=op.get("method", "PUT"),
                                     headers=hdrs)
        resp = urllib.request.urlopen(req, timeout=120)
        resp.read()

def commit_screenshot(screenshot_id, md5_hex):
    return api("PATCH", f"/v1/appScreenshots/{screenshot_id}", {
        "data": {
            "type": "appScreenshots",
            "id": screenshot_id,
            "attributes": {"uploaded": True, "sourceFileChecksum": md5_hex},
        }
    })

def reorder_set(set_id, screenshot_ids):
    # Locks the carousel order shown on the App Store page.
    api("PATCH", f"/v1/appScreenshotSets/{set_id}/relationships/appScreenshots", {
        "data": [{"type": "appScreenshots", "id": sid} for sid in screenshot_ids]
    })


# --- Main ----------------------------------------------------------------

def main():
    for display_type, folder in DEVICES:
        print(f"\n=== {display_type} ===")
        set_obj = create_set(display_type)
        set_id = set_obj["id"]
        print(f"  created set {set_id}")

        uploaded_ids = []
        for fname in FILES:
            path = os.path.join(folder, fname)
            with open(path, "rb") as f:
                blob = f.read()
            md5 = hashlib.md5(blob).hexdigest()

            reservation = reserve_screenshot(set_id, fname, len(blob))
            ss_id = reservation["id"]
            ops = reservation["attributes"]["uploadOperations"]

            print(f"  → uploading {fname} ({len(blob)//1024} KB, {len(ops)} chunk) as {ss_id}")
            upload_chunks(ops, blob)
            commit_screenshot(ss_id, md5)
            uploaded_ids.append(ss_id)

        reorder_set(set_id, uploaded_ids)
        print(f"  ordered {len(uploaded_ids)} screenshots 01 → 05")

    print("\nAll uploads done.")

if __name__ == "__main__":
    main()
