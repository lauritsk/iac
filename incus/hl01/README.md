# hl01

Set the provisioning variables:

```bash
set -euo pipefail

FLATCAR_VERSION=4593.2.5
FLATCAR_IMAGE=flatcar_production_qemu_uefi_secure_image.img
FLATCAR_CERT=flatcar-sb-dev-shim-2025.cert
FLATCAR_WORKDIR="${XDG_CACHE_HOME:-$HOME/.cache}/homelab-iac/flatcar/$FLATCAR_VERSION"

mkdir -p "$FLATCAR_WORKDIR"
```

Generate the Ignition configuration:

```bash
mise run ignition:generate
python3 -m json.tool config.ign >/dev/null
```

Check the required Incus resources:

```bash
incus storage show hv01:local
incus storage volume show hv01:fast fast
incus storage volume show hv01:slow slow
incus network show hv01:incusbr0
```

Import the Flatcar image if it is not already present:

```bash
if ! incus image info "hv01:flatcar-$FLATCAR_VERSION" >/dev/null 2>&1; then
  curl -fsSL --retry 3 \
    -o "$FLATCAR_WORKDIR/$FLATCAR_IMAGE" \
    "https://stable.release.flatcar-linux.net/amd64-usr/$FLATCAR_VERSION/$FLATCAR_IMAGE"

  printf '%s  %s\n' \
    ecc1a70ad9022663e6122977b289295167729e63f1694a830f9fd776537fdc54a05eed2c93f951b0ac6facfefe0d6cb78d9f037f420b527d5e263b1a3af22a78 \
    "$FLATCAR_WORKDIR/$FLATCAR_IMAGE" |
    shasum -a 512 -c

  cat > "$FLATCAR_WORKDIR/metadata.yaml" <<EOF
architecture: x86_64
creation_date: $(date +%s)
properties:
  description: Flatcar Container Linux $FLATCAR_VERSION
  os: Flatcar
  release: $FLATCAR_VERSION
  requirements.secureboot: "true"
EOF

  COPYFILE_DISABLE=1 tar --format=ustar \
    -cf "$FLATCAR_WORKDIR/metadata.tar" \
    -C "$FLATCAR_WORKDIR" \
    metadata.yaml

  incus image import \
    "$FLATCAR_WORKDIR/metadata.tar" \
    "$FLATCAR_WORKDIR/$FLATCAR_IMAGE" \
    hv01: \
    --alias "flatcar-$FLATCAR_VERSION"
fi
```

Download the Flatcar Secure Boot certificate:

```bash
curl -fsSL --retry 3 \
  -o "$FLATCAR_WORKDIR/$FLATCAR_CERT" \
  "https://raw.githubusercontent.com/flatcar/scripts/stable-$FLATCAR_VERSION/build_library/$FLATCAR_CERT"
```

Create the VM with the Ignition configuration:

```bash
RAW_QEMU=$(python3 -c '
import json
import shlex
with open("config.ign") as source:
    ignition = json.dumps(json.load(source), separators=(",", ":"))
value = "name=opt/org.flatcar-linux/config,string=" + ignition.replace(",", ",,")
print("-fw_cfg " + shlex.quote(value))
')

incus init \
  "hv01:flatcar-$FLATCAR_VERSION" \
  hv01:hl01 \
  --vm \
  --config "raw.qemu=$RAW_QEMU" \
  < incus/hl01/config.yml
```

Enroll the Flatcar Secure Boot certificate:

```bash
DB_JSON="$FLATCAR_WORKDIR/secure-boot-db.json"

incus low-level nvram get \
  hv01:hl01 \
  EFI_IMAGE_SECURITY_DATABASE_GUID:db \
  --format=json \
  > "$DB_JSON"

CERT_PATH="$FLATCAR_WORKDIR/$FLATCAR_CERT" DB_PATH="$DB_JSON" python3 <<'PY'
import base64
import json
import os

with open(os.environ["CERT_PATH"]) as source:
    pem = "".join(line.strip() for line in source if not line.startswith("-----"))

with open(os.environ["DB_PATH"]) as source:
    db = json.load(source)

data = base64.b64encode(base64.b64decode(pem)).decode()
entries = [entry for node in db["data"] for entry in node["entries"]]
if not any(entry["data"] == data for entry in entries):
    db["data"].append({
        "type": "x509",
        "entries": [{
            "owner": "a0baa8a3-041d-48a8-bc87-c36d121b5e3d",
            "data": data,
        }],
    })

db.pop("binary", None)
with open(os.environ["DB_PATH"], "w") as destination:
    json.dump(db, destination)
PY

incus low-level nvram set \
  hv01:hl01 \
  EFI_IMAGE_SECURITY_DATABASE_GUID:db=- \
  --format=json \
  < "$DB_JSON"
```

Start the VM:

```bash
incus start hv01:hl01
incus wait hv01:hl01 ipv4 --timeout=180
```

Check its state and console:

```bash
incus list hv01:hl01
incus console hv01:hl01
```
