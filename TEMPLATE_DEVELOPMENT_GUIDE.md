# MCP Template Development Guide

A comprehensive guide for developing custom OpenAPI Generator templates for Model Context Protocol (MCP) code generation.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Template Structure](#template-structure)
4. [Mustache Basics](#mustache-basics)
5. [Available Variables](#available-variables)
6. [Creating a New Language Template](#creating-a-new-language-template)
7. [Testing Templates](#testing-templates)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)
10. [Advanced Techniques](#advanced-techniques)

## Overview

This guide covers the process of creating custom templates for generating MCP server code from OpenAPI specifications. The template system uses Mustache as the templating engine.

### Architecture

```
OpenAPI Spec → OpenAPI Generator → Mustache Templates → Generated Code
```

**Key Components:**
- **OpenAPI Spec** - Defines REST API operations
- **Mustache Templates** - Transform API definitions into MCP tools
- **Configuration** - Controls generation parameters
- **Post-Processing** - Optional cleanup and organization

## Prerequisites

### Required Tools

```bash
# Node.js (for OpenAPI Generator CLI)
node --version  # v18+

# OpenAPI Generator CLI
npm install -g @openapitools/openapi-generator-cli

# Mustache (for template validation)
npm install -g mustache

# yq (for OpenAPI validation)
brew install yq  # macOS
```

### Knowledge Requirements

- OpenAPI 3.0 specification format
- Mustache template syntax
- Target language (C#, Python, TypeScript, etc.)
- MCP SDK for target language

## Template Structure

### Minimal Template Set

Every language needs at least these templates:

```
templates/mcp-<language>/
├── api.mustache              # MCP tool class generation
├── model.mustache            # Data model generation
├── partial_header.mustache   # File header (license, imports)
└── index.mustache           # Package/module entry point (optional)
```

### Example: Python Template Structure

```
templates/mcp-python/
├── api.mustache              # Tool classes with async methods
├── model.mustache            # Pydantic models
├── partial_header.mustache   # Python file header
├── __init__.mustache         # Package initialization
└── requirements.mustache     # Dependencies (optional)
```

## Mustache Basics

### Syntax Reference

| Syntax | Description | Example |
|--------|-------------|---------|
| `{{variable}}` | Output variable | `{{classname}}` |
| `{{#section}}...{{/section}}` | Conditional section | `{{#hasParams}}...{{/hasParams}}` |
| `{{^section}}...{{/section}}` | Inverted section | `{{^isLibrary}}...{{/isLibrary}}` |
| `{{!comment}}` | Comment (not output) | `{{!This is a comment}}` |
| `{{>partial}}` | Include partial | `{{>partial_header}}` |
| `{{{variable}}}` | Unescaped variable | `{{{description}}}` |

### Common Patterns

**Iteration:**
```mustache
{{#operations}}
{{#operation}}
  Method: {{operationId}}
{{/operation}}
{{/operations}}
```

**Conditional:**
```mustache
{{#hasParams}}
Parameters:
{{#allParams}}
  - {{paramName}}: {{dataType}}
{{/allParams}}
{{/hasParams}}
{{^hasParams}}
No parameters
{{/hasParams}}
```

**Nested Access:**
```mustache
{{#vendorExtensions.x-mcp-tool}}
Category: {{category}}
Priority: {{priority}}
{{/vendorExtensions.x-mcp-tool}}
```

## Available Variables

### Top-Level Variables

| Variable | Type | Description |
|----------|------|-------------|
| `appName` | string | Application name from info.title |
| `appDescription` | string | Application description |
| `version` | string | API version |
| `packageName` | string | Package name from config |
| `sourceFolder` | string | Source folder path |
| `isLibrary` | boolean | Library mode (base classes) |

### API/Operation Variables

| Variable | Type | Description |
|----------|------|-------------|
| `classname` | string | API class name (e.g., PetApi) |
| `baseName` | string | Base name without "Api" suffix |
| `operations` | array | Array of operations |
| `operation` | object | Current operation context |

### Operation Variables

| Variable | Type | Description |
|----------|------|-------------|
| `operationId` | string | Operation identifier |
| `summary` | string | Short summary |
| `notes` | string | Full description |
| `httpMethod` | string | HTTP method (GET, POST, etc.) |
| `path` | string | URL path |
| `returnType` | string | Return type name |
| `hasParams` | boolean | Has parameters |
| `allParams` | array | All parameters |
| `bodyParam` | object | Body parameter |
| `hasRequiredParams` | boolean | Has required parameters |

### Parameter Variables

| Variable | Type | Description |
|----------|------|-------------|
| `paramName` | string | Parameter name |
| `dataType` | string | Parameter type |
| `description` | string | Parameter description |
| `required` | boolean | Is required |
| `isString` | boolean | Is string type |
| `isInteger` | boolean | Is integer type |
| `isBoolean` | boolean | Is boolean type |
| `isArray` | boolean | Is array type |
| `isEnum` | boolean | Is enum type |

### Model Variables

| Variable | Type | Description |
|----------|------|-------------|
| `models` | array | Array of models |
| `model` | object | Current model context |
| `classname` | string | Model class name |
| `vars` | array | Model properties |
| `isEnum` | boolean | Is enum type |

### Property Variables

| Variable | Type | Description |
|----------|------|-------------|
| `name` | string | Property name |
| `baseName` | string | JSON property name |
| `dataType` | string | Property type |
| `description` | string | Property description |
| `required` | boolean | Is required |
| `defaultValue` | string | Default value |
| `example` | string | Example value |

## Creating a New Language Template

### Step 1: Create Template Directory

```bash
cd openapitools/templates
mkdir mcp-<language>
cd mcp-<language>
```

### Step 2: Create `api.mustache`

This template generates MCP tool classes:

```mustache
{{>partial_header}}

import { Server } from "mcp-sdk";
import { Tool } from "mcp-sdk/types";

{{#operations}}
export class {{classname}}McpTool {
  constructor(private server: Server) {
    this.registerTools();
  }

  private registerTools() {
    {{#operation}}
    this.server.addTool({
      name: "{{operationId}}",
      description: "{{{notes}}}",
      inputSchema: {
        type: "object",
        properties: {
          {{#allParams}}
          {{paramName}}: { type: "{{dataType}}" },
          {{/allParams}}
        }
      }
    }, this.{{operationId}}.bind(this));
    {{/operation}}
  }

  {{#operation}}
  async {{operationId}}(args: any) {
    // TODO: Implement
    return { success: true };
  }
  {{/operation}}
}
{{/operations}}
```

### Step 3: Create `model.mustache`

This template generates data models:

```mustache
{{>partial_header}}

{{#models}}
{{#model}}
{{#isEnum}}
export enum {{classname}} {
  {{#allowableValues}}
  {{#enumVars}}
  {{name}} = "{{value}}",
  {{/enumVars}}
  {{/allowableValues}}
}
{{/isEnum}}
{{^isEnum}}
export interface {{classname}} {
  {{#vars}}
  {{baseName}}{{^required}}?{{/required}}: {{dataType}};
  {{/vars}}
}
{{/isEnum}}
{{/model}}
{{/models}}
```

### Step 4: Create `partial_header.mustache`

Standard file header:

```mustache
/**
 * {{appName}}
 * {{appDescription}}
 *
 * OpenAPI spec version: {{version}}
 * Generated by: https://github.com/openapitools/openapi-generator.git
 */
```

### Step 5: Create Configuration

Create `config/mcp-<language>.json`:

```json
{
  "inputSpec": "api/openapi.yaml",
  "generatorName": "<language>",
  "templateDir": "templates/mcp-<language>",
  "outputDir": "../generated/<language>-mcp",
  "packageName": "petstore_mcp",
  "isLibrary": true
}
```

### Step 6: Test Generation

```bash
cd openapitools
./generate-mcp-all.sh --languages=<language> --dry-run
```

## Testing Templates

### Manual Testing

```bash
# Dry run
./generate-mcp-all.sh --languages=<language> --dry-run

# Actual generation
./generate-mcp-all.sh --languages=<language>

# Review output
ls -la ../generated/<language>-mcp/
```

### Automated Testing

```bash
# Run template tests
./test-templates.sh

# Validate OpenAPI extensions
./validate-mcp-extensions.sh api/openapi.yaml
```

### Test Checklist

- ✅ Templates generate valid code
- ✅ No mustache syntax errors
- ✅ Imports are correct
- ✅ Type mappings are accurate
- ✅ Required vs optional parameters handled
- ✅ Error handling present
- ✅ Comments/documentation generated

## Best Practices

### 1. **Use Descriptive Names**

```mustache
<!-- Good -->
{{#operation}}
async {{operationId}}(arguments: Arguments): Promise<Result> {

<!-- Bad -->
{{#operation}}
async {{operationId}}(args: any): Promise<any> {
```

### 2. **Handle Optional Fields**

```mustache
{{#allParams}}
{{paramName}}{{^required}}?{{/required}}: {{dataType}}
{{/allParams}}
```

### 3. **Preserve Type Safety**

```mustache
<!-- TypeScript -->
export interface {{classname}} {
  {{#vars}}
  {{baseName}}: {{dataType}}{{#isNullable}} | null{{/isNullable}};
  {{/vars}}
}

<!-- Python -->
class {{classname}}(BaseModel):
  {{#vars}}
  {{name}}: {{^required}}Optional[{{/required}}{{dataType}}{{^required}}]{{/required}}
  {{/vars}}
```

### 4. **Add Error Handling**

```mustache
{{#operation}}
async {{operationId}}(args: Arguments) {
  try {
    // Implementation
  } catch (error) {
    return { success: false, error: error.message };
  }
}
{{/operation}}
```

### 5. **Include Documentation**

```mustache
{{#operation}}
/**
 * {{summary}}
 * {{#notes}}
 *
 * {{.}}
 * {{/notes}}
 */
async {{operationId}}() {
```

### 6. **Support Library vs Implementation Modes**

```mustache
{{#isLibrary}}
// Generate abstract base class
export abstract class {{classname}}McpToolBase {
  protected abstract {{operationId}}(): Promise<Result>;
}
{{/isLibrary}}
{{^isLibrary}}
// Generate concrete implementation
export class {{classname}}McpTool {
  async {{operationId}}(): Promise<Result> {
    // Implementation
  }
}
{{/isLibrary}}
```

## Troubleshooting

### Issue: Undefined Variable

**Symptom:** Template generates empty output

**Solution:**
```bash
# Debug with --verbose
openapi-generator-cli generate -c config/mcp-<language>.json --verbose

# Check available variables
openapi-generator-cli config-help -g <language>
```

### Issue: Incorrect Type Mapping

**Symptom:** Wrong data types in generated code

**Solution:** Check type mapping in config:

```json
{
  "typeMappings": {
    "integer": "number",
    "string": "str"
  }
}
```

### Issue: Missing Imports

**Symptom:** Generated code has undefined references

**Solution:** Add import logic:

```mustache
{{#hasImport}}
import {
{{#imports}}
  {{import}},
{{/imports}}
} from "./models";
{{/hasImport}}
```

### Issue: Template Syntax Error

**Symptom:** Generation fails with parse error

**Solution:** Validate mustache syntax:

```bash
# Check for unclosed tags
grep -E '{{[^}]*$' templates/mcp-<language>/api.mustache

# Validate with mustache CLI
mustache templates/mcp-<language>/api.mustache
```

## Advanced Techniques

### Custom Lambda Functions

Define custom functions in config:

```json
{
  "additionalProperties": {
    "lambda.camelcase": "{{#lambda.camelcase}}{{name}}{{/lambda.camelcase}}"
  }
}
```

### Conditional Generation

Use vendor extensions:

```mustache
{{#vendorExtensions.x-mcp-tool}}
  {{#enabled}}
  // Generate tool
  {{/enabled}}
{{/vendorExtensions.x-mcp-tool}}
```

### Multi-File Generation

Configure additional files:

```json
{
  "supportingFiles": [
    {
      "templateFile": "README.mustache",
      "destinationFilename": "README.md"
    }
  ]
}
```

### Post-Processing Hooks

Add bash post-processing:

```bash
# In generate-mcp-all.sh
post_process_<language>() {
  # Format code
  prettier --write "../generated/<language>-mcp/**/*.ts"

  # Rename files
  find "../generated/<language>-mcp" -name "*Api.ts" -exec rename 's/Api/McpTool/' {} \;
}
```

## Reference Templates

### Complete Python Example

See: `templates/mcp-python/api.mustache`

Key features:
- Async/await pattern
- Pydantic models
- Type hints
- Error handling
- MCP SDK integration

### Complete TypeScript Example

See: `templates/mcp-typescript/api.mustache`

Key features:
- ESM modules
- TypeScript interfaces
- Type guards
- Async/await
- MCP SDK integration

### Complete C# Example

See: `templates/mcp-csharp/api.mustache`

Key features:
- Abstract base classes
- Async Task pattern
- Newtonsoft.Json
- MCP attributes
- XML documentation

## Contributing

### Adding a New Language

1. Create template directory
2. Implement required templates
3. Create configuration
4. Add to `generate-mcp-all.sh`
5. Add test cases to `test-templates.sh`
6. Update documentation
7. Submit PR

### Template Review Checklist

- [ ] Valid mustache syntax
- [ ] All required templates present
- [ ] Configuration file included
- [ ] Tests pass
- [ ] Generated code compiles
- [ ] MCP SDK integration works
- [ ] Documentation updated
- [ ] Examples provided

## Resources

- [OpenAPI Generator Docs](https://openapi-generator.tech/docs/templating)
- [Mustache Manual](https://mustache.github.io/mustache.5.html)
- [MCP Specification](https://github.com/modelcontextprotocol/specification)
- [Template Examples](./templates/)

---

**Version:** 1.0.0
**Last Updated:** 2025-10-06
