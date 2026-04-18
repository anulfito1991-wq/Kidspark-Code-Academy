#!/usr/bin/env python3
"""Audit every submission-relevant field on the 1.0 version and print a
what-is-set / what-is-missing table."""
import base64, json, subprocess, sys, time, urllib.request, urllib.error

KEY_ID="KDFPL64CHR"; ISSUER="51549305-fc95-4dc5-a0bb-41060f7b0a57"
KEY_PATH="private_keys/AuthKey_KDFPL64CHR.p8"
APP="6762496898"; VERSION="afc4e171-d1d1-4894-9b98-cdbbef7bb38a"
LOC="9ad65bbd-5056-4891-a91e-451705f909f0"

def _b(x): return base64.urlsafe_b64encode(x).rstrip(b"=").decode()
def _jwt():
    h={"alg":"ES256","kid":KEY_ID,"typ":"JWT"}
    p={"iss":ISSUER,"iat":int(time.time()),"exp":int(time.time())+600,"aud":"appstoreconnect-v1"}
    si=f"{_b(json.dumps(h,separators=(',',':')).encode())}.{_b(json.dumps(p,separators=(',',':')).encode())}"
    der=subprocess.run(["openssl","dgst","-sha256","-sign",KEY_PATH,"-binary"],input=si.encode(),capture_output=True,check=True).stdout
    i=2 if der[1]<0x80 else 3;rl=der[i+1];r=der[i+2:i+2+rl];j=i+2+rl;sl=der[j+1];s=der[j+2:j+2+sl]
    rs=r.lstrip(b"\x00").rjust(32,b"\x00")+s.lstrip(b"\x00").rjust(32,b"\x00")
    return f"{si}.{_b(rs)}"
def api(path):
    url=f"https://api.appstoreconnect.apple.com{path}"
    req=urllib.request.Request(url,headers={"Authorization":f"Bearer {_jwt()}"})
    try: return json.loads(urllib.request.urlopen(req,timeout=30).read())
    except urllib.error.HTTPError as e:
        return {"_error":f"{e.code} {e.read().decode()[:200]}"}

def show(title, obj, keys):
    print(f"\n## {title}")
    for k in keys:
        v = obj.get(k)
        flag = "✓" if v not in (None, "", [], {}) else "✗"
        pretty = v if v is None or isinstance(v,(str,int,bool)) else json.dumps(v)[:90]
        print(f"  {flag} {k}: {pretty}")

# App-level
app = api(f"/v1/apps/{APP}?include=appInfos,betaAppReviewDetail")
attrs = app["data"]["attributes"]
show("App attributes", attrs, ["name","bundleId","sku","primaryLocale","contentRightsDeclaration"])

# App Info (categories etc.)
infos = api(f"/v1/apps/{APP}/appInfos")
if infos.get("data"):
    info = infos["data"][0]
    iid = info["id"]
    show(f"AppInfo {iid}", info["attributes"], ["appStoreState","appStoreAgeRating","brazilAgeRating"])
    cats = api(f"/v1/appInfos/{iid}?include=primaryCategory,secondaryCategory,ageRatingDeclaration")
    prim = None; sec = None
    for inc in cats.get("included",[]):
        if inc["type"] == "appCategories":
            if prim is None: prim = inc["id"]
            else: sec = inc["id"]
    print(f"  categories: primary={prim}  secondary={sec}")

    # AppInfo localizations (subtitle lives here for 2022+ flow)
    ail = api(f"/v1/appInfos/{iid}/appInfoLocalizations")
    for l in ail.get("data",[]):
        a = l["attributes"]
        show(f"AppInfoLocalization {a.get('locale')}", a, ["name","subtitle","privacyPolicyUrl","privacyChoicesUrl","privacyPolicyText"])

# Version
v = api(f"/v1/appStoreVersions/{VERSION}")
show("AppStoreVersion", v["data"]["attributes"], ["versionString","copyright","releaseType","earliestReleaseDate","appStoreState","platform","downloadable"])

# VersionLocalization — description, keywords, promo, URLs
vl = api(f"/v1/appStoreVersionLocalizations/{LOC}")
show("VersionLocalization en-US", vl["data"]["attributes"],
     ["description","keywords","marketingUrl","promotionalText","supportUrl","whatsNew"])

# App Review Information
rd = api(f"/v1/appStoreVersions/{VERSION}/appStoreReviewDetail")
if rd.get("data"):
    show("AppStoreReviewDetail", rd["data"]["attributes"],
         ["contactFirstName","contactLastName","contactPhone","contactEmail","demoAccountName","demoAccountPassword","demoAccountRequired","notes"])
else:
    print("\n## AppStoreReviewDetail\n  ✗ not created yet")

# Build linked
builds = api(f"/v1/appStoreVersions/{VERSION}/build")
bd = builds.get("data")
if bd:
    print(f"\n## Build linked: id={bd['id']}")
else:
    print("\n## Build\n  ✗ no build attached to 1.0 (will need TestFlight archive upload)")

# Age rating declaration
ard = api(f"/v1/apps/{APP}?include=ageRatingDeclaration")
for inc in ard.get("included",[]):
    if inc["type"] == "ageRatingDeclarations":
        print(f"\n## AgeRatingDeclaration {inc['id']}")
        for k,v in inc["attributes"].items():
            print(f"   {k}: {v}")

# Pricing
price = api(f"/v1/apps/{APP}/appPricePoints?limit=1")
print(f"\n## Pricing: {('set' if price.get('data') else '✗ not configured (will need base price + availability)')}")
