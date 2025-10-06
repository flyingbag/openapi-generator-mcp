# Getting Started with OpenAPI to MCP Generator

Welcome! This guide will help you generate your first MCP server from an OpenAPI specification in less than 10 minutes.

---

## Prerequisites

Before you begin, ensure you have:

- **Node.js 14+** ([Download](https://nodejs.org/))
- **OpenAPI Generator CLI** (we'll install this)
- **Your language runtime** (optional, for testing):
  - Python 3.8+ for Python generation
  - .NET SDK for C# generation
  - TypeScript/Node for TypeScript generation
  - Go 1.21+ for Go generation

---

## Quick Start (5 minutes)

### Step 1: Install OpenAPI Generator CLI

```bash
npm install -g @openapitools/openapi-generator-cli
```

Verify installation:
```bash
openapi-generator-cli version
```

### Step 2: Clone or Download This Repository

```bash
git clone https://github.com/openapi-generator/openapi-generator-mcp.git
cd openapi-generator-mcp
```

### Step 3: Generate Your First MCP Server

Let's generate a Python MCP server for the included Petstore API:

```bash
./generate-mcp-all.sh --languages=python
```

That's it! Your MCP server is now generated at `../generated/python-mcp/`

### Step 4: View the Generated Code

```bash
ls -la ../generated/python-mcp/petstore_mcp/api/
```

You should see:
- `pet_api.py` - Pet management tools
- `store_api.py` - Store operations tools
- `user_api.py` - User management tools

---

## Understanding What Was Generated

The generator created MCP tool classes for each API:

```python
# Example from pet_api.py
class PetApiMcpToolBase:
    """MCP Tools for pet operations"""

    def __init__(self, server: Server):
        self.server = server
        self._register_tools()

    async def get_pet_by_id(self, arguments: Dict[str, Any]) -> list[TextContent]:
        """Get pet by ID from Petstore."""
        # Implementation here...
```

Each operation from your OpenAPI spec becomes an MCP tool!

---

## Testing Your MCP Server

### Option A: Use the Example Server

```bash
cd examples

# Install dependencies
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt

# Run the server
python python-mcp-example.py
```

### Option B: Test with MCP Inspector

```bash
npx @modelcontextprotocol/inspector python examples/python-mcp-example.py
```

The MCP Inspector will open in your browser. Try these tools:
- `get_pet_by_id` with `{"petId": 1}`
- `find_pets_by_status` with `{"status": "available"}`
- `get_store_inventory` with `{}`

---

## Using Your Own OpenAPI Spec

### Step 1: Add Your OpenAPI Spec

Place your OpenAPI 3.0+ spec in the `api/` directory:

```bash
cp /path/to/your/openapi.yaml api/my-api.yaml
```

### Step 2: Add MCP Extensions (Optional but Recommended)

Edit your OpenAPI spec to add MCP metadata:

```yaml
info:
  title: My API
  version: 1.0.0
  x-mcp-server:
    name: "my-api-mcp"
    version: "1.0.0"
    description: "MCP server for My API"

tags:
  - name: users
    x-mcp-category:
      name: "User Management"
      description: "User-related operations"
      icon: "👤"

paths:
  /users/{id}:
    get:
      x-mcp-tool:
        enabled: true
        category: "users"
        priority: 100
```

See [MCP_EXTENSIONS.md](./MCP_EXTENSIONS.md) for complete documentation.

### Step 3: Create a Configuration File

```bash
cp config/mcp-python.json config/my-api-python.json
```

Edit `my-api-python.json`:

```json
{
  "inputSpec": "api/my-api.yaml",
  "generatorName": "python",
  "templateDir": "templates/mcp-python",
  "outputDir": "../generated/my-api-mcp",
  "packageName": "my_api_mcp",
  "packageTitle": "My API MCP Server",
  "projectName": "my-api-mcp",
  "packageVersion": "1.0.0"
}
```

### Step 4: Generate Your MCP Server

```bash
openapi-generator-cli generate -c config/my-api-python.json
```

### Step 5: Implement Your Service

The generated code provides base classes. Implement the service layer:

```python
from my_api_mcp.api.users_api import UsersApiMcpToolBase
from mcp.server import Server

class MyApiService:
    """Your business logic implementation"""

    async def get_user_by_id(self, user_id: int):
        # Call your actual API
        response = await httpx.get(f"https://myapi.com/users/{user_id}")
        return response.json()

# Use it
server = Server("my-api-mcp")
service = MyApiService()
tools = UsersApiMcpToolBase(server)
# Wire up service calls...
```

---

## Language-Specific Guides

### Python

**Installation:**
```bash
pip install mcp httpx
```

**Key Files:**
- `petstore_mcp/api/*.py` - Tool implementations
- `petstore_mcp/models/*.py` - Data models (if enabled)

**Example Usage:**
```python
from mcp.server import Server
from petstore_mcp.api.pet_api import PetApiMcpToolBase

server = Server("petstore-mcp")
pet_tools = PetApiMcpToolBase(server)
await server.run()
```

### TypeScript

**Installation:**
```bash
npm install @modelcontextprotocol/sdk
```

**Key Files:**
- `api/*.ts` - Tool implementations
- `models/*.ts` - Data models (if enabled)

**Example Usage:**
```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { PetApiMcpTools } from "./api/petApi.js";

const server = new Server({ name: "petstore-mcp", version: "1.0.0" });
const petTools = new PetApiMcpTools(server);
await server.connect(transport);
```

### C#

**Installation:**
```bash
dotnet add package ModelContextProtocol
```

**Key Files:**
- `src/PetstoreMcp/Api/*.cs` - Tool implementations
- `src/PetstoreMcp/Models/*.cs` - Data models (if enabled)

**Example Usage:**
```csharp
using ModelContextProtocol.Server;
using PetstoreMcp;

var builder = RestServerBuilder.UseDefaults();
builder.Services.AddMcpServer()
    .WithHttpTransport()
    .WithToolsFromAssembly(Assembly.GetExecutingAssembly());
```

### Go

**Installation:**
```bash
go get github.com/modelcontextprotocol/go-sdk
```

**Key Files:**
- `api_*.go` - Tool implementations
- `model_*.go` - Data models (if enabled)

**Example Usage:**
```go
import (
    "github.com/modelcontextprotocol/go-sdk/mcp"
    petstoreMcp "github.com/your-org/petstore-mcp-go"
)

server := mcp.NewServer("petstore-mcp", "1.0.0")
petTools := petstoreMcp.NewPetAPIMcpTools(server, service)
server.ListenAndServe(":8080")
```

---

## Common Workflows

### Workflow 1: Rapid Prototyping

```bash
# 1. Get an OpenAPI spec
curl https://api.example.com/openapi.json > api/example.yaml

# 2. Add basic MCP extensions
# (edit api/example.yaml manually or use a script)

# 3. Generate all languages
./generate-mcp-all.sh

# 4. Test with one language
cd examples
python python-mcp-example.py
```

### Workflow 2: Production Deployment

```bash
# 1. Validate your OpenAPI spec
./validate-mcp-extensions.sh api/your-api.yaml

# 2. Run all tests
./scripts/run-all-tests.sh

# 3. Generate production code
./generate-mcp-all.sh --languages=python

# 4. Build Docker container
docker build -t your-mcp-server .

# 5. Deploy
kubectl apply -f k8s/deployment.yaml
```

### Workflow 3: Continuous Integration

```yaml
# .github/workflows/generate.yml
name: Generate MCP Servers

on: [push]

jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install OpenAPI Generator
        run: npm install -g @openapitools/openapi-generator-cli
      - name: Validate Spec
        run: ./validate-mcp-extensions.sh api/openapi.yaml
      - name: Generate All Languages
        run: ./generate-mcp-all.sh
      - name: Run Tests
        run: ./scripts/run-all-tests.sh
```

---

## Troubleshooting

### Issue: "openapi-generator-cli: command not found"

**Solution:**
```bash
npm install -g @openapitools/openapi-generator-cli
# Or use npx:
npx @openapitools/openapi-generator-cli generate -c config/mcp-python.json
```

### Issue: "Template file not found"

**Solution:**
```bash
# Check template directory exists
ls templates/mcp-python/

# Verify templateDir in config matches actual directory
cat config/mcp-python.json | grep templateDir
```

### Issue: Generated code has import errors

**Solution:**
```bash
# For Python: Enable model generation
# Edit config/mcp-python.json and remove excludeModels

# Or define models manually
# Check templates/mcp-python/model.mustache
```

### Issue: MCP Inspector can't connect

**Solution:**
```bash
# Ensure your server uses stdio transport
# Check examples/python-mcp-example.py for correct setup

# Verify dependencies installed
pip list | grep mcp

# Test manually
python examples/python-mcp-example.py
# (should wait for stdin input)
```

---

## Best Practices

### 1. Version Control

```bash
# Commit your OpenAPI spec and configs
git add api/ config/
git commit -m "Add API specification and configs"

# Don't commit generated code
echo "generated/" >> .gitignore
```

### 2. MCP Extension Organization

```yaml
# Group related operations with categories
tags:
  - name: core
    x-mcp-category:
      name: "Core Operations"
      priority: 100

  - name: admin
    x-mcp-category:
      name: "Admin Operations"
      priority: 50

# Set priorities for important tools
paths:
  /health:
    get:
      x-mcp-tool:
        priority: 100  # High priority

  /debug:
    get:
      x-mcp-tool:
        priority: 10   # Low priority
```

### 3. Testing

```bash
# Always validate before generating
./validate-mcp-extensions.sh api/your-api.yaml

# Test generated code
./scripts/run-all-tests.sh

# Manual integration test
npx @modelcontextprotocol/inspector python examples/your-example.py
```

### 4. Documentation

```bash
# Add examples to your OpenAPI spec
paths:
  /users/{id}:
    get:
      x-mcp-examples:
        - description: "Get user by ID"
          input: {"id": 123}
          output: {"id": 123, "name": "John"}

# Generate API documentation
openapi-generator-cli generate \
  -g markdown \
  -i api/your-api.yaml \
  -o docs/
```

---

## Next Steps

### Learn More

- **[README_MCP_GENERATOR.md](./README_MCP_GENERATOR.md)** - Complete usage guide
- **[MCP_EXTENSIONS.md](./MCP_EXTENSIONS.md)** - MCP extension reference
- **[TEMPLATE_DEVELOPMENT_GUIDE.md](./TEMPLATE_DEVELOPMENT_GUIDE.md)** - Create custom templates
- **[TESTING.md](./TESTING.md)** - Testing procedures

### Examples

- **[examples/](./examples/)** - Working example implementations
- **[api/openapi.yaml](./api/openapi.yaml)** - Annotated Petstore example
- **Multiple API Examples** - Coming soon

### Get Help

- **[GitHub Issues](https://github.com/openapi-generator/openapi-generator-mcp/issues)** - Report bugs
- **[GitHub Discussions](https://github.com/openapi-generator/openapi-generator-mcp/discussions)** - Ask questions
- **[CONTRIBUTING.md](./CONTRIBUTING.md)** - Contribute to the project

### Stay Updated

- ⭐ **Star the repository** to get updates
- 👀 **Watch releases** for new versions
- 🐦 **Follow announcements** on social media

---

## Quick Reference

### Essential Commands

```bash
# Generate all languages
./generate-mcp-all.sh

# Generate specific language
./generate-mcp-all.sh --languages=python

# Validate OpenAPI spec
./validate-mcp-extensions.sh api/openapi.yaml

# Run all tests
./scripts/run-all-tests.sh

# Test with MCP Inspector
npx @modelcontextprotocol/inspector python examples/python-mcp-example.py
```

### File Structure

```
openapi-generator-mcp/
├── api/                  # OpenAPI specifications
├── config/               # Generation configurations
├── templates/            # Mustache templates
├── examples/             # Example implementations
├── scripts/              # Utility scripts
├── schemas/              # JSON schemas
└── docs/                 # Documentation
```

### Configuration Keys

```json
{
  "inputSpec": "api/openapi.yaml",      // Input OpenAPI spec
  "generatorName": "python",            // Language (python/go/typescript/csharp)
  "templateDir": "templates/mcp-python",// Template directory
  "outputDir": "../generated/python-mcp",// Output directory
  "packageName": "my_api_mcp"          // Package/module name
}
```

---

## Success! 🎉

You've successfully generated your first MCP server!

**What you've learned:**
- ✅ Install and use OpenAPI Generator CLI
- ✅ Generate MCP servers from OpenAPI specs
- ✅ Add MCP extensions to OpenAPI specs
- ✅ Test generated servers with MCP Inspector
- ✅ Implement service layers for your APIs

**Ready for more?** Check out the [README_MCP_GENERATOR.md](./README_MCP_GENERATOR.md) for advanced topics!

---

*Last Updated: 2025-10-06*
*Version: 1.0.0*
