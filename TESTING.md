# Testing Guide

This guide explains how to test the OpenAPI to MCP Generator and its examples.

## Prerequisites

- **Node.js 18+** - For OpenAPI Generator CLI and TypeScript examples
- **Python 3.8+** - For Python examples
- **OpenAPI Generator CLI** - Install with `npm install -g @openapitools/openapi-generator-cli`

## 1. Test Code Generation

### Test All Languages

```bash
./generate-mcp-all.sh
```

Expected output:
- ✓ C# generation complete
- ✓ Python generation complete
- ✓ TypeScript generation complete

Generated files will be in `../generated/`:
```
generated/
├── csharp-mcp/src/PetstoreMcp/Api/
├── python-mcp/petstore_mcp/api/
└── typescript-mcp/api/
```

### Test Specific Language

```bash
# Python only
./generate-mcp-all.sh --languages=python

# Multiple languages
./generate-mcp-all.sh --languages=csharp,python

# Dry run (preview)
./generate-mcp-all.sh --dry-run
```

## 2. Validate OpenAPI Spec

Validate the OpenAPI specification with MCP extensions:

```bash
./validate-mcp-extensions.sh api/openapi.yaml
```

Expected output:
- ✓ OpenAPI version: 3.0.4
- ✓ Info section present
- ✓ x-mcp-server extension found
- ✓ Categories defined for all tags

## 3. Test Templates

Run the template testing framework:

```bash
./test-templates.sh
```

This validates:
- Template file existence
- Configuration validity
- OpenAPI spec validation
- Template syntax

## 4. Test Python Example

### Setup

```bash
cd examples
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Run Server

```bash
python python-mcp-example.py
```

The server will start with stdio transport and wait for JSON-RPC requests.

### Test with MCP Inspector

```bash
# Install MCP Inspector (one-time)
npm install -g @modelcontextprotocol/inspector

# Test the server
npx @modelcontextprotocol/inspector python python-mcp-example.py
```

The inspector will open in your browser. Try these tools:
- `get_pet_by_id` with `petId: 1`
- `find_pets_by_status` with `status: "available"`
- `get_store_inventory` with no parameters

### Expected Results

The server should connect to `https://petstore3.swagger.io/api/v3` and return real data:

```json
{
  "id": 1,
  "name": "doggie",
  "status": "available",
  "photoUrls": ["..."],
  "category": {...},
  "tags": [...]
}
```

## 5. Test TypeScript Example

### Setup

```bash
cd examples
npm install
```

### Run Server

```bash
# Using tsx (development)
npm run start:ts

# Or compile and run
npm run build
npm run start:js
```

### Test with MCP Inspector

```bash
npx @modelcontextprotocol/inspector npm run start:ts
```

Try the same tools as the Python example.

## 6. Verify Generated Code

### C# Verification

Check that generated files compile:

```bash
cd ../generated/csharp-mcp
# Requires .NET SDK
dotnet build  # If you have a project file
```

Generated classes should have:
- `[McpServerTool]` attributes
- `async Task<string>` method signatures
- Proper XML documentation

### Python Verification

Check imports and syntax:

```bash
cd ../generated/python-mcp
python -m py_compile petstore_mcp/api/*.py
```

All files should compile without errors.

### TypeScript Verification

Check TypeScript compilation:

```bash
cd ../generated/typescript-mcp
npx tsc --noEmit api/*.ts
```

Should show no errors.

## 7. Integration Testing

### Test Real API Calls

The examples connect to the live Petstore API. Test common scenarios:

1. **Get Pet by ID**: Should return pet data or 404
2. **Find Pets by Status**: Should return array of pets
3. **Get Inventory**: Should return status counts

### Test Error Handling

Try invalid requests:
- Non-existent pet ID
- Invalid status value
- Missing required parameters

The server should return proper error responses.

## 8. Performance Testing

### Generation Speed

Time the generation:

```bash
time ./generate-mcp-all.sh --languages=python
```

Expected: < 5 seconds per language

### API Response Time

Check latency to Petstore API:

```bash
curl -w "@-" -o /dev/null -s 'https://petstore3.swagger.io/api/v3/pet/1' <<'EOF'
\nTime: %{time_total}s\n
EOF
```

Expected: < 1 second

## 9. Continuous Integration

### GitHub Actions Example

```yaml
name: Test MCP Generation
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'

      - name: Install OpenAPI Generator
        run: npm install -g @openapitools/openapi-generator-cli

      - name: Validate OpenAPI Spec
        run: ./validate-mcp-extensions.sh api/openapi.yaml

      - name: Test Generation
        run: ./generate-mcp-all.sh

      - name: Run Template Tests
        run: ./test-templates.sh
```

## 10. Troubleshooting

### Generation Fails

**Error: Template not found**
- Check `templateDir` path in config files
- Ensure templates exist in correct directory

**Error: Invalid OpenAPI spec**
- Validate spec: `./validate-mcp-extensions.sh api/openapi.yaml`
- Check for syntax errors in YAML

### Python Example Issues

**Import Error: No module named 'mcp'**
```bash
pip install mcp httpx
```

**Connection Error**
- Check internet connection
- Petstore API may be down - try later

### TypeScript Example Issues

**Cannot find module '@modelcontextprotocol/sdk'**
```bash
cd examples && npm install
```

**Compilation Error**
```bash
npx tsc --init
npm install
```

### Generated Code Issues

**Python: Import errors**
- Regenerate: `./generate-mcp-all.sh --languages=python`
- Check template: `templates/mcp-python/api.mustache`

**C#: Compilation errors**
- Verify OpenAPI types are compatible
- Check template: `templates/mcp-csharp/api.mustache`

## 11. Test Checklist

Before committing changes:

- [ ] All languages generate without errors
- [ ] OpenAPI spec validates successfully
- [ ] Template tests pass
- [ ] Python example runs and connects
- [ ] TypeScript example runs and connects
- [ ] Generated code has correct imports
- [ ] MCP Inspector can communicate with servers
- [ ] Real API calls return expected data
- [ ] Error handling works correctly
- [ ] Documentation is up to date

## 12. Reporting Issues

When reporting issues, include:

1. **Generation command** used
2. **Error output** (full logs)
3. **OpenAPI spec** (if custom)
4. **Environment info**:
   - OS and version
   - Node.js version
   - Python version
   - OpenAPI Generator version

```bash
# Collect environment info
node --version
python --version
openapi-generator-cli version
```

---

**Last Updated**: 2025-10-06
**Version**: 1.0.0
