# VFD Display Control Module

Loadable Kernel Module (LKM) for controlling 4-character VFD/LED display on Meson-VFD Android TV boxes.

**Status**: ✅ Working | ⚙️ Automated CI/CD | 📦 Ready to Deploy

## Features

- ✅ **No kernel modification** - Pure LKM (Loadable Kernel Module)
- ✅ **Simple userspace API** - Echo text to `/sys/kernel/vfd_display/display`
- ✅ **Automated CI/CD** - GitHub Actions compilation
- ✅ **Multi-kernel support** - Works on 5.4, 5.10, 5.15, 6.0, 6.1+
- ✅ **Pre-built releases** - Download compiled .ko files
- ✅ **Full documentation** - Complete usage guide

## Quick Start

### Local Build (3 commands)

```bash
# Clone repository
git clone https://github.com/YOUR_ORG/vfd-display-module.git
cd vfd-display-module

# Build and load
make load

# Test
echo "TEST" > /sys/kernel/vfd_display/display
```

### Using Pre-built Module (from Release)

```bash
# Download from GitHub Releases
wget https://github.com/YOUR_ORG/vfd-display-module/releases/download/v1.0/vfd_display.ko

# Load module
sudo insmod vfd_display.ko

# Use
echo "TEST" > /sys/kernel/vfd_display/display
```

## Usage

### Display Text

```bash
# Simple (if permissions allow)
echo "TEXT" > /sys/kernel/vfd_display/display
echo "1234" > /sys/kernel/vfd_display/display
echo "BOOT" > /sys/kernel/vfd_display/display

# With sudo (if needed)
echo "TEXT" | sudo tee /sys/kernel/vfd_display/display
```

### Check Current Display

```bash
cat /sys/kernel/vfd_display/display
```

### Module Control

```bash
# Load module
sudo insmod vfd_display.ko

# Unload module
sudo rmmod vfd_display

# Check if loaded
lsmod | grep vfd_display
```

### Using Helper Scripts

```bash
# Display with nice output
./vfd_control.sh "TEST"
./vfd_control.sh status
./vfd_control.sh boot
./vfd_control.sh cycle 2 "BOOT" "TEST" "OK  "

# Add bash functions to shell
source .bashrc_vfd_functions
vfd "TEST"
vfd_boot
vfd_time
```

## Repository Structure

```
vfd-display-module/
├── .github/
│   └── workflows/
│       └── build.yml              # GitHub Actions CI/CD
├── vfd_display.c                  # Module source code
├── Makefile                       # Build rules
├── vfd_control.sh                 # Control script
├── .bashrc_vfd_functions          # Bash functions
├── README.md                      # This file
├── CONTRIBUTING.md                # Contribution guide
└── docs/
    ├── USAGE.md                   # Detailed usage
    ├── BUILDING.md                # Build instructions
    ├── API.md                     # API reference
    └── TROUBLESHOOTING.md         # Troubleshooting
```

## Requirements

### To Build

- **GCC** - C compiler
- **Make** - Build tool  
- **Linux headers** - For your kernel version
- **bash** - Shell

Install on Debian/Ubuntu:

```bash
sudo apt-get install build-essential linux-headers-$(uname -r)
```

### To Run

- **Linux kernel** 5.4+ (AArch64)
- **Meson-VFD driver** - Must be in kernel
- **sysfs** - Must be mounted (usually `/sys`)

## Building

### Local Build

```bash
make              # Compile
make load         # Compile and load
make test         # Compile, load, and test
make unload       # Unload module
make clean        # Clean build
```

### GitHub Actions Build

Automatically triggered on:
- Push to `main`, `master`, `develop` branches
- Pull requests
- Manual workflow dispatch

View build status: **Actions** tab

Download artifacts: **Actions** → Select workflow → **Artifacts**

## Pre-built Releases

Pre-compiled modules available for download:

**GitHub Releases**: https://github.com/YOUR_ORG/vfd-display-module/releases

Compiled for:
- Kernel 5.4
- Kernel 5.10
- Kernel 5.15
- Kernel 6.0
- Kernel 6.1

## Installation

### From Source

```bash
git clone https://github.com/YOUR_ORG/vfd-display-module.git
cd vfd-display-module
make
sudo insmod build/vfd_display.ko
```

### From Release (Pre-built)

```bash
# Download
wget https://github.com/YOUR_ORG/vfd-display-module/releases/download/v1.0/vfd_display.ko

# Load
sudo insmod vfd_display.ko
```

