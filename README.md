# OpenAPI to MCP Generator

Generate Model Context Protocol (MCP) server implementations from OpenAPI specifications across multiple programming languages.

## Overview

This project provides custom templates and configurations for [OpenAPI Generator](https://openapi-generator.tech/) to create MCP-compatible server code. It enables AI agents to interact with any REST API through the standardized Model Context Protocol.

**Supported Languages:**
- ✅ **C#** (.NET Standard 2.1)
- ✅ **Python** (3.8+)
- ✅ **TypeScript** (Node.js)

## Features

- 🚀 **Fast Generation** - Generate complete MCP servers in seconds
- 🎯 **Type-Safe** - Leverages language type systems for compile-time safety
- 🔌 **Plug-and-Play** - Generated code integrates with official MCP SDKs
- 📝 **Customizable** - Mustache templates for flexible code generation
- 🏷️ **MCP Extensions** - Custom OpenAPI extensions for MCP metadata
- 🧪 **Validated** - Built-in validation for OpenAPI specs and MCP extensions

## Quick Start

### Prerequisites

```bash
# Install Node.js 14+ (for OpenAPI Generator CLI)
# Install OpenAPI Generator CLI
npm install -g @openapitools/openapi-generator-cli
```

### Generate MCP Servers

```bash
# Clone the repository
git clone https://github.com/openapi-generator/openapi-generator-mcp.git
cd openapi-generator-mcp

# Generate all languages
./generate-mcp-all.sh

# Generate specific language
./generate-mcp-all.sh --languages=python

# Generate multiple languages
./generate-mcp-all.sh --languages=csharp,python,typescript
```

### Generated Output

```
generated/
├── csharp-mcp/        # C# MCP server code
├── python-mcp/        # Python MCP server code
└── typescript-mcp/    # TypeScript MCP server code
```

## Example: Using the Generated Code

### Python Example

```python
from mcp.server import Server
from petstore_mcp import PetMcpTool, StoreMcpTool

# Create MCP server
server = Server("petstore-mcp")

# Initialize generated tools with your service implementations
pet_tool = PetMcpTool(server, pet_service)
store_tool = StoreMcpTool(server, store_service)

# Run server
await server.run()
```

### C# Example

```csharp
using ModelContextProtocol.Server;
using PetstoreMcp;

// Create MCP server
var builder = RestServerBuilder.UseDefaults();
var mcpBuilder = builder.Services.AddMcpServer()
    .WithHttpTransport()
    .WithToolsFromAssembly(Assembly.GetExecutingAssembly());

// Implement generated base classes
[McpServerToolType]
public class PetMcpTool : PetMcpToolBase
{
    public override async Task<string> GetPetById(long petId)
    {
        var result = await _petService.GetPetByIdAsync(petId);
        return JsonConvert.SerializeObject(result);
    }
}
```

## Project Structure

```
.
├── api/
│   └── openapi.yaml                 # OpenAPI specification with MCP extensions
├── config/
│   ├── mcp-csharp.json              # C# generator configuration
│   ├── mcp-python.json              # Python generator configuration
│   └── mcp-typescript.json          # TypeScript generator configuration
├── templates/
│   ├── mcp-csharp/                  # C# Mustache templates
│   ├── mcp-python/                  # Python Mustache templates
│   └── mcp-typescript/              # TypeScript Mustache templates
├── examples/                        # Example implementations
├── generate-mcp-all.sh              # Multi-language generator script
├── validate-mcp-extensions.sh       # OpenAPI + MCP validator
└── test-templates.sh                # Template testing framework
```

## MCP Extensions

This project defines custom OpenAPI extensions for MCP metadata:

### `x-mcp-server` (Info level)
```yaml
info:
  x-mcp-server:
    name: "petstore-mcp"
    version: "1.0.0"
    description: "MCP server for Swagger Petstore API"
```

### `x-mcp-category` (Tag level)
```yaml
tags:
  - name: pet
    x-mcp-category:
      name: "Pet Management"
      description: "Tools for managing pets"
      icon: "🐾"
```

### `x-mcp-tool` (Operation level)
```yaml
paths:
  /pet/{petId}:
    get:
      x-mcp-tool:
        enabled: true
        category: "pet"
        priority: 100
```

See [MCP_EXTENSIONS.md](./MCP_EXTENSIONS.md) for complete documentation.

## Documentation

- **[README_MCP_GENERATOR.md](./README_MCP_GENERATOR.md)** - Complete usage guide
- **[MCP_EXTENSIONS.md](./MCP_EXTENSIONS.md)** - OpenAPI extension reference
- **[TEMPLATE_DEVELOPMENT_GUIDE.md](./TEMPLATE_DEVELOPMENT_GUIDE.md)** - Template development guide
- **[IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md)** - Project summary

## Validation

Validate your OpenAPI spec with MCP extensions:

```bash
./validate-mcp-extensions.sh api/openapi.yaml
```

Test templates and configurations:

```bash
./test-templates.sh
```

## Example API

This repository includes a fully annotated Petstore OpenAPI specification with MCP extensions as a reference implementation.

**Operations included:**
- 🐾 **Pet Management** (8 tools) - Create, read, update, delete pets
- 🏪 **Store Operations** (4 tools) - Inventory and order management
- 👤 **User Management** (7 tools) - User account operations

## Integration with MCP SDKs

### C# SDK
```bash
dotnet add package ModelContextProtocol
```

### Python SDK
```bash
pip install mcp
```

### TypeScript SDK
```bash
npm install @modelcontextprotocol/sdk
```

## Development Workflow

1. **Define OpenAPI Spec** - Create or modify your OpenAPI specification
2. **Add MCP Extensions** - Annotate with `x-mcp-*` extensions
3. **Validate** - Run `./validate-mcp-extensions.sh`
4. **Generate** - Run `./generate-mcp-all.sh`
5. **Implement** - Extend generated base classes with your business logic
6. **Test** - Use MCP Inspector to test your server

## Testing with MCP Inspector

```bash
# Install MCP Inspector
npx @modelcontextprotocol/inspector

# Test your generated server
npx @modelcontextprotocol/inspector python -m petstore_mcp
```

## Roadmap

### ✅ Phase 1 - Template-Based Generation (Complete)
- C#, Python, TypeScript templates
- Multi-language generation script
- MCP extension definitions
- Validation tools
- Documentation

### 📋 Phase 2 - Custom Generator (4-6 weeks)
- Create `openapi-generator-mcp` Java module
- Advanced validation
- MCP manifest generation
- Publish to Maven Central

### 📋 Phase 3 - Community Distribution
- Submit PR to OpenAPI Generator project
- Example repositories
- Tutorial content

### 📋 Phase 4 - Additional Languages
- Go, Kotlin, Rust, Java support

## Contributing

We welcome contributions! Areas of interest:

- New language templates
- Template improvements
- Documentation enhancements
- Bug fixes
- Example implementations

See [TEMPLATE_DEVELOPMENT_GUIDE.md](./TEMPLATE_DEVELOPMENT_GUIDE.md) for template development.

## Use Cases

- **API Integration** - Generate MCP servers for any REST API
- **Legacy System Integration** - Expose legacy APIs to AI agents
- **Microservices** - Create MCP adapters for microservices
- **API Gateways** - Build MCP-compatible API gateways
- **Developer Tools** - Generate boilerplate for MCP server development

## Requirements

- **OpenAPI Specification** - Version 3.0+ required
- **Node.js** - 14+ for OpenAPI Generator CLI
- **Language Runtimes** - Depends on target language(s)

## License

Apache 2.0 - See [LICENSE](./LICENSE) for details

## Resources

- [OpenAPI Generator Documentation](https://openapi-generator.tech/)
- [MCP Specification](https://github.com/modelcontextprotocol/specification)
- [MCP C# SDK](https://github.com/modelcontextprotocol/csharp-sdk)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)
- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)

## Support

- **Issues**: [GitHub Issues](https://github.com/openapi-generator/openapi-generator-mcp/issues)
- **Discussions**: [GitHub Discussions](https://github.com/openapi-generator/openapi-generator-mcp/discussions)
- **Documentation**: See docs/ directory

---

**Built with** ❤️ **by the MCP community**

**Version**: 1.0.0 | **Last Updated**: 2025-10-06
