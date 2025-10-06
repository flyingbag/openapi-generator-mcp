# Contributing to OpenAPI to MCP Generator

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to the project.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Guidelines](#coding-guidelines)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Community](#community)

---

## Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please read [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md) before contributing.

**TL;DR**: Be respectful, inclusive, and professional.

---

## Getting Started

### Ways to Contribute

We welcome contributions in many forms:

- 🐛 **Bug Reports** - Report issues you encounter
- ✨ **Feature Requests** - Suggest new features
- 📝 **Documentation** - Improve or translate docs
- 🔧 **Code** - Fix bugs or add features
- 🧪 **Testing** - Test releases and report findings
- 💡 **Ideas** - Share ideas for improvements
- 🎨 **Templates** - Create templates for new languages
- 📦 **Examples** - Add example implementations

### Good First Issues

Look for issues labeled `good first issue` or `help wanted` to get started.

---

## How to Contribute

### Reporting Bugs

Before creating a bug report, please:

1. **Search existing issues** to avoid duplicates
2. **Check the documentation** for known issues
3. **Try the latest version** to see if it's already fixed

When creating a bug report, include:

```markdown
**Description**: Clear description of the bug

**Steps to Reproduce**:
1. Run command `./generate-mcp-all.sh --languages=python`
2. Check output in `../generated/python-mcp/`
3. Notice error message: ...

**Expected Behavior**: What should happen

**Actual Behavior**: What actually happens

**Environment**:
- OS: macOS 13.5
- Node.js: v20.17.0
- OpenAPI Generator CLI: 7.12.0
- Language: Python 3.10

**Additional Context**: Screenshots, logs, etc.
```

### Suggesting Features

Feature requests are welcome! Please:

1. **Check existing feature requests** first
2. **Explain the use case** clearly
3. **Describe the proposed solution**
4. **Consider alternatives** you've thought about

Template:

```markdown
**Problem**: What problem does this solve?

**Proposed Solution**: How should it work?

**Alternatives**: What other solutions did you consider?

**Additional Context**: Examples, mockups, etc.
```

---

## Development Setup

### Prerequisites

- Node.js 14+
- OpenAPI Generator CLI
- Git
- (Optional) Language runtimes for testing (Python, Go, etc.)

### Clone and Setup

```bash
# Fork the repository on GitHub first

# Clone your fork
git clone https://github.com/YOUR_USERNAME/openapi-generator-mcp.git
cd openapi-generator-mcp

# Add upstream remote
git remote add upstream https://github.com/openapi-generator/openapi-generator-mcp.git

# Install dependencies
npm install -g @openapitools/openapi-generator-cli

# Verify setup
./test-templates.sh
```

### Project Structure

```
openapi-generator-mcp/
├── .github/               # GitHub Actions workflows
├── api/                   # Example OpenAPI specifications
├── config/                # Generator configurations
├── templates/             # Mustache templates
│   ├── mcp/              # C# templates
│   ├── mcp-python/       # Python templates
│   ├── mcp-typescript/   # TypeScript templates
│   └── mcp-go/           # Go templates
├── examples/              # Example implementations
├── scripts/               # Utility scripts
├── schemas/               # JSON schemas
└── docs/                  # Documentation
```

---

## Coding Guidelines

### Template Development

When creating or modifying templates:

1. **Follow language idioms** - Generate idiomatic code for the target language
2. **Use meaningful variable names** - `{{operationId}}` not `{{op}}`
3. **Add comments** - Explain complex template logic
4. **Test thoroughly** - Generate code and verify it works
5. **Document** - Update TEMPLATE_DEVELOPMENT_GUIDE.md

**Template Checklist**:
- [ ] Follows target language style guide
- [ ] Handles edge cases (optional params, arrays, etc.)
- [ ] Includes proper error handling
- [ ] Generates valid, compilable code
- [ ] Documented in TEMPLATE_DEVELOPMENT_GUIDE.md

### Shell Scripts

- Use `#!/usr/bin/env bash` shebang
- Include `set -e` for error handling
- Add descriptive comments
- Use meaningful variable names
- Include help text (`--help`)

### Documentation

- Use clear, concise language
- Include code examples
- Keep line length ≤ 100 characters
- Use proper markdown formatting
- Add table of contents for long docs

---

## Testing

### Before Submitting

Run these commands to ensure quality:

```bash
# 1. Validate OpenAPI spec
./validate-mcp-extensions.sh api/openapi.yaml

# 2. Test templates
./test-templates.sh

# 3. Generate all languages
./generate-mcp-all.sh

# 4. Run all automated tests
./scripts/run-all-tests.sh

# 5. Test specific language (if changed)
./generate-mcp-all.sh --languages=python
python -m py_compile ../generated/python-mcp/petstore_mcp/api/*.py
```

### Adding Tests

When adding features, also add tests:

1. **Unit tests** for template logic
2. **Integration tests** for generation
3. **Examples** demonstrating the feature

---

## Pull Request Process

### Before Creating a PR

1. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make your changes** following our guidelines

3. **Test thoroughly** using the testing section above

4. **Commit with clear messages**:
   ```bash
   git commit -m "Add Go language support for XYZ feature

   - Implement XYZ in Go templates
   - Add tests for XYZ
   - Update documentation"
   ```

5. **Push to your fork**:
   ```bash
   git push origin feature/my-feature
   ```

### Creating the PR

1. Go to the original repository on GitHub
2. Click "New Pull Request"
3. Select your fork and branch
4. Fill in the PR template:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Changes Made
- Added Go language support
- Updated generate-mcp-all.sh
- Added tests

## Testing
- [ ] All tests pass
- [ ] Generated code compiles
- [ ] Documentation updated

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have added tests
- [ ] I have updated documentation
- [ ] All tests pass
```

### PR Review Process

1. **Automated checks** will run (CI/CD)
2. **Maintainers** will review your code
3. **Address feedback** by pushing new commits
4. **Approval** - Once approved, PR will be merged

### After Your PR is Merged

1. **Delete your branch**:
   ```bash
   git branch -d feature/my-feature
   git push origin --delete feature/my-feature
   ```

2. **Update your fork**:
   ```bash
   git checkout main
   git pull upstream main
   git push origin main
   ```

3. **Celebrate!** 🎉 You've contributed!

---

## Coding Guidelines by Component

### Templates (Mustache)

```mustache
{{!-- Good: Descriptive variable names --}}
{{#operations}}
class {{classname}}McpTools:
    """{{description}}"""
{{/operations}}

{{!-- Bad: Unclear variable names --}}
{{#ops}}
class {{name}}:
    """{{desc}}"""
{{/ops}}
```

### Configuration Files (JSON)

```json
{
  "inputSpec": "api/openapi.yaml",
  "generatorName": "python",
  "templateDir": "templates/mcp-python",
  "outputDir": "../generated/python-mcp",
  "packageName": "petstore_mcp"
}
```

**Guidelines**:
- Use meaningful keys
- Include comments (where supported)
- Validate JSON syntax
- Follow existing structure

### Shell Scripts

```bash
#!/usr/bin/env bash

set -e  # Exit on error

# Function description
generate_code() {
    local lang=$1
    local config="config/mcp-${lang}.json"

    echo "Generating ${lang} code..."
    openapi-generator-cli generate -c "$config"
}
```

**Guidelines**:
- Use `local` for function variables
- Quote variables: `"$var"`
- Check for errors
- Provide user feedback

---

## Language-Specific Contributions

### Adding a New Language

1. **Create templates** in `templates/mcp-yourlang/`
2. **Add configuration** in `config/mcp-yourlang.json`
3. **Update generation script** to include your language
4. **Add examples** in `examples/yourlang-mcp-example.*`
5. **Document** in README and guides
6. **Test** thoroughly

See [TEMPLATE_DEVELOPMENT_GUIDE.md](./TEMPLATE_DEVELOPMENT_GUIDE.md) for details.

### Improving Existing Languages

1. **Identify the issue** (bug or improvement)
2. **Modify the template** in `templates/mcp-lang/`
3. **Test generation** with `./generate-mcp-all.sh --languages=lang`
4. **Verify output** is valid and idiomatic
5. **Update tests** if needed
6. **Document changes** in commit message

---

## Community

### Getting Help

- **GitHub Discussions** - Ask questions, share ideas
- **GitHub Issues** - Report bugs, request features
- **Email** - Contact maintainers (see README)

### Stay Connected

- ⭐ Star the repository
- 👀 Watch for updates
- 🐦 Follow on social media
- 📧 Subscribe to announcements

### Recognition

Contributors are recognized in:
- README.md (Contributors section)
- Release notes
- CHANGELOG.md

---

## License

By contributing, you agree that your contributions will be licensed under the Apache 2.0 License.

---

## Questions?

If you have questions about contributing:

1. Check [GETTING_STARTED.md](./GETTING_STARTED.md)
2. Read [README_MCP_GENERATOR.md](./README_MCP_GENERATOR.md)
3. Search [GitHub Discussions](https://github.com/openapi-generator/openapi-generator-mcp/discussions)
4. Create a new discussion if needed

---

Thank you for contributing to OpenAPI to MCP Generator! 🙏

Every contribution, no matter how small, makes a difference.

---

*Last Updated: 2025-10-06*
*Version: 1.0.0*
