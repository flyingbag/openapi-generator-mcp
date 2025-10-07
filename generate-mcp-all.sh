#!/usr/bin/env bash

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Default languages
DEFAULT_LANGUAGES="csharp,python,typescript,go"

# Parse arguments
LANGUAGES="${1:-$DEFAULT_LANGUAGES}"
DRY_RUN=false
SKIP_POST_PROCESS=false

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        --languages=*)
            LANGUAGES="${1#*=}"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --skip-post-process)
            SKIP_POST_PROCESS=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --languages=LANGS    Comma-separated list of languages (default: csharp,python,typescript)"
            echo "                       Available: csharp, python, typescript, go"
            echo "  --dry-run           Show what would be generated without generating"
            echo "  --skip-post-process Skip post-processing steps"
            echo "  --help              Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Generate C# and Python"
            echo "  $0 --languages=python                 # Generate Python only"
            echo "  $0 --languages=csharp,python,typescript  # Generate all three"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# Convert comma-separated list to array
IFS=',' read -ra LANG_ARRAY <<< "$LANGUAGES"

echo -e "${GREEN}=== MCP Multi-Language Code Generator ===${NC}"
echo "Languages: ${LANG_ARRAY[*]}"
echo ""

# Function to generate for a specific language
generate_language() {
    local lang=$1
    local config_file="config/mcp-${lang}.json"

    if [ ! -f "$config_file" ]; then
        echo -e "${RED}Error: Configuration file not found: $config_file${NC}"
        return 1
    fi

    echo -e "${YELLOW}Generating $lang MCP tools...${NC}"

    if [ "$DRY_RUN" = true ]; then
        echo "  Would run: openapi-generator-cli generate -c $config_file"
        return 0
    fi

    # Run OpenAPI Generator
    openapi-generator-cli generate \
        -c "$config_file" \
        --global-property apis,apiDocs=false,modelDocs=false \
        || {
            echo -e "${RED}Error generating $lang code${NC}"
            return 1
        }

    echo -e "${GREEN}✓ $lang generation complete${NC}"
    return 0
}

# Function to run post-processing
post_process_language() {
    local lang=$1

    if [ "$SKIP_POST_PROCESS" = true ]; then
        return 0
    fi

    case $lang in
        csharp)
            # C# post-processing (if needed in future)
            echo -e "${YELLOW}No post-processing needed for C#${NC}"
            ;;
        python)
            # Python post-processing (if needed in future)
            echo -e "${YELLOW}No post-processing needed for Python${NC}"
            ;;
        typescript)
            # TypeScript post-processing (if needed in future)
            echo -e "${YELLOW}No post-processing needed for TypeScript${NC}"
            ;;
        go)
            # Go post-processing (if needed in future)
            echo -e "${YELLOW}No post-processing needed for Go${NC}"
            ;;
    esac
}

# Track success/failure
SUCCESS_COUNT=0
FAILURE_COUNT=0
FAILED_LANGUAGES=()

# Generate for each language
for lang in "${LANG_ARRAY[@]}"; do
    lang=$(echo "$lang" | tr '[:upper:]' '[:lower:]' | xargs) # Trim and lowercase

    if generate_language "$lang"; then
        post_process_language "$lang"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        FAILED_LANGUAGES+=("$lang")
    fi
    echo ""
done

# Summary
echo -e "${GREEN}=== Generation Summary ===${NC}"
echo "Successful: $SUCCESS_COUNT"
echo "Failed: $FAILURE_COUNT"

if [ $FAILURE_COUNT -gt 0 ]; then
    echo -e "${RED}Failed languages: ${FAILED_LANGUAGES[*]}${NC}"
    exit 1
fi

echo -e "${GREEN}All MCP code generation completed successfully!${NC}"

# Display output locations
echo ""
echo -e "${GREEN}=== Generated Code Locations ===${NC}"
for lang in "${LANG_ARRAY[@]}"; do
    lang=$(echo "$lang" | tr '[:upper:]' '[:lower:]' | xargs)
    case $lang in
        csharp)
            echo "  C#: ../generated/csharp-mcp/"
            ;;
        python)
            echo "  Python: ../generated/python-mcp/"
            ;;
        typescript)
            echo "  TypeScript: ../generated/typescript-mcp/"
            ;;
        go)
            echo "  Go: ../generated/go-mcp/"
            ;;
    esac
done

echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "  1. Review generated code"
echo "  2. Implement concrete tool classes"
echo "  3. Test MCP server integration"
echo "  4. Update documentation"