### Persistent Loading (systemd)

Create `/etc/systemd/system/vfd-display.service`:

```ini
[Unit]
Description=VFD Display Module
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/insmod /path/to/vfd_display.ko
ExecStop=/sbin/rmmod vfd_display
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Enable:

```bash
sudo systemctl daemon-reload
sudo systemctl enable vfd-display.service
sudo systemctl start vfd-display.service
```

## API Reference

### sysfs Interface

**Path**: `/sys/kernel/vfd_display/display`

**Read**: Display current text
```bash
cat /sys/kernel/vfd_display/display
```

**Write**: Display new text
```bash
echo "TEXT" > /sys/kernel/vfd_display/display
```

**Limits**:
- Max 4 characters
- Padded automatically with spaces
- ASCII characters only

### Kernel API (for other modules)

```c
extern void set_vfd_led_value(const char *text, int flag);
extern void MDrv_TM1623_LED_DISP(int segment, unsigned char byte, int flag);
```

## Examples

### Boot Sequence

```bash
echo "BOOT" > /sys/kernel/vfd_display/display
sleep 1
echo "OK  " > /sys/kernel/vfd_display/display
sleep 1
echo "RUN " > /sys/kernel/vfd_display/display
```

### Display Time

```bash
TIME=$(date +%H%M)
echo "$TIME" > /sys/kernel/vfd_display/display
```

### Continuous Status Loop

```bash
while true; do
  echo "RUN " > /sys/kernel/vfd_display/display
  sleep 5
done
```

### Cycle Messages

```bash
for msg in "BOOT" "TEST" "OK  " "DONE"; do
  echo "$msg" > /sys/kernel/vfd_display/display
  sleep 1
done
```

## Troubleshooting

### "Module not found"

```bash
# Check if module is loaded
lsmod | grep vfd_display

# If not, load it
sudo insmod build/vfd_display.ko
```

### "Permission denied" writing to sysfs

```bash
# Use sudo with tee
echo "TEXT" | sudo tee /sys/kernel/vfd_display/display

# Or change permissions (not recommended)
sudo chmod 666 /sys/kernel/vfd_display/display
```

### "No such file: /sys/kernel/vfd_display/display"

```bash
# Module not loaded - load it
sudo insmod vfd_display.ko

# Wait a moment
sleep 1

# Verify
ls -la /sys/kernel/vfd_display/
```

### Compilation errors

```bash
# Install kernel headers
sudo apt-get install linux-headers-$(uname -r)

# Clean and retry
make clean
make
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Workflow

1. Fork repository
2. Create feature branch (`git checkout -b feature/my-feature`)
3. Make changes
4. Test locally (`make test`)
5. Commit (`git commit -am 'Add feature'`)
6. Push to branch (`git push origin feature/my-feature`)
7. Create Pull Request

## CI/CD Pipeline

GitHub Actions automatically:

1. **Builds** module on every push/PR
2. **Tests** module loading
3. **Creates artifacts** for each kernel version
4. **Publishes releases** when tagged
5. **Generates documentation**

### Workflow Status

- [![Build Status](../../actions/workflows/build.yml/badge.svg)](../../actions/workflows/build.yml)

### View Logs

1. Go to **Actions** tab
2. Select workflow run
3. View detailed logs

### Download Build Artifacts

1. Go to **Actions** tab
2. Select successful workflow
3. Expand "Artifacts" section
4. Download `.ko` file

## Hardware Support

### Tested On

- Meson-VFD (Android TV box)
- AArch64 architecture
- TM1623/TM1628 display controller
- 4-character 7-segment VFD display

### Kernel Versions

- ✅ 5.4+
- ✅ 5.10+
- ✅ 5.15+
- ✅ 6.0+
- ✅ 6.1+

## License

MIT

## Authors

- Main development: [Edytor Studio]
- Reverse engineering: [Contributors]

## Support

### Documentation

- [Building](docs/BUILDING.md)
- [Usage](docs/USAGE.md)
- [API Reference](docs/API.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

### Issue Tracking

Report issues on [GitHub Issues](../../issues)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## Acknowledgments

- Kernel reverse engineering analysis
- Community testing and feedback

---

**Latest Release**: v1.0  
**Last Updated**: 2026-09-29  
**Maintainer**: [@AmakerGame](https://github.com/AmakerGame)
