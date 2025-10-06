# OpenAPI Extensions for MCP Code Generation

This document defines custom OpenAPI extensions (`x-*` fields) used to enhance MCP tool generation from OpenAPI specifications.

## Extension Reference

### Operation-Level Extensions

#### `x-mcp-tool`
Controls MCP tool-specific generation settings.

**Type:** `object`

**Properties:**
- `enabled` (boolean, default: true) - Whether to generate MCP tool for this operation
- `name` (string, optional) - Override tool name (defaults to operationId)
- `category` (string, optional) - Tool category for grouping
- `priority` (integer, optional) - Tool priority for ordering (0-100, default: 50)

**Example:**
```yaml
paths:
  /scene/info:
    get:
      operationId: getSceneInfo
      x-mcp-tool:
        enabled: true
        category: "scene"
        priority: 100
```

#### `x-mcp-examples`
Provides MCP-specific examples for tool usage.

**Type:** `array`

**Items:**
- `description` (string) - Example description
- `input` (object) - Example input parameters
- `output` (object) - Example output response

**Example:**
```yaml
paths:
  /object:
    post:
      operationId: createObject
      x-mcp-examples:
        - description: "Create a cube at origin"
          input:
            type: "Cube"
            position: [0, 0, 0]
          output:
            success: true
            message: "Cube created successfully"
```

### Schema-Level Extensions

#### `x-mcp-input-schema`
Provides JSON Schema overrides for MCP tool input validation.

**Type:** `object`

**Example:**
```yaml
components:
  schemas:
    CreateObjectRequest:
      type: object
      properties:
        type:
          type: string
          enum: ["Cube", "Sphere", "Cylinder"]
      x-mcp-input-schema:
        type: string
        enum: ["Cube", "Sphere", "Cylinder", "Capsule", "Plane"]
        description: "Primitive type to create"
```

### Info-Level Extensions

#### `x-mcp-server`
Defines MCP server metadata.

**Type:** `object`

**Properties:**
- `name` (string) - Server name
- `version` (string) - Server version
- `description` (string) - Server description
- `author` (string) - Server author
- `license` (string) - License identifier

**Example:**
```yaml
info:
  title: Unity Context Bridge API
  version: "1.0.0"
  x-mcp-server:
    name: "unity-context-bridge"
    version: "1.0.0"
    author: "Unity Technologies"
    license: "MIT"
```

### Tag-Level Extensions

#### `x-mcp-category`
Maps OpenAPI tags to MCP tool categories.

**Type:** `object`

**Properties:**
- `name` (string) - Category display name
- `description` (string) - Category description
- `icon` (string, optional) - Icon identifier or emoji

**Example:**
```yaml
tags:
  - name: Scene
    description: Scene management operations
    x-mcp-category:
      name: "Scene Management"
      description: "Tools for managing Unity scenes"
      icon: "🎬"
```

## Usage in Templates

### Accessing Extensions in Mustache

Extensions are available in templates through the vendorExtensions object:

```mustache
{{#vendorExtensions.x-mcp-tool}}
# Tool: {{name}}
Category: {{category}}
Priority: {{priority}}
{{/vendorExtensions.x-mcp-tool}}
```

### Example Template Usage

**Python MCP Tool Template:**
```mustache
{{#vendorExtensions.x-mcp-tool}}
@server.call_tool()
async def {{name}}({{#allParams}}{{paramName}}: {{dataType}}{{^-last}}, {{/-last}}{{/allParams}}) -> str:
    """{{summary}}

    Category: {{category}}
    {{#description}}
    {{.}}
    {{/description}}
    """
    # Implementation
    pass
{{/vendorExtensions.x-mcp-tool}}
```

## Migration Guide

### From Standard OpenAPI to MCP-Enhanced

**Before:**
```yaml
paths:
  /scene/info:
    get:
      operationId: getSceneInfo
      summary: "Retrieve Scene Information"
      tags:
        - Scene
```

**After:**
```yaml
paths:
  /scene/info:
    get:
      operationId: getSceneInfo
      summary: "Retrieve Scene Information"
      tags:
        - Scene
      x-mcp-tool:
        enabled: true
        category: "scene"
        priority: 100
      x-mcp-examples:
        - description: "Get current scene info"
          input: {}
          output:
            sceneName: "MainScene"
            rootObjects: ["Camera", "Light"]
```

## Best Practices

1. **Category Naming:** Use lowercase, hyphenated names (e.g., "scene-management")
2. **Priority Range:** Reserve 90-100 for critical tools, 0-10 for rarely used
3. **Examples:** Provide at least one example per tool
4. **Descriptions:** Keep summaries concise (<100 chars), use notes for details

## Validation

Use the provided validation script to check extension usage:

```bash
./validate-mcp-extensions.sh api/openapi.yaml
```

## Future Extensions

Planned extensions for future versions:

- `x-mcp-resource` - Define MCP resources
- `x-mcp-prompt` - Define MCP prompts
- `x-mcp-sampling` - Define LLM sampling support
- `x-mcp-progress` - Define progress notification support

---

**Version:** 1.0.0
**Last Updated:** 2025-10-06
**Maintainer:** Unity AI-QA Team
