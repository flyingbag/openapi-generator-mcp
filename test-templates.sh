#!/usr/bin/env bash

set -e -o pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}=== MCP Template Testing Framework ===${NC}"
echo ""

# Test configuration
TEST_OUTPUT_DIR="./test-output"
TEST_SPEC="api/openapi.yaml"

# Clean previous test output
if [ -d "$TEST_OUTPUT_DIR" ]; then
    echo -e "${YELLOW}Cleaning previous test output...${NC}"
    rm -rf "$TEST_OUTPUT_DIR"
fi

mkdir -p "$TEST_OUTPUT_DIR"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Function to run a test
run_test() {
    local test_name=$1
    local test_command=$2
    local expected_output=$3

    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -e "${BLUE}Test $TESTS_TOTAL: $test_name${NC}"

    # Run test and capture exit code
    local test_exit_code=0
    eval "$test_command" > "$TEST_OUTPUT_DIR/test_$TESTS_TOTAL.log" 2>&1 || test_exit_code=$?

    # Always show log content for debugging (but only stderr goes to console)
    echo "Test command: $test_command" >> "$TEST_OUTPUT_DIR/test_$TESTS_TOTAL.log"
    echo "Exit code: $test_exit_code" >> "$TEST_OUTPUT_DIR/test_$TESTS_TOTAL.log"

    if [ $test_exit_code -eq 0 ]; then
        if [ -n "$expected_output" ]; then
            if grep -q "$expected_output" "$TEST_OUTPUT_DIR/test_$TESTS_TOTAL.log"; then
                echo -e "${GREEN}  ✓ PASSED${NC}"
                TESTS_PASSED=$((TESTS_PASSED + 1))
                return 0
            else
                echo -e "${RED}  ✗ FAILED - Expected output not found${NC}"
                echo "Expected: $expected_output"
                echo "Log file: $TEST_OUTPUT_DIR/test_$TESTS_TOTAL.log"
                cat "$TEST_OUTPUT_DIR/test_$TESTS_TOTAL.log"
                TESTS_FAILED=$((TESTS_FAILED + 1))
                return 1
            fi
        else
            echo -e "${GREEN}  ✓ PASSED${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
        fi
    else
        echo -e "${RED}  ✗ FAILED - Command failed (exit code: $test_exit_code)${NC}"
        echo "Command: $test_command"
        echo "Log file: $TEST_OUTPUT_DIR/test_$TESTS_TOTAL.log"
        cat "$TEST_OUTPUT_DIR/test_$TESTS_TOTAL.log"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Helper function to check for absence of pattern
check_no_match() {
    local pattern=$1
    local file=$2

    echo "=== Diagnostic Info ===" >&2
    echo "Pattern: $pattern" >&2
    echo "File: $file" >&2
    echo "File exists: $(test -f "$file" && echo "yes" || echo "no")" >&2
    echo "File readable: $(test -r "$file" && echo "yes" || echo "no")" >&2
    echo "Working directory: $(pwd)" >&2
    echo "Bash version: $BASH_VERSION" >&2
    echo "Shell: $SHELL" >&2
    echo "" >&2

    # Try the grep and capture output
    local grep_output
    local grep_exit_code
    grep_output=$(grep -E "$pattern" "$file" 2>&1) || grep_exit_code=$?

    echo "Grep exit code: ${grep_exit_code:-0}" >&2
    echo "Grep output length: ${#grep_output}" >&2
    if [ -n "$grep_output" ]; then
        echo "Grep found matches (first 200 chars):" >&2
        echo "${grep_output:0:200}" >&2
    else
        echo "Grep output: (empty - no matches)" >&2
    fi
    echo "===================" >&2

    if [ "${grep_exit_code:-0}" -eq 0 ]; then
        echo "FAIL: Pattern found in file" >&2
        return 1  # Pattern found - test fails
    else
        echo "PASS: Pattern not found in file" >&2
        return 0  # Pattern not found - test passes
    fi
}

echo -e "${BLUE}=== Template Validation Tests ===${NC}"
echo ""

# Test 1: Check if template files exist
run_test "C# templates exist" \
    "test -f templates/mcp-csharp/api.mustache" \
    ""

run_test "Python templates exist" \
    "test -f templates/mcp-python/api.mustache && test -f templates/mcp-python/model.mustache" \
    ""

run_test "TypeScript templates exist" \
    "test -f templates/mcp-typescript/api.mustache && test -f templates/mcp-typescript/model.mustache" \
    ""

run_test "Go templates exist" \
    "test -f templates/mcp-go/api.mustache && test -f templates/mcp-go/model.mustache" \
    ""

echo ""
echo -e "${BLUE}=== Configuration Validation Tests ===${NC}"
echo ""

# Test 2: Check if config files are valid JSON
run_test "C# config is valid JSON" \
    "python3 -c \"import json; json.load(open('config/mcp-csharp.json'))\"" \
    ""

run_test "Python config is valid JSON" \
    "python3 -c \"import json; json.load(open('config/mcp-python.json'))\"" \
    ""

run_test "TypeScript config is valid JSON" \
    "python3 -c \"import json; json.load(open('config/mcp-typescript.json'))\"" \
    ""

run_test "Go config is valid JSON" \
    "python3 -c \"import json; json.load(open('config/mcp-go.json'))\"" \
    ""

echo ""
echo -e "${BLUE}=== OpenAPI Spec Validation Tests ===${NC}"
echo ""

# Test 3: Validate OpenAPI spec
run_test "OpenAPI spec is valid YAML" \
    "python3 -c \"import yaml; yaml.safe_load(open('$TEST_SPEC'))\"" \
    ""

run_test "OpenAPI spec has required fields" \
    "python3 -c \"import yaml; spec = yaml.safe_load(open('$TEST_SPEC')); assert 'openapi' in spec and 'paths' in spec and 'info' in spec\"" \
    ""

echo ""
echo -e "${BLUE}=== Generator Script Tests ===${NC}"
echo ""

# Test 4: Test generation script
run_test "Generation script is executable" \
    "test -x generate-mcp-all.sh" \
    ""

run_test "Generation script dry-run (Python)" \
    "./generate-mcp-all.sh --languages=python --dry-run" \
    "Would run"

run_test "Generation script help" \
    "./generate-mcp-all.sh --help" \
    "Usage"

echo ""
echo -e "${BLUE}=== Template Syntax Tests ===${NC}"
echo ""

# Test 5: Check for common template issues
run_test "C# template has no unclosed mustache tags" \
    "check_no_match '{{[^}]*\\\$' templates/mcp-csharp/api.mustache" \
    ""

run_test "Python template has no unclosed mustache tags" \
    "check_no_match '{{[^}]*\\\$' templates/mcp-python/api.mustache" \
    ""

run_test "TypeScript template has no unclosed mustache tags" \
    "check_no_match '{{[^}]*\\\$' templates/mcp-typescript/api.mustache" \
    ""

run_test "Go template has no unclosed mustache tags" \
    "check_no_match '{{[^}]*\\\$' templates/mcp-go/api.mustache" \
    ""

echo ""
echo -e "${BLUE}=== Documentation Tests ===${NC}"
echo ""

# Test 6: Check documentation exists
run_test "MCP extensions documentation exists" \
    "test -f MCP_EXTENSIONS.md" \
    ""

run_test "Generator README exists" \
    "test -f README_MCP_GENERATOR.md" \
    ""

run_test "Example files exist" \
    "test -f examples/python-mcp-example.py && test -f examples/typescript-mcp-example.ts" \
    ""

echo ""
echo -e "${BLUE}=== Code Generation Tests (Dry Run) ===${NC}"
echo ""

# Test 7: Dry run generation for all languages
run_test "C# generation dry-run" \
    "./generate-mcp-all.sh --languages=csharp --dry-run" \
    "Would run"

run_test "Python generation dry-run" \
    "./generate-mcp-all.sh --languages=python --dry-run" \
    "Would run"

run_test "TypeScript generation dry-run" \
    "./generate-mcp-all.sh --languages=typescript --dry-run" \
    "Would run"

run_test "Go generation dry-run" \
    "./generate-mcp-all.sh --languages=go --dry-run" \
    "Would run"

run_test "Multi-language generation dry-run" \
    "./generate-mcp-all.sh --languages=csharp,python,typescript,go --dry-run" \
    "Would run"

echo ""
echo -e "${BLUE}=== Test Summary ===${NC}"
echo -e "Total:  $TESTS_TOTAL"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ All tests passed!${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Run actual code generation: ./generate-mcp-all.sh --languages=python"
    echo "  2. Review generated code in ../generated/"
    echo "  3. Test with MCP Inspector"
    exit 0
else
    echo ""
    echo -e "${RED}❌ Some tests failed${NC}"
    echo "Check test output in: $TEST_OUTPUT_DIR/"
    exit 1
fi
