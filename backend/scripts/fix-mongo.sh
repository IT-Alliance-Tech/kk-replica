#!/usr/bin/env bash
# Safe automation to diagnose Atlas SRV issue and optionally replace MONGO_URI with a standard connection string.
# Usage:
#   ./scripts/fix-mongo.sh           -> runs DNS + test using .env MONGO_URI
#   STANDARD_URI="mongodb://host1:27017,.../db?replicaSet=..." ./scripts/fix-mongo.sh
#
# If STANDARD_URI environment variable is provided, script will back up .env and replace MONGO_URI with STANDARD_URI (non-destructive).
#
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$DIR/.env"
BACKUP_ENV="$DIR/.env.backup.$(date +%s)"

echo "Working dir: $DIR"
echo

# 1) SRV DNS check
CLUSTER_HOST="kk-api.h89wter.mongodb.net"
echo "==> 1) SRV DNS check for _mongodb._tcp.$CLUSTER_HOST"
if command -v nslookup >/dev/null 2>&1; then
  nslookup -type=SRV "_mongodb._tcp.$CLUSTER_HOST" || true
else
  echo "nslookup not found; trying dig..."
  if command -v dig >/dev/null 2>&1; then
    dig SRV "_mongodb._tcp.$CLUSTER_HOST" +short || true
  else
    echo "Neither nslookup nor dig available. Skipping SRV check."
  fi
fi
echo

# 2) Ensure we have a MONGO_URI (from .env or env)
if [ -f "$ENV_FILE" ]; then
  echo "Found $ENV_FILE. Showing MONGO_URI line (password hidden):"
  grep -i '^MONGO_URI=' "$ENV_FILE" || true
else
  echo "No .env file found at $ENV_FILE"
fi
echo

# 3) run test-mongo.js using MONGO_URI from .env if present, else environment
echo "==> 2) Running test-mongo.js with current MONGO_URI (reads process.env.MONGO_URI)"
# If .env exists, export variables from it temporarily for the test
if [ -f "$ENV_FILE" ]; then
  # load .env into environment in a safe way (ignore lines without equals)
  export $(grep -v '^#' "$ENV_FILE" | xargs) || true
fi

node "$DIR/test-mongo.js" || TEST_EXIT=$? && true
TEST_EXIT=${TEST_EXIT:-$?}
if [ "$TEST_EXIT" -eq 0 ]; then
  echo "✅ test-mongo succeeded with current MONGO_URI. No change needed."
  exit 0
else
  echo "❗ test-mongo failed. Exit code: $TEST_EXIT"
fi
echo

# 4) If STANDARD_URI provided, back up .env and replace.
if [ -n "${STANDARD_URI:-}" ]; then
  echo "==> 3) STANDARD_URI provided, will attempt non-SRV standard connection string fallback."
  if [ -f "$ENV_FILE" ]; then
    echo "Backing up $ENV_FILE -> $BACKUP_ENV"
    cp "$ENV_FILE" "$BACKUP_ENV"
  else
    echo "No .env found; creating a new one at $ENV_FILE (backup skipped)."
  fi

  # Replace or add MONGO_URI line safely
  if grep -qi '^MONGO_URI=' "$ENV_FILE" 2>/dev/null; then
    perl -0777 -pe "s/^MONGO_URI=.*$/MONGO_URI=$STANDARD_URI/mis" -i "$ENV_FILE"
  else
    echo "MONGO_URI=$STANDARD_URI" >> "$ENV_FILE"
  fi

  echo "Wrote standard connection string into $ENV_FILE (password should be URL-encoded)."
  echo "Now re-running test-mongo.js..."
  # reload env
  export $(grep -v '^#' "$ENV_FILE" | xargs) || true
  node "$DIR/test-mongo.js" || true
  echo
  echo "If this fails, try connecting from a different network (phone hotspot) or URL-encode password."
  exit 0
else
  echo "No STANDARD_URI provided. To attempt automatic fix, re-run with STANDARD_URI set to the standard (non-SRV) connection string from Atlas."
  echo "Example (replace with actual standard connection string):"
  echo "  STANDARD_URI=\"mongodb://host1:27017,host2:27017,host3:27017/kitchen_kettles?replicaSet=atlas-xxxxx-shard-0&authSource=admin&ssl=true\" ./scripts/fix-mongo.sh"
  exit 2
fi
