# MCP Multi-Language Code Generator

A template-based code generator that creates Model Context Protocol (MCP) server implementations from OpenAPI specifications across multiple programming languages.

## Overview

This generator extends OpenAPI Generator to produce MCP-compatible server code for:
- **C# (.NET)** - Using MCP SDK with .NET Standard 2.1
- **Python** - Using Python MCP SDK with async/await
- **TypeScript** - Using TypeScript MCP SDK

## Architecture

```
OpenAPI Spec (contextbridge.yaml)
         ↓
OpenAPI Generator + Custom Templates
         ↓
┌────────┴────────┬─────────────┐
│                 │             │
C# MCP Tools   Python MCP    TypeScript MCP
(Base Classes)   (Full Impl)   (Full Impl)
```

### How It Works

1. **OpenAPI Specification**: Defines REST API endpoints with operations, parameters, and models
2. **Custom Templates**: Mustache templates transform OpenAPI operations into MCP tool definitions
3. **Language-Specific Generation**: Each language has tailored templates and configurations
4. **Post-Processing**: Optional scripts for file organization and naming conventions

## Directory Structure

```
openapitools/
├── api/
│   └── contextbridge.yaml           # OpenAPI specification
├── config/
│   ├── mcp-csharp.json             # C# generator config
│   ├── mcp-python.json             # Python generator config
│   └── mcp-typescript.json         # TypeScript generator config
├── templates/
│   ├── mcp/                        # C# templates (existing)
│   │   └── api.mustache
│   ├── mcp-python/                 # Python templates (new)
│   │   ├── api.mustache
│   │   ├── model.mustache
│   │   ├── __init__.mustache
│   │   └── partial_header.mustache
│   ├── mcp-typescript/             # TypeScript templates (planned)
│   └── shared/                     # Shared partials
├── generate-mcp-all.sh             # Multi-language generator script
├── MCP_EXTENSIONS.md               # OpenAPI extension documentation
└── README_MCP_GENERATOR.md         # This file
```

## Quick Start

### Prerequisites

- Node.js 14+ (for openapi-generator-cli)
- OpenAPI Generator CLI installed:
  ```bash
  npm install -g @openapitools/openapi-generator-cli
  ```

### Generate All Languages

```bash
cd openapitools
./generate-mcp-all.sh
```

### Generate Specific Language

```bash
# Python only
./generate-mcp-all.sh --languages=python

# C# only
./generate-mcp-all.sh --languages=csharp

# Multiple languages
./generate-mcp-all.sh --languages=csharp,python,typescript
```

### Dry Run (Preview)

```bash
./generate-mcp-all.sh --languages=python --dry-run
```

## Generated Output

### C# Output
```
Editor/ContextBridge/Interface/
├── SceneMcpToolBase.cs
├── ObjectMcpToolBase.cs
├── AssetMcpToolBase.cs
└── ...
```

**Usage:**
```csharp
[McpServerToolType]
public class SceneMcpTool : SceneMcpToolBase
{
    public override async Task<string> GetSceneInfo()
    {
        var result = await _sceneService.GetSceneInfoAsync();
        return JsonConvert.SerializeObject(result);
    }
}
```

### Python Output
```
generated/python-mcp/
├── unity_context_bridge_mcp/
│   ├── __init__.py
│   ├── scene_mcp_tool.py
│   ├── object_mcp_tool.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── scene_info_response.py
│   │   └── ...
│   └── requirements.txt
```

**Usage:**
```python
from mcp.server import Server
from unity_context_bridge_mcp import SceneMcpTool

server = Server("unity-context-bridge")
scene_tool = SceneMcpTool(server, service_implementation)

# Tools are automatically registered with the server
```

## Template Customization

### Adding a New Language

1. **Create template directory:**
   ```bash
   mkdir templates/mcp-<language>
   ```

2. **Create templates:**
   - `api.mustache` - Tool class generation
   - `model.mustache` - Data model generation
   - `__init__.mustache` - Package initialization
   - `partial_header.mustache` - File header

3. **Create configuration:**
   ```json
   {
     "inputSpec": "api/openapi.yaml",
     "generatorName": "<language>",
     "templateDir": "templates/mcp-<language>",
     "outputDir": "../generated/<language>-mcp",
     "packageName": "unity_context_bridge_mcp"
   }
   ```

4. **Update generation script:**
   Add language-specific post-processing to `generate-mcp-all.sh`

### Template Variables

Common mustache variables available in templates:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{classname}}` | API class name | SceneApi |
| `{{operationId}}` | Operation identifier | getSceneInfo |
| `{{summary}}` | Operation summary | Retrieve Scene Information |
| `{{notes}}` | Operation description | Retrieves the current scene... |
| `{{allParams}}` | All parameters | [scenePath, saveCurrent] |
| `{{returnType}}` | Return type | SceneInfoResponse |
| `{{hasRequiredParams}}` | Has required params | true/false |
| `{{isLibrary}}` | Library mode flag | true/false |

### Custom Extensions

Use OpenAPI extensions for MCP-specific metadata:

```yaml
paths:
  /pet/{petId}:
    get:
      operationId: getPetById
      x-mcp-tool:
        enabled: true
        category: "pet"
        priority: 100
      x-mcp-examples:
        - description: "Get pet by ID"
          input: { petId: 123 }
          output: { id: 123, name: "doggie", status: "available" }
