#!/usr/bin/env bash
# Admin Dashboard CI/Fix Script
# This script ensures the frontend builds correctly with automated fixes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Navigate to kk-frontend directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRONTEND_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$FRONTEND_DIR"

echo "========================================"
echo "EDemo Admin - Build Check & Fix"
echo "========================================"
echo ""

# Initialize report
REPORT_FILE="$FRONTEND_DIR/tools/admin-ci-report.json"
mkdir -p "$(dirname "$REPORT_FILE")"

FORMATTED=false
ESLINT_FIXED=false
TYPE_CHECK_PASS=false
BUILD_PASS=false
ERRORS=()

# Function to add error to array
add_error() {
    ERRORS+=("$1")
}

# Step 1: Check and install dependencies
echo -e "${YELLOW}[1/6] Checking dependencies...${NC}"
if [ ! -d "node_modules" ] || [ "package-lock.json" -nt "node_modules" ]; then
    echo "Installing dependencies..."
    if npm ci 2>/dev/null || npm install; then
        echo -e "${GREEN}✓ Dependencies installed${NC}"
    else
        echo -e "${RED}✗ Failed to install dependencies${NC}"
        add_error "npm install failed"
    fi
else
    echo -e "${GREEN}✓ Dependencies up to date${NC}"
fi
echo ""

# Step 2: Run Prettier
echo -e "${YELLOW}[2/6] Running Prettier...${NC}"
if command -v npx &> /dev/null; then
    if npx prettier --write . --log-level warn 2>&1 | tee /tmp/prettier.log; then
        FORMATTED=true
        echo -e "${GREEN}✓ Code formatted${NC}"
    else
        echo -e "${YELLOW}⚠ Prettier completed with warnings${NC}"
        FORMATTED=true
    fi
else
    echo -e "${YELLOW}⚠ Prettier not available, skipping${NC}"
fi
echo ""

# Step 3: Run ESLint with --fix
echo -e "${YELLOW}[3/6] Running ESLint...${NC}"
ESLINT_OUTPUT=$(npx eslint . --ext .js,.jsx,.ts,.tsx --fix 2>&1 || true)
ESLINT_EXIT_CODE=$?
echo "$ESLINT_OUTPUT" > /tmp/eslint.log

if [ $ESLINT_EXIT_CODE -eq 0 ]; then
    ESLINT_FIXED=true
    echo -e "${GREEN}✓ ESLint passed${NC}"
else
    echo -e "${YELLOW}⚠ ESLint found issues (attempted auto-fix)${NC}"
    # Get first 5 error lines
    ERROR_LINES=$(echo "$ESLINT_OUTPUT" | grep -E "error|warning" | head -n 5)
    if [ ! -z "$ERROR_LINES" ]; then
        while IFS= read -r line; do
            add_error "$line"
        done <<< "$ERROR_LINES"
    fi
    ESLINT_FIXED=false
fi
echo ""

# Step 4: Run TypeScript type checking
echo -e "${YELLOW}[4/6] Running TypeScript type check...${NC}"
TSC_OUTPUT=$(npx tsc --noEmit 2>&1 || true)
TSC_EXIT_CODE=$?
echo "$TSC_OUTPUT" > /tmp/tsc.log

if [ $TSC_EXIT_CODE -eq 0 ]; then
    TYPE_CHECK_PASS=true
    echo -e "${GREEN}✓ Type check passed${NC}"
else
    echo -e "${RED}✗ Type check failed${NC}"
    TYPE_CHECK_PASS=false
    # Get first 10 error lines
    ERROR_LINES=$(echo "$TSC_OUTPUT" | grep "error TS" | head -n 10)
    if [ ! -z "$ERROR_LINES" ]; then
        while IFS= read -r line; do
            add_error "$line"
        done <<< "$ERROR_LINES"
    fi
fi
echo ""

