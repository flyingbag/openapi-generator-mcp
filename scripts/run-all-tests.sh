#!/bin/bash
#
# Run All Tests - OpenAPI to MCP Generator
#
# Comprehensive test suite that runs all validation and generation tests
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Navigate to project root
cd "$(dirname "$0")/.."

echo "=============================================="
echo "  OpenAPI to MCP Generator - Test Suite"
echo "=============================================="
echo
echo "Date: $(date)"
echo "Version: 1.0.0"
echo
echo "=============================================="
echo

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local is_optional="${3:-false}"

    ((TOTAL_TESTS++))
    echo -e "${BLUE}[Test $TOTAL_TESTS]${NC} $test_name"
    echo "Command: $test_command"
    echo

    if eval "$test_command" 2>&1 | tee /tmp/test_output_$TOTAL_TESTS.log; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((PASSED_TESTS++))
    else
        if [ "$is_optional" = "true" ]; then
            echo -e "${YELLOW}⊘ SKIPPED (optional)${NC}"
            ((SKIPPED_TESTS++))
        else
            echo -e "${RED}✗ FAIL${NC}"
            ((FAILED_TESTS++))
        fi
    fi
    echo
    echo "----------------------------------------------"
    echo
}

# Test 1: Validate OpenAPI Spec
run_test "Validate OpenAPI Specification" \
    "./validate-mcp-extensions.sh api/openapi.yaml"

# Test 2: Validate MCP Extensions with JSON Schema
run_test "Validate MCP Extensions (JSON Schema)" \
    "./scripts/validate-mcp-schema.sh api/openapi.yaml" \
    "true"

# Test 3: Test Templates
run_test "Test Template Files" \
    "./test-templates.sh"

# Test 4: Generate C# Code
run_test "Generate C# MCP Server" \
    "./generate-mcp-all.sh --languages=csharp"

# Test 5: Generate Python Code
run_test "Generate Python MCP Server" \
    "./generate-mcp-all.sh --languages=python"

# Test 6: Generate TypeScript Code
run_test "Generate TypeScript MCP Server" \
    "./generate-mcp-all.sh --languages=typescript"

# Test 7: Verify Generated Files Exist
run_test "Verify Generated Files" \
    "test -f ../generated/python-mcp/petstore_mcp/api/pet_api.py && \
     test -f ../generated/typescript-mcp/api/petApi.ts"

# Test 8: Python Syntax Check
run_test "Python Syntax Validation" \
    "python3 -m py_compile ../generated/python-mcp/petstore_mcp/api/*.py" \
    "true"

# Test 9: TypeScript Type Check
run_test "TypeScript Type Validation" \
    "cd examples && npx tsc ../generated/typescript-mcp/api/*.ts --noEmit --skipLibCheck" \
    "true"

# Test 10: Check Python Example Syntax
run_test "Python Example Syntax" \
    "python3 -m py_compile examples/python-mcp-example.py" \
    "true"

echo
echo "=============================================="
echo "  Test Summary"
echo "=============================================="
echo
echo -e "Total Tests:   ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Passed:        ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed:        ${RED}$FAILED_TESTS${NC}"
echo -e "Skipped:       ${YELLOW}$SKIPPED_TESTS${NC}"
echo

# Calculate percentage
if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo -e "Success Rate:  ${GREEN}$SUCCESS_RATE%${NC}"
fi

echo
echo "=============================================="
echo

# Final result
if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✅ ALL TESTS PASSED!${NC}"
    echo
    echo "The OpenAPI to MCP Generator is working correctly."
    echo "You can proceed to manual testing with MCP Inspector."
    EXIT_CODE=0
else
    echo -e "${RED}❌ SOME TESTS FAILED!${NC}"
    echo
    echo "Please review the failed tests above and fix the issues."
    echo "Log files are in /tmp/test_output_*.log"
    EXIT_CODE=1
fi

echo
echo "Next steps:"
if [ $FAILED_TESTS -eq 0 ]; then
    echo "  1. Test with MCP Inspector:"
    echo "     npx @modelcontextprotocol/inspector python examples/python-mcp-example.py"
    echo
    echo "  2. Test live API calls with real Petstore API"
    echo
    echo "  3. Review TEST_RESULTS.md for full test documentation"
else
    echo "  1. Review failed test logs in /tmp/"
    echo "  2. Fix issues and re-run: ./scripts/run-all-tests.sh"
    echo "  3. Check TESTING.md for troubleshooting"
fi

echo
echo "=============================================="
echo

exit $EXIT_CODE
