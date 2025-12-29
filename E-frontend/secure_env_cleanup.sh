#!/bin/bash
# Usage: chmod +x secure_env_cleanup.sh && ./secure_env_cleanup.sh

set -e

FOLDER="kk-frontend"
cd "$(dirname "$0")"

GITIGNORE_UPDATED=false
UNTRACKED_ENV=false
COMMIT_MADE=false

# Required patterns
PATTERNS=(".env" ".env.local" ".env.*.local" "**/.env")

# Ensure .gitignore exists
touch .gitignore

# Add patterns if missing
for pattern in "${PATTERNS[@]}"; do
    if ! grep -qxF "$pattern" .gitignore 2>/dev/null; then
        echo "$pattern" >> .gitignore
        GITIGNORE_UPDATED=true
    fi
done

# Untrack .env if tracked
if [ -f ".env" ]; then
    if git ls-files --error-unmatch .env >/dev/null 2>&1; then
        git rm --cached .env >/dev/null 2>&1 || true
        UNTRACKED_ENV=true
    fi
fi

# Stage .gitignore
git add .gitignore 2>/dev/null || true

# Commit if changes exist
if ! git diff --cached --quiet 2>/dev/null || [ "$UNTRACKED_ENV" = true ]; then
    git commit -m "chore: untrack & ignore .env in $FOLDER" >/dev/null 2>&1 || true
    COMMIT_MADE=true
fi

# Print JSON summary
echo "{\"folder\":\"$FOLDER\",\"gitignoreUpdated\":$GITIGNORE_UPDATED,\"untrackedEnv\":$UNTRACKED_ENV,\"commitMade\":$COMMIT_MADE}"
