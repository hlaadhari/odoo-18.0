#!/usr/bin/env bash
set -euo pipefail

#
# Deploys or updates an Odoo addon inside a Docker container and updates the module in a target database.
#
# Usage:
#   ./scripts/deploy_addon.sh \
#     --addon ./custom_addons/steg_stock_management \
#     --container odoo18 \
#     --module steg_stock_management \
#     --db steg_db \
#     [--target /var/lib/odoo/custom_addons] [--odoo-bin odoo-bin] [--config /etc/odoo/odoo.conf] [--copy-only]
#

ADDON=""
CONTAINER=""
TARGET="/var/lib/odoo/custom_addons"
MODULE=""
DB=""
ODOOBIN="odoo-bin"
CONFIG="/etc/odoo/odoo.conf"
COPY_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --addon) ADDON="$2"; shift 2;;
    --container) CONTAINER="$2"; shift 2;;
    --target) TARGET="$2"; shift 2;;
    --module) MODULE="$2"; shift 2;;
    --db) DB="$2"; shift 2;;
    --odoo-bin) ODOOBIN="$2"; shift 2;;
    --config) CONFIG="$2"; shift 2;;
    --copy-only) COPY_ONLY=1; shift 1;;
    -h|--help)
      grep '^#' "$0" | sed -e 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "Unknown arg: $1"; exit 1;;
  esac
done

if [[ -z "$ADDON" || -z "$CONTAINER" || -z "$MODULE" || -z "$DB" ]]; then
  echo "Missing required arguments. Run with --help"
  exit 1
fi

if [[ ! -d "$ADDON" ]]; then
  echo "Addon path not found: $ADDON"; exit 1
fi

ADDON_NAME=$(basename "$(realpath "$ADDON")")
echo "[+] Addon: $ADDON_NAME"
echo "[+] Container: $CONTAINER"
echo "[+] Target (in container): $TARGET"

echo "[+] Ensuring target directory exists in container..."
docker exec "$CONTAINER" bash -lc "mkdir -p '$TARGET'"

echo "[+] Copying addon into container (temp)..."
TEMP_DEST="$TARGET/.tmp_${ADDON_NAME}"
docker exec "$CONTAINER" bash -lc "rm -rf '$TEMP_DEST' && mkdir -p '$TEMP_DEST'"
docker cp "$ADDON/." "$CONTAINER:$TEMP_DEST/"

echo "[+] Swapping temp into place..."
docker exec "$CONTAINER" bash -lc "rm -rf '$TARGET/$ADDON_NAME' && mv '$TEMP_DEST' '$TARGET/$ADDON_NAME' && find '$TARGET/$ADDON_NAME' -type d -exec chmod 755 {} \; && find '$TARGET/$ADDON_NAME' -type f -exec chmod 644 {} \;"

if [[ "$COPY_ONLY" -eq 1 ]]; then
  echo "[+] Copy-only mode, skipping update."
  exit 0
fi

echo "[+] Running module update in container..."
CFG_ARG=""
if [[ -n "$CONFIG" ]]; then CFG_ARG="-c '$CONFIG'"; fi
docker exec "$CONTAINER" bash -lc "$ODOOBIN $CFG_ARG -d '$DB' -u '$MODULE' --stop-after-init"

echo "[✓] Deployment complete for module '$MODULE' on database '$DB'."



