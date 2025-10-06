#!/bin/bash
#
# Validate MCP Extensions using JSON Schema
#
# This script validates that MCP extensions in an OpenAPI spec conform
# to the MCP extensions JSON Schema.
#
# Usage: ./validate-mcp-schema.sh <openapi-file>
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

OPENAPI_FILE="${1:-api/openapi.yaml}"
SCHEMA_FILE="schemas/mcp-extensions-schema.json"

echo "=========================================="
echo "MCP Extensions JSON Schema Validator"
echo "=========================================="
echo

# Check if OpenAPI file exists
if [[ ! -f "$OPENAPI_FILE" ]]; then
    echo -e "${RED}✗ OpenAPI file not found: $OPENAPI_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} OpenAPI file found: $OPENAPI_FILE"

# Check if schema file exists
if [[ ! -f "$SCHEMA_FILE" ]]; then
    echo -e "${RED}✗ Schema file not found: $SCHEMA_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Schema file found: $SCHEMA_FILE"
echo

# Check if yq is available (for YAML to JSON conversion)
if ! command -v yq &> /dev/null; then
    echo -e "${YELLOW}⚠ yq not found. Install with: brew install yq${NC}"
    echo -e "${YELLOW}  Skipping JSON Schema validation${NC}"
    echo -e "${YELLOW}  Using basic validation instead...${NC}"
    echo

    # Fall back to basic validation
    exec ./validate-mcp-extensions.sh "$OPENAPI_FILE"
fi

echo -e "${GREEN}✓${NC} yq found"

# Check if ajv-cli is available (for JSON Schema validation)
if ! command -v ajv &> /dev/null; then
    echo -e "${YELLOW}⚠ ajv-cli not found. Install with: npm install -g ajv-cli${NC}"
    echo -e "${YELLOW}  Skipping JSON Schema validation${NC}"
    echo -e "${YELLOW}  Using basic validation instead...${NC}"
    echo

    # Fall back to basic validation
    exec ./validate-mcp-extensions.sh "$OPENAPI_FILE"
fi

echo -e "${GREEN}✓${NC} ajv-cli found"
echo

# Convert YAML to JSON
echo "Converting YAML to JSON..."
TEMP_JSON=$(mktemp)
yq eval -o=json "$OPENAPI_FILE" > "$TEMP_JSON"
echo -e "${GREEN}✓${NC} Conversion complete"
echo

# Validate against schema
echo "Validating MCP extensions..."
if ajv validate -s "$SCHEMA_FILE" -d "$TEMP_JSON" --spec=draft7 2>&1; then
    echo
    echo -e "${GREEN}✓ MCP extensions are valid!${NC}"
    VALIDATION_RESULT=0
else
    echo
    echo -e "${RED}✗ MCP extensions validation failed${NC}"
    VALIDATION_RESULT=1
fi

# Cleanup
rm -f "$TEMP_JSON"

echo
echo "=========================================="
echo "Validation Summary"
echo "=========================================="
echo

if [[ $VALIDATION_RESULT -eq 0 ]]; then
    echo -e "${GREEN}Status: PASS${NC}"
    echo "All MCP extensions conform to the schema"
else
    echo -e "${RED}Status: FAIL${NC}"
    echo "Some MCP extensions do not conform to the schema"
    echo
    echo "Common issues:"
    echo "  - Missing required fields (name, version)"
    echo "  - Invalid format (e.g., version not semver)"
    echo "  - Unknown properties"
    echo "  - Invalid values (e.g., priority out of range)"
fi

echo

exit $VALIDATION_RESULT
