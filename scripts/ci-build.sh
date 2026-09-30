#!/bin/bash

################################################################################
#                   VFD MODULE - GitHub Actions Build Script                  #
#                                                                              #
# This script is designed to run in GitHub Actions CI/CD environment         #
# It handles all build steps and generates artifacts                         #
#                                                                             #
# Usage: bash scripts/ci-build.sh                                            #
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
ARTIFACTS_DIR="$PROJECT_ROOT/artifacts"

# Configuration
MODULE_NAME="vfd_display"
KERNEL_VERSION=$(uname -r)
TARGET_ARCH=$(uname -m)

# Functions
print_header() {
    echo -e "\n${BLUE}════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}║${NC} $1"
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

# Check environment
check_environment() {
    print_header "ENVIRONMENT CHECK"

    print_info "Kernel: $KERNEL_VERSION"
    print_info "Architecture: $TARGET_ARCH"
    print_info "Working directory: $PROJECT_ROOT"

    # Check dependencies
    local missing=0

    if ! command -v gcc &> /dev/null; then
        print_error "gcc not found"
        missing=1
    else
        local gcc_version=$(gcc --version | head -n1)
        print_success "$gcc_version"
    fi

    if ! command -v make &> /dev/null; then
        print_error "make not found"
        missing=1
    else
        print_success "make found"
    fi

    if [ ! -d "/lib/modules/$KERNEL_VERSION/build" ]; then
        print_error "Kernel headers not found for $KERNEL_VERSION"
        missing=1
    else
        print_success "Kernel headers found"
    fi

    if [ $missing -eq 1 ]; then
        print_error "Missing dependencies"
        exit 1
    fi

    print_success "Environment OK"
}

# Create build directories
setup_directories() {
    print_header "SETUP DIRECTORIES"

    mkdir -p "$BUILD_DIR"
    mkdir -p "$ARTIFACTS_DIR"

    print_success "Build directory: $BUILD_DIR"
    print_success "Artifacts directory: $ARTIFACTS_DIR"
}

# Copy source files
copy_sources() {
    print_header "COPY SOURCE FILES"

    cd "$PROJECT_ROOT"

    if [ ! -f "$MODULE_NAME.c" ]; then
        print_error "Source file not found: $MODULE_NAME.c"
        exit 1
    fi

    cp "$MODULE_NAME.c" "$BUILD_DIR/"
    cp Makefile "$BUILD_DIR/"

    print_success "Sources copied to $BUILD_DIR"
    ls -lh "$BUILD_DIR"/"$MODULE_NAME".c
}

# Build module
build_module() {
    print_header "BUILD MODULE"

    cd "$BUILD_DIR"

    print_info "Running make clean..."
    make clean > /dev/null 2>&1 || true

    print_info "Building module..."
    if make > build.log 2>&1; then
        print_success "Build successful"
        
        if [ -f "$MODULE_NAME.ko" ]; then
            print_success "Module created: $MODULE_NAME.ko"
            ls -lh "$MODULE_NAME.ko"
        else
            print_error "Module file not generated"
            cat build.log
            exit 1
        fi
    else
        print_error "Build failed"
        print_info "Build log:"
        cat build.log
        exit 1
    fi
}

# Verify module
verify_module() {
    print_header "VERIFY MODULE"

    cd "$BUILD_DIR"

    if [ ! -f "$MODULE_NAME.ko" ]; then
        print_error "Module file not found"
        exit 1
    fi

    print_info "Module info:"
    file "$MODULE_NAME.ko"

    print_info "Module size:"
    ls -lh "$MODULE_NAME.ko" | awk '{print $5 " - " $9}'

    # Check for expected symbols
    print_info "Checking for kernel symbols..."
    if nm "$MODULE_NAME.ko" | grep -q "set_vfd_led_value"; then
        print_success "Found symbol: set_vfd_led_value"
    else
        print_warning "Symbol not found: set_vfd_led_value"
    fi

    if nm "$MODULE_NAME.ko" | grep -q "MDrv_FrontPnl_Update"; then
        print_success "Found symbol: MDrv_FrontPnl_Update"
    else
        print_warning "Symbol not found: MDrv_FrontPnl_Update"
    fi

    print_success "Module verification complete"
}

# Generate metadata
generate_metadata() {
    print_header "GENERATE METADATA"

    local metadata_file="$BUILD_DIR/metadata.txt"

    cat > "$metadata_file" << EOF
VFD Display Module Build Report
================================

Build Information:
  Date: $(date -u)
  Kernel: $KERNEL_VERSION
  Architecture: $TARGET_ARCH
  GCC Version: $(gcc --version | head -n1)

Module Information:
  Name: $MODULE_NAME
  File: $MODULE_NAME.ko
  Size: $(ls -lh "$BUILD_DIR/$MODULE_NAME.ko" | awk '{print $5}')

Build Status: SUCCESS

Build Directory: $BUILD_DIR
Git Commit: $(git rev-parse HEAD 2>/dev/null || echo "N/A")
Git Branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "N/A")

Symbols Exported:
EOF

    nm "$BUILD_DIR/$MODULE_NAME.ko" | grep " U " >> "$metadata_file" 2>/dev/null || true

    print_success "Metadata generated"
    cat "$metadata_file"
}

# Copy artifacts
copy_artifacts() {
    print_header "COPY ARTIFACTS"

    cd "$BUILD_DIR"

    # Copy module
    if [ -f "$MODULE_NAME.ko" ]; then
        cp "$MODULE_NAME.ko" "$ARTIFACTS_DIR/"
        print_success "Copied module to artifacts"
    fi

    # Copy metadata
    if [ -f "metadata.txt" ]; then
        cp metadata.txt "$ARTIFACTS_DIR/"
        print_success "Copied metadata to artifacts"
    fi

    # Copy build log if exists
    if [ -f "build.log" ]; then
        cp build.log "$ARTIFACTS_DIR/"
        print_success "Copied build log to artifacts"
    fi

    print_info "Artifacts ready:"
    ls -lh "$ARTIFACTS_DIR"
}

# Generate summary
generate_summary() {
    print_header "BUILD SUMMARY"

    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ BUILD SUCCESSFUL${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}\n"

    echo -e "Module: ${YELLOW}$MODULE_NAME.ko${NC}"
    echo -e "Kernel: ${YELLOW}$KERNEL_VERSION${NC}"
    echo -e "Arch: ${YELLOW}$TARGET_ARCH${NC}"
    echo -e "Size: ${YELLOW}$(ls -lh "$BUILD_DIR/$MODULE_NAME.ko" | awk '{print $5}')${NC}"
    echo ""
    echo -e "Artifacts: ${YELLOW}$ARTIFACTS_DIR${NC}"
    ls -lh "$ARTIFACTS_DIR"

    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
}

# Main function
main() {
    echo -e "\n${BLUE}"
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║        VFD DISPLAY MODULE - GitHub Actions Build Script       ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"

    # Run steps
    check_environment
    setup_directories
    copy_sources
    build_module
    verify_module
    generate_metadata
    copy_artifacts
    generate_summary

    print_success "Build pipeline complete!"
    exit 0
}

# Error handler
trap 'print_error "Build failed at line $LINENO"; exit 1' ERR

# Run main
main "$@"
