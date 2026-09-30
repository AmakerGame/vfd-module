#!/bin/bash

#################################################################################
#                       VFD DISPLAY CONTROL SCRIPT                             #
#                                                                               #
# This script provides easy command-line control of the VFD display           #
# Requirements: vfd_display.ko module loaded (run: make load)                 #
#                                                                               #
# Usage:
#   ./vfd_control.sh "TEXT"       - Display text (up to 4 chars, pad with space)
#   ./vfd_control.sh status        - Show current display text
#   ./vfd_control.sh boot          - Show BOOT message
#   ./vfd_control.sh cycle "TEXT1" "TEXT2" ...  - Cycle through messages
#################################################################################

set -e

VFD_PATH="/sys/kernel/vfd_display/display"
VFD_MODULE="vfd_display"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if module is loaded
check_module_loaded() {
    if ! lsmod | grep -q "^${VFD_MODULE}"; then
        echo -e "${RED}ERROR: VFD module not loaded!${NC}"
        echo "Run: cd /path/to/vfd_display && make load"
        exit 1
    fi
}

# Function to check if sysfs interface exists
check_sysfs() {
    if [ ! -w "$VFD_PATH" ]; then
        echo -e "${RED}ERROR: VFD sysfs interface not available!${NC}"
        echo "Make sure you have write permissions to: $VFD_PATH"
        exit 1
    fi
}

# Function to display text on VFD
display_text() {
    local text="$1"
    local len=${#text}

    # Validate input
    if [ -z "$text" ]; then
        echo -e "${RED}ERROR: Empty text provided${NC}"
        return 1
    fi

    if [ $len -gt 4 ]; then
        echo -e "${BLUE}INFO: Text longer than 4 chars, truncating: '$text' -> '${text:0:4}'${NC}"
        text="${text:0:4}"
    fi

    # Pad with spaces if shorter than 4 chars
    if [ $len -lt 4 ]; then
        text=$(printf "%-4s" "$text")
        echo -e "${BLUE}INFO: Padded to 4 chars: '$text'${NC}"
    fi

    # Write to VFD
    echo -n "$text" | sudo tee "$VFD_PATH" > /dev/null
    
    echo -e "${GREEN}✓ Display updated: '$text'${NC}"
}

# Function to show current display
show_status() {
    echo -e "${BLUE}Current VFD display:${NC}"
    echo -n "  "
    cat "$VFD_PATH"
}

# Function to cycle through messages
cycle_messages() {
    local interval="${1:-2}"
    shift
    local messages=("$@")

    if [ ${#messages[@]} -eq 0 ]; then
        echo -e "${RED}ERROR: No messages provided for cycling${NC}"
        return 1
    fi

    echo -e "${BLUE}Cycling through ${#messages[@]} messages (${interval}s each)...${NC}"
    
    while true; do
        for msg in "${messages[@]}"; do
            display_text "$msg"
            sleep "$interval"
        done
    done
}

# Function to show boot message
show_boot() {
    echo -e "${BLUE}Showing boot sequence...${NC}"
    
    display_text "BOOT"
    sleep 1
    display_text "OK  "
    sleep 1
    display_text "RUN "
    sleep 1
    display_text "....";
}

# Function to show help
show_help() {
    cat << 'EOF'

╔════════════════════════════════════════════════════════════════╗
║         VFD DISPLAY CONTROL SCRIPT - HELP                      ║
╚════════════════════════════════════════════════════════════════╝

USAGE:
    ./vfd_control.sh COMMAND [ARGUMENTS]

COMMANDS:

    "TEXT"              Display text (max 4 characters)
                        Examples:
                            ./vfd_control.sh "TEST"
                            ./vfd_control.sh "1234"
                            ./vfd_control.sh "HI"      (auto-padded to "HI  ")

    status              Show current display text
                        Example:
                            ./vfd_control.sh status

    boot                Show boot sequence (BOOT → OK → RUN → ....)
                        Example:
                            ./vfd_control.sh boot

    cycle INTERVAL MSG1 MSG2 ...
                        Cycle through messages with interval (seconds)
                        Example:
                            ./vfd_control.sh cycle 2 "TEST" "BOOT" "OK  "
                            (shows each message for 2 seconds)

    test                Run comprehensive tests
                        Example:
                            ./vfd_control.sh test

    help                Show this help message

REQUIREMENTS:

    1. VFD module must be loaded:
       cd /path/to/vfd_display
       make load

    2. User must have write access to /sys/kernel/vfd_display/display
       (or run with sudo)

EXAMPLES:

    # Display simple text
    ./vfd_control.sh "1234"
    ./vfd_control.sh "TEST"

    # Display with auto-padding
    ./vfd_control.sh "HI"        (becomes "HI  ")
    ./vfd_control.sh "BOOT"      (becomes "BOOT")

    # Check current display
    ./vfd_control.sh status

    # Boot sequence
    ./vfd_control.sh boot

    # Cycle messages every 3 seconds
    ./vfd_control.sh cycle 3 "BOOT" "TEST" "OK  " "RUN "

    # Run tests
    ./vfd_control.sh test

════════════════════════════════════════════════════════════════════

EOF
}

# Function to run tests
run_tests() {
    echo -e "${BLUE}Running VFD Display Tests...${NC}\n"

    local tests=(
        "TEST"
        "1234"
        "BOOT"
        "HI  "
        "....".
        "----"
        "    "
        "STOP"
    )

    for test_text in "${tests[@]}"; do
        echo -e "${BLUE}→${NC} Displaying: '$test_text'"
        display_text "$test_text"
        sleep 0.5
    done

    echo -e "\n${GREEN}✓ All tests completed!${NC}"
}

# Main script logic
main() {
    # Check if module is loaded
    check_module_loaded
    check_sysfs

    # Parse arguments
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    case "$1" in
        help|-h|--help)
            show_help
            ;;
        status)
            show_status
            ;;
        boot)
            show_boot
            ;;
        cycle)
            if [ $# -lt 3 ]; then
                echo -e "${RED}ERROR: cycle requires INTERVAL and at least one MESSAGE${NC}"
                echo "Usage: ./vfd_control.sh cycle INTERVAL MSG1 [MSG2 ...]"
                exit 1
            fi
            shift
            interval="$1"
            shift
            cycle_messages "$interval" "$@"
            ;;
        test)
            run_tests
            ;;
        *)
            # Treat as text to display
            display_text "$1"
            ;;
    esac
}

# Run main function
main "$@"