```

See [MCP_EXTENSIONS.md](./MCP_EXTENSIONS.md) for full documentation.

## Configuration Options

### Common Configuration

```json
{
  "inputSpec": "api/openapi.yaml",
  "excludeTests": "true",
  "isLibrary": true,
  "packageName": "petstore_mcp",
  "packageVersion": "1.0.0",
  "packageAuthors": "MCP Generator"
}
```

### C# Configuration

```json
{
  "generatorName": "csharp",
  "nullableReferenceTypes": false,
  "sourceFolder": "Editor",
  "validatable": false,
  "zeroBasedEnums": true,
  "additionalProperties": {
    "targetFramework": "netstandard2.1"
  }
}
```

### Python Configuration

```json
{
  "generatorName": "python",
  "library": "asyncio",
  "additionalProperties": {
    "pythonVersion": "3.8",
    "supportPython38": "true",
    "generateSourceCodeOnly": "true"
  }
}
```

## Integration with MCP SDKs

### C# SDK Integration

The generated code works with `ModelContextProtocol` NuGet package:

```csharp
using ModelContextProtocol.Server;

var builder = RestServerBuilder.UseDefaults();
var mcpBuilder = builder.Services.AddMcpServer()
    .WithHttpTransport()
    .WithToolsFromAssembly(Assembly.GetExecutingAssembly());
```

### Python SDK Integration

The generated code works with `mcp` PyPI package:

```python
from mcp.server import Server
from petstore_mcp import PetMcpTool, StoreMcpTool, UserMcpTool

server = Server("petstore-mcp")

# Initialize tools with service implementations
pet_tool = PetMcpTool(server, pet_service)
store_tool = StoreMcpTool(server, store_service)
user_tool = UserMcpTool(server, user_service)

# Run server
await server.run()
```

## Advanced Usage

### Custom Post-Processing

Add language-specific post-processing in `generate-mcp-all.sh`:

```bash
post_process_language() {
    case $lang in
        python)
            # Format with black
            black ../generated/python-mcp/
            # Sort imports with isort
            isort ../generated/python-mcp/
            ;;
    esac
}
```

### Selective Generation

Generate only specific API tags:

```bash
openapi-generator-cli generate \
    -c config/mcp-python.json \
    --global-property apis=PetApi,StoreApi,UserApi
```

### CI/CD Integration

```yaml
# .github/workflows/generate-mcp.yml
name: Generate MCP Code
on: [push]
jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install OpenAPI Generator
        run: npm install -g @openapitools/openapi-generator-cli
      - name: Generate Code
        run: |
          cd openapitools
          ./generate-mcp-all.sh --languages=csharp,python
      - name: Commit Generated Code
        run: |
          git config user.name "GitHub Actions"
          git commit -am "chore: regenerate MCP code"
          git push
```

## Troubleshooting

### Issue: Templates not found

**Solution:** Ensure `templateDir` in config points to correct relative path:
```json
"templateDir": "templates/mcp-python"
```

### Issue: Invalid mustache syntax

**Solution:** Validate templates with mustache linter:
```bash
npm install -g mustache
mustache --version
```

### Issue: Generated code has compilation errors

**Solution:**
1. Check OpenAPI spec is valid
2. Verify template variable names match OpenAPI Generator's model
3. Run with `--verbose` flag for debugging

### Issue: Post-processing fails

**Solution:** Run without post-processing first:
```bash
./generate-mcp-all.sh --skip-post-process
```

## Comparison with Other Approaches

| Approach | Pros | Cons | Best For |
|----------|------|------|----------|
| **Template Extension (Current)** | Fast iteration, no Java coding, language-agnostic | Limited validation, requires post-processing | Quick prototyping, multiple languages |
| **Custom Generator** | Full control, type-safe, advanced validation | Java expertise required, maintenance overhead | Production systems, complex validation |
| **Manual Implementation** | Complete flexibility | Time-consuming, error-prone, inconsistent | Small projects, one-off tools |

## Roadmap

### Phase 1 (Current)
- ✅ C# template-based generation
- ✅ Python template-based generation
- ✅ Multi-language generation script
- ✅ OpenAPI extension definitions

### Phase 2 (Next 4-6 weeks)
- ⏳ TypeScript template-based generation
- ⏳ Go template-based generation
- ⏳ Validation scripts for extensions
- ⏳ Example projects for each language

### Phase 3 (Future)
- 📋 Custom Java generator (`openapi-generator-mcp`)
- 📋 MCP manifest generation
- 📋 Resource and Prompt support
- 📋 Publish to OpenAPI Generator project

## Contributing

### Adding Templates

1. Fork repository
2. Create language template directory
3. Implement required mustache files
4. Test generation
5. Submit PR with examples

### Improving Existing Templates

1. Test changes with real OpenAPI specs
2. Ensure backward compatibility
3. Update documentation
4. Add test cases

## Resources

- [OpenAPI Generator Documentation](https://openapi-generator.tech/)
- [Mustache Template Syntax](https://mustache.github.io/)
- [MCP Specification](https://github.com/modelcontextprotocol/specification)
- [MCP C# SDK](https://github.com/modelcontextprotocol/csharp-sdk)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)

## Support

- **Issues**: Open GitHub issue with `[mcp-generator]` tag
- **Questions**: Discussion board or Slack channel
- **Documentation**: [MCP_EXTENSIONS.md](./MCP_EXTENSIONS.md)

---

**Version:** 1.0.0
**Last Updated:** 2025-10-06
**Maintainer:** Unity AI-QA Team
