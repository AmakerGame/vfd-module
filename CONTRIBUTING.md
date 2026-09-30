# Contributing to VFD Display Module

Thank you for your interest in contributing! This document provides guidelines and instructions.

## Code of Conduct

Be respectful, inclusive, and professional in all interactions.

## How to Contribute

### Reporting Bugs

1. Check existing [Issues](../../issues) to avoid duplicates
2. Include:
   - Kernel version (`uname -r`)
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - Error messages/logs

Example:
```
Title: VFD display not working on kernel 6.1
Kernel: 6.1.0-generic
Steps:
1. Load module: sudo insmod vfd_display.ko
2. Try to display: echo "TEST" > /sys/kernel/vfd_display/display
3. Error: Permission denied

Expected: Text displayed on VFD
Actual: sysfs write failed
```

### Suggesting Features

1. Check existing discussions
2. Describe the feature clearly
3. Explain the use case
4. Include examples if applicable

### Submitting Code

#### Development Setup

```bash
# Fork repository on GitHub
git clone https://github.com/YOUR_USERNAME/vfd-display-module.git
cd vfd-display-module

# Create feature branch
git checkout -b feature/my-feature

# Make changes
# ...

# Test
make clean
make test
```

#### Code Style

- Follow Linux kernel coding style
- Use 4-space indentation
- Keep lines under 100 characters
- Comment complex logic

Example:
```c
/* Function to display text on VFD
 * Returns: 0 on success, negative on error
 */
static int display_text(const char *text) {
    if (!text) {
        pr_err("Text cannot be NULL\n");
        return -EINVAL;
    }
    
    // Your code here
    return 0;
}
```

#### Commit Messages

Write clear, descriptive commit messages:

```
Add support for multi-line text display

- Implement text buffering for longer messages
- Add character scrolling animation
- Update sysfs interface documentation

Fixes #123
```

#### Testing

Before submitting PR:

```bash
# Build
make clean && make

# Test locally
sudo insmod build/vfd_display.ko
echo "TEST" > /sys/kernel/vfd_display/display
sudo rmmod vfd_display

# Run full test suite
make test
```

#### Pull Request Process

1. **Fork** repository
2. **Create** feature branch (`git checkout -b feature/feature-name`)
3. **Make** changes
4. **Commit** with clear messages
5. **Push** to your fork
6. **Open** Pull Request with:
   - Clear description of changes
   - Reference to related issues (#123)
   - Testing results
   - Screenshots/logs if applicable

Example PR description:
```
## Description
Add support for custom character mappings

## Type of Change
- [x] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [x] Tested on kernel 5.15
- [x] Tested on kernel 6.1
- [ ] Tested on ARM64
- [x] Module loads successfully
- [x] Display commands work

## Checklist
- [x] Code follows style guidelines
- [x] I have tested this locally
- [x] Documentation updated
- [x] No breaking changes
```

## Development Workflow

### Directory Structure

```
vfd-display-module/
├── .github/workflows/       # CI/CD workflows
├── scripts/                 # Build and utility scripts
├── docs/                    # Documentation
├── vfd_display.c            # Module source
├── Makefile                 # Build configuration
└── vfd_control.sh          # Control script
```

### Building Locally

```bash
# Full build
make all

# Build with verbose output
make V=1

# Build for specific kernel
KERNELDIR=/path/to/kernel make

# Clean build
make clean
make
```

### Testing

```bash
# Unit tests (if available)
make test

# Integration test
sudo make load_test

# Manual test
sudo insmod vfd_display.ko
echo "TEST" > /sys/kernel/vfd_display/display
lsmod | grep vfd_display
sudo rmmod vfd_display
```

### Documentation

When adding features, update documentation:

- **Code comments** - Explain complex logic
- **README.md** - Update if user-facing changes
- **docs/USAGE.md** - Add usage examples
- **docs/API.md** - Document new APIs

## Debugging

### Enable Debug Output

```bash
# In kernel
dmesg -w  # Watch kernel logs

# In module (modify vfd_display.c)
pr_debug("Debug message\n");
pr_info("Info message\n");
pr_err("Error message\n");

# Build with debug symbols
make CFLAGS="-g -O0"
```

### Kernel Modules Debugging

```bash
# Load with debug
sudo insmod vfd_display.ko debug=1

# View module info
modinfo vfd_display.ko

# Check module symbols
nm vfd_display.ko | grep set_vfd_led_value

# View module references
grep -r "vfd_display" /sys/module/
```

## CI/CD Integration

### GitHub Actions

The repository uses GitHub Actions for automated:
- **Building** on push/PR
- **Testing** across kernel versions
- **Artifact generation**
- **Release publishing**

View workflow: `.github/workflows/build.yml`

### Local CI Testing

Run locally to preview CI behavior:

```bash
# Simulate CI build
bash scripts/ci-build.sh

# Check artifacts
ls -lh artifacts/
```

## Documentation

### Writing Documentation

- Use Markdown (.md) files
- Keep language clear and simple
- Include code examples
- Update table of contents

Template:
```markdown
# Feature Name

## Overview
Brief description

## Usage
```bash
# Example code
```

## Troubleshooting
Common issues and solutions
```

## Performance Considerations

- Keep module size small
- Minimize memory allocations
- Avoid busy-waiting loops
- Use efficient kernel APIs

## Security

- No buffer overflows
- Validate user input
- Use safe kernel functions
- Follow kernel security practices

## Compatibility

Test across kernel versions:
- 5.4 LTS
- 5.10 LTS
- 5.15 LTS
- 6.0
- 6.1+

## Release Process

### Version Numbering
Use semantic versioning: `MAJOR.MINOR.PATCH`

Examples:
- v1.0.0 - Initial release
- v1.1.0 - New feature
- v1.1.1 - Bug fix

### Creating Release

1. Update CHANGELOG.md
2. Tag commit: `git tag v1.0.0`
3. Push tag: `git push origin v1.0.0`
4. GitHub Actions creates Release
5. Upload built artifacts

## Contact

- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions
- **Email**: [maintainer@email.com](mailto:maintainer@email.com)

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

**Thank you for contributing!** 🎉
