#!/usr/bin/env bash

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Default OpenAPI spec file
SPEC_FILE="${1:-api/openapi.yaml}"

if [ ! -f "$SPEC_FILE" ]; then
    echo -e "${RED}Error: OpenAPI spec file not found: $SPEC_FILE${NC}"
    exit 1
fi

echo -e "${BLUE}=== MCP Extension Validator ===${NC}"
echo "Validating: $SPEC_FILE"
echo ""

# Validation counters
WARNINGS=0
ERRORS=0
INFO=0

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo -e "${YELLOW}Warning: yq not installed. Installing...${NC}"
    echo "Install with: brew install yq (macOS) or see https://github.com/mikefarah/yq"
    echo ""
    echo "Skipping detailed validation. Basic checks only."
    echo ""

    # Basic validation without yq
    echo -e "${BLUE}=== Basic Validation ===${NC}"

    # Check if file is valid YAML
    if command -v python3 &> /dev/null; then
        if python3 -c "import yaml; yaml.safe_load(open('$SPEC_FILE'))" 2>/dev/null; then
            echo -e "${GREEN}✓ Valid YAML syntax${NC}"
        else
            echo -e "${RED}✗ Invalid YAML syntax${NC}"
            ((ERRORS++))
        fi
    else
        echo -e "${YELLOW}⚠ python3 not found, skipping YAML syntax check${NC}"
        ((INFO++))
    fi

    # Check for MCP extensions
    if grep -q "x-mcp-" "$SPEC_FILE"; then
        echo -e "${GREEN}✓ Contains MCP extensions${NC}"
        ((INFO++))
    else
        echo -e "${YELLOW}⚠ No MCP extensions found${NC}"
        ((WARNINGS++))
    fi

else
    # Full validation with yq
    echo -e "${BLUE}=== Validating OpenAPI Structure ===${NC}"

    # Check OpenAPI version
    OPENAPI_VERSION=$(yq eval '.openapi' "$SPEC_FILE")
    if [[ "$OPENAPI_VERSION" == "3."* ]]; then
        echo -e "${GREEN}✓ OpenAPI version: $OPENAPI_VERSION${NC}"
    else
        echo -e "${RED}✗ Invalid OpenAPI version: $OPENAPI_VERSION${NC}"
        ((ERRORS++))
    fi

    # Check info section
    if yq eval '.info' "$SPEC_FILE" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Info section present${NC}"
    else
        echo -e "${RED}✗ Info section missing${NC}"
        ((ERRORS++))
    fi

    echo ""
    echo -e "${BLUE}=== Validating MCP Extensions ===${NC}"

    # Check for x-mcp-server extension
    if yq eval '.info.x-mcp-server' "$SPEC_FILE" | grep -qv "null"; then
        echo -e "${GREEN}✓ x-mcp-server extension found${NC}"

        # Validate required fields
        SERVER_NAME=$(yq eval '.info.x-mcp-server.name' "$SPEC_FILE")
        if [ "$SERVER_NAME" != "null" ]; then
            echo -e "  ${GREEN}✓ Server name: $SERVER_NAME${NC}"
        else
            echo -e "  ${YELLOW}⚠ Server name not specified${NC}"
            ((WARNINGS++))
        fi

        SERVER_VERSION=$(yq eval '.info.x-mcp-server.version' "$SPEC_FILE")
        if [ "$SERVER_VERSION" != "null" ]; then
            echo -e "  ${GREEN}✓ Server version: $SERVER_VERSION${NC}"
        else
            echo -e "  ${YELLOW}⚠ Server version not specified${NC}"
            ((WARNINGS++))
        fi
    else
        echo -e "${YELLOW}⚠ x-mcp-server extension not found (optional)${NC}"
        ((INFO++))
    fi

    # Check for x-mcp-tool extensions in operations
    TOOL_COUNT=$(yq eval '[.paths[][] | select(has("x-mcp-tool"))] | length' "$SPEC_FILE" 2>/dev/null || echo "0")

    if [ "$TOOL_COUNT" == "null" ]; then
        TOOL_COUNT=0
    fi

    if [ $TOOL_COUNT -gt 0 ]; then
        echo -e "${GREEN}✓ Found $TOOL_COUNT operations with MCP tool extensions${NC}"
    else
        echo -e "${YELLOW}⚠ No x-mcp-tool extensions found${NC}"
        echo -e "  ${BLUE}ℹ This is optional but recommended for MCP generation${NC}"
        ((INFO++))
    fi

    # Check for x-mcp-category in tags
    TAG_COUNT=$(yq eval '[.tags[] | select(has("x-mcp-category"))] | length' "$SPEC_FILE" 2>/dev/null || echo "0")

    if [ "$TAG_COUNT" == "null" ]; then
        TAG_COUNT=0
    fi

    if [ $TAG_COUNT -gt 0 ]; then
        echo -e "${GREEN}✓ Found $TAG_COUNT tags with x-mcp-category extensions${NC}"
    else
        TOTAL_TAGS=$(yq eval '.tags | length' "$SPEC_FILE" 2>/dev/null || echo "0")
        if [ "$TOTAL_TAGS" != "0" ] && [ "$TOTAL_TAGS" != "null" ]; then
            echo -e "${YELLOW}⚠ No tags have x-mcp-category extensions${NC}"
            ((INFO++))
        fi
    fi
fi

echo ""
echo -e "${BLUE}=== Validation Summary ===${NC}"
echo -e "Errors:   ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo -e "Info:     ${BLUE}$INFO${NC}"

echo ""
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ Validation failed with $ERRORS error(s)${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Validation completed with $WARNINGS warning(s)${NC}"
    echo -e "${YELLOW}Consider adding MCP extensions for better code generation${NC}"
    exit 0
else
    echo -e "${GREEN}✅ Validation passed!${NC}"
    exit 0
fi