# Step 5: First build attempt
echo -e "${YELLOW}[5/6] Running build (attempt 1)...${NC}"
BUILD_OUTPUT=$(npm run build 2>&1 || true)
BUILD_EXIT_CODE=$?
echo "$BUILD_OUTPUT" > /tmp/build1.log

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    BUILD_PASS=true
    echo -e "${GREEN}✓ Build successful${NC}"
else
    echo -e "${RED}✗ Build failed on first attempt${NC}"
    
    # Step 6: Retry with fixes
    echo ""
    echo -e "${YELLOW}[6/6] Retrying with additional fixes...${NC}"
    
    # Run eslint --fix again
    npx eslint . --ext .js,.jsx,.ts,.tsx --fix 2>&1 || true
    
    # Run prettier again
    npx prettier --write . --log-level warn 2>&1 || true
    
    # Retry build
    echo "Retrying build..."
    BUILD_OUTPUT=$(npm run build 2>&1 || true)
    BUILD_EXIT_CODE=$?
    echo "$BUILD_OUTPUT" > /tmp/build2.log
    
    if [ $BUILD_EXIT_CODE -eq 0 ]; then
        BUILD_PASS=true
        echo -e "${GREEN}✓ Build successful on retry${NC}"
    else
        BUILD_PASS=false
        echo -e "${RED}✗ Build failed on retry${NC}"
        
        # Capture build errors
        ERROR_LINES=$(echo "$BUILD_OUTPUT" | grep -E "Error|error|ERROR|Failed" | head -n 10)
        if [ ! -z "$ERROR_LINES" ]; then
            while IFS= read -r line; do
                add_error "$line"
            done <<< "$ERROR_LINES"
        fi
    fi
fi
echo ""

# Generate report
echo "========================================"
echo "Generating report..."
echo "========================================"

# Convert errors array to JSON array
ERRORS_JSON="["
FIRST=true
for error in "${ERRORS[@]}"; do
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        ERRORS_JSON+=","
    fi
    # Escape quotes and newlines
    ESCAPED_ERROR=$(echo "$error" | sed 's/"/\\"/g' | tr -d '\n')
    ERRORS_JSON+="\"$ESCAPED_ERROR\""
done
ERRORS_JSON+="]"

# Write JSON report
cat > "$REPORT_FILE" <<EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "formatted": $FORMATTED,
  "eslintFixed": $ESLINT_FIXED,
  "typeCheckPass": $TYPE_CHECK_PASS,
  "buildPass": $BUILD_PASS,
  "errors": $ERRORS_JSON,
  "summary": "Build $([ "$BUILD_PASS" = true ] && echo "passed" || echo "failed"). Type check $([ "$TYPE_CHECK_PASS" = true ] && echo "passed" || echo "failed")."
}
EOF

echo -e "${GREEN}✓ Report written to $REPORT_FILE${NC}"
echo ""

# Print summary
echo "========================================"
echo "Summary"
echo "========================================"
echo -e "Formatted:       $([ "$FORMATTED" = true ] && echo "${GREEN}✓${NC}" || echo "${RED}✗${NC}")"
echo -e "ESLint Fixed:    $([ "$ESLINT_FIXED" = true ] && echo "${GREEN}✓${NC}" || echo "${YELLOW}⚠${NC}")"
echo -e "Type Check:      $([ "$TYPE_CHECK_PASS" = true ] && echo "${GREEN}✓${NC}" || echo "${RED}✗${NC}")"
echo -e "Build:           $([ "$BUILD_PASS" = true ] && echo "${GREEN}✓${NC}" || echo "${RED}✗${NC}")"
echo "========================================"
echo ""

# Exit with appropriate code
if [ "$BUILD_PASS" = true ]; then
    echo -e "${GREEN}All checks passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}Build failed. See report for details.${NC}"
    echo "Report: $REPORT_FILE"
    echo ""
    echo "Common issues:"
    echo "  - Missing dependencies: Check package.json"
    echo "  - TypeScript errors: Review errors in tools/admin-ci-report.json"
    echo "  - Import path issues: Verify relative paths in new admin files"
    exit 1
fi
