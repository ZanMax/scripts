#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
MAX_ENTRIES=30
CRASH_DIR="/var/crash"

# Print section header
print_header() {
    local title="$1"
    echo -e "\n${BOLD}${CYAN}=== $title ===${NC}"
    echo -e "${GRAY}$(printf '=%.0s' {1..50})${NC}\n"
}

# Print subsection header
print_subheader() {
    local title="$1"
    echo -e "${BOLD}${CYAN}>>> $title${NC}"
}

# Print success message
print_success() {
    echo -e "${GREEN}$1${NC}"
}

# Print warning message
print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

# Print error message
print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check root privileges
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Please run this script as root or with sudo."
        exit 1
    fi
}

# Print system information
print_system_info() {
    print_header "System Information"

    print_subheader "Basic System Details"
    echo -e "${GRAY}Hostname:${NC} $(hostname)"
    echo -e "${GRAY}Kernel:${NC} $(uname -r)"
    if [ -f /etc/os-release ]; then
        echo -e "${GRAY}OS:${NC} $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
    fi

    print_subheader "Hardware Information"
    echo -e "${GRAY}CPU:${NC} $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
    echo -e "${GRAY}Memory:${NC} $(free -h | awk '/Mem:/ {print $2}')"

    print_subheader "Disk Space"
    df -h / | awk 'NR==1{print $0} NR==2{space=$5; sub(/%/,"",space); if(space>90) printf "'${RED}'%s'${NC}'\n",$0; else if(space>80) printf "'${YELLOW}'%s'${NC}'\n",$0; else printf "'${GREEN}'%s'${NC}'\n",$0}'
}

# Print uptime and load information
print_uptime() {
    print_header "System Uptime and Load"
    uptime | awk '{print}' | sed 's/,/\n/g' | sed 's/^[ \t]*//' | \
    while read -r line; do
        echo -e "${GRAY}→${NC} $line"
    done
}

# Print recent crash reports
print_crash_reports() {
    print_header "Recent Crash Reports"
    if [ -d "$CRASH_DIR" ] && [ "$(ls -A $CRASH_DIR)" ]; then
        ls -lh --time-style=long-iso "$CRASH_DIR" | \
        awk 'NR>1{printf "'${GRAY}'%s %s'${NC}' %s\n", $6, $7, $9}'
    else
        print_warning "No crash reports found in $CRASH_DIR"
    fi
}

# Print recent boot logs
print_boot_logs() {
    print_header "Recent Boot Logs"
    if journalctl -b -1 &>/dev/null; then
        journalctl -b -1 --no-pager | tail -n $MAX_ENTRIES | \
        while read -r line; do
            if echo "$line" | grep -qi "error"; then
                echo -e "${RED}$line${NC}"
            elif echo "$line" | grep -qi "warning"; then
                echo -e "${YELLOW}$line${NC}"
            else
                echo -e "${GRAY}$line${NC}"
            fi
        done
    else
        print_warning "Previous boot logs not available"
    fi
}

# Print kernel errors
print_kernel_errors() {
    print_header "Kernel Messages (Errors, Panics, Failures)"
    dmesg --time-format ctime | grep -i "error\|panic\|fail" | tail -n $MAX_ENTRIES | \
    while read -r line; do
        if echo "$line" | grep -qi "panic"; then
            echo -e "${RED}$line${NC}"
        elif echo "$line" | grep -qi "error"; then
            echo -e "${YELLOW}$line${NC}"
        else
            echo -e "${GRAY}$line${NC}"
        fi
    done
}

# Print service status
print_service_status() {
    print_header "Failed Services"
    failed_services=$(systemctl --failed)
    if echo "$failed_services" | grep -q "0 loaded units listed"; then
        print_success "No failed services found"
    else
        echo "$failed_services" | \
        while read -r line; do
            if echo "$line" | grep -q "UNIT"; then
                echo -e "${BOLD}$line${NC}"
            elif echo "$line" | grep -q "failed"; then
                echo -e "${RED}$line${NC}"
            else
                echo -e "$line"
            fi
        done
    fi
}

# Print memory status
print_memory_status() {
    print_header "Memory Status"
    print_subheader "Current Memory Usage"
    free -h | awk 'NR==1{print "'${BOLD}'"$0"'${NC}'"} NR>1{print $0}'

    print_subheader "Top Memory Consumers"
    ps aux --sort=-%mem | head -n 6 | \
    awk 'NR==1{print "'${BOLD}'"$0"'${NC}'"} NR>1{printf "'${GRAY}'%s %s'${NC}' %s\n", $4, $11, $0}'
}

# Function to create header box
print_fancy_box() {
    local title="$1"
    local width=50
    local padding=$(( (width - ${#title}) / 2 ))

    echo -e "${BOLD}${PURPLE}"
    echo "╔$(printf '═%.0s' $(seq 1 $width))╗"
    printf "║%*s%s%*s║\n" $padding "" "$title" $(( padding + (width - ${#title}) % 2 )) ""
    echo -e "╚$(printf '═%.0s' $(seq 1 $width))╝${NC}"
}

# Main execution
main() {
    # Clear screen for better readability
    clear

    # Check root privileges
    check_root

    # Print fancy header
    print_fancy_box "System Crash Analysis Report"
    echo -e "${GRAY}Generated on: $(date)${NC}\n"

    # Run all analysis functions
    print_system_info
    print_uptime
    print_memory_status
    print_crash_reports
    print_boot_logs
    print_kernel_errors
    print_service_status

    # Print footer
    print_fancy_box "Analysis Complete"
}

# Run main function
main