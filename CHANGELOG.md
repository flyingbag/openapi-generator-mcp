# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2025-10-06

### Added
- ✅ Multi-language MCP server code generation (C#, Python, TypeScript)
- ✅ Custom OpenAPI extensions for MCP metadata (`x-mcp-server`, `x-mcp-category`, `x-mcp-tool`)
- ✅ Petstore API example with full MCP annotations (19 operations)
- ✅ Mustache templates for all three languages
- ✅ Multi-language generation script (`generate-mcp-all.sh`)
- ✅ OpenAPI + MCP extension validator (`validate-mcp-extensions.sh`)
- ✅ Template testing framework (`test-templates.sh`)
- ✅ Comprehensive documentation (README, MCP_EXTENSIONS, TEMPLATE_DEVELOPMENT_GUIDE)
- ✅ Working Python example with httpx client
- ✅ Working TypeScript example with fetch API
- ✅ `.gitignore` for generated files

### Changed
- Update API to generic Petstore API
- Updated all configuration files to use Petstore naming
- Updated example files to demonstrate real API calls

### Fixed
- Added missing `licenseInfo.mustache` partial for Python templates

### Removed
- Unity-specific generator scripts
- `.meta` files (Unity metadata)
- `.idea` directory

## Roadmap

### Phase 2 (Next)
- [ ] Fix Python template import generation
- [ ] Add Go language support
- [ ] Enhanced validation with JSON Schema
- [ ] Complete working examples with tests

### Phase 3 (Future)
- [ ] Custom Java generator module
- [ ] MCP Resources and Prompts support
- [ ] Contribute to OpenAPI Generator project
- [ ] Additional languages (Kotlin, Rust, Java)
