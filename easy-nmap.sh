#!/bin/bash

# ============================================================
# easy-nmap.sh v2
# Beginner-friendly Nmap automation
#
# Supports:
#   - Single IP / hostname / subdomain
#   - Target files
#   - Multiple scan profiles
#   - Custom ports
#   - TCP / UDP scanning
#   - Organized timestamped reports
#   - TXT / XML / Grepable output
#
# Usage:
#   ./easy-nmap.sh
#   ./easy-nmap.sh 192.168.1.10
#   ./easy-nmap.sh example.com --profile full
#   ./easy-nmap.sh targets.txt --profile quick
#   ./easy-nmap.sh example.com --ports 80,443
#
# Use only against systems you are authorized to test.
# ============================================================

set -u

# ============================================================
# Colors
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

# ============================================================
# Banner
# ============================================================

banner() {
    clear

    if command -v figlet >/dev/null 2>&1; then
        echo -e "${CYAN}"
        figlet "r4vindra"
        echo -e "${NC}"
    else
        echo -e "${CYAN}"
        echo "=========================================="
        echo "             r4vindra"
        echo "          EASY NMAP v2"
        echo "=========================================="
        echo -e "${NC}"
    fi

    echo -e "${WHITE}Professional Nmap Enumeration Framework${NC}"
    echo -e "${GRAY}IP | Hostname | Subdomain | Target List${NC}"
    echo
}

# ============================================================
# Usage
# ============================================================

usage() {
    echo
    echo -e "${WHITE}Usage:${NC}"
    echo
    echo "  $0 [TARGET] [OPTIONS]"
    echo "  $0 [TARGET_FILE] [OPTIONS]"
    echo
    echo -e "${WHITE}Examples:${NC}"
    echo
    echo "  $0 192.168.1.10"
    echo "  $0 example.com"
    echo "  $0 targets.txt"
    echo "  $0 example.com --profile quick"
    echo "  $0 example.com --profile full"
    echo "  $0 example.com --ports 22,80,443"
    echo "  $0 example.com --all-ports"
    echo "  $0 example.com --profile udp"
    echo
    echo -e "${WHITE}Profiles:${NC}"
    echo
    echo "  quick       Fast common-port scan"
    echo "  standard    Service/version + default scripts"
    echo "  full        All TCP ports + service enumeration"
    echo "  aggressive  Full enumeration + OS detection"
    echo "  web         Common web ports"
    echo "  udp         Common UDP ports"
    echo "  custom      User-defined ports"
    echo
    echo -e "${WHITE}Options:${NC}"
    echo
    echo "  --profile PROFILE"
    echo "  --ports PORTS"
    echo "  --all-ports"
    echo "  --udp"
    echo "  --no-ping"
    echo "  --timing 1-5"
    echo "  -h, --help"
    echo
}

# ============================================================
# Logging helpers
# ============================================================

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[+]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[-]${NC} $1"
}

section() {
    echo
    echo -e "${MAGENTA}============================================================${NC}"
    echo -e "${WHITE}$1${NC}"
    echo -e "${MAGENTA}============================================================${NC}"
}

# ============================================================
# Dependency check
# ============================================================

check_dependencies() {

    section "Checking Dependencies"

    if ! command -v nmap >/dev/null 2>&1; then
        error "Nmap is not installed."
        echo
        echo "Install it with:"
        echo
        echo "  sudo apt update && sudo apt install nmap"
        echo
        exit 1
    fi

    success "Nmap found: $(nmap --version | head -n 1)"

    if ! command -v figlet >/dev/null 2>&1; then
        warning "figlet is not installed. Using text banner."
    fi
}

# ============================================================
# Root check
# ============================================================

check_privileges() {

    if [ "$EUID" -eq 0 ]; then
        success "Running with root privileges."
    else
        warning "Not running as root."
        echo
        echo "Some Nmap features such as SYN scanning and OS detection"
        echo "may require elevated privileges."
        echo
    fi
}

# ============================================================
# Validate target
# ============================================================

validate_target() {

    local target="$1"

    if [ -z "$target" ]; then
        return 1
    fi

    # Target file
    if [ -f "$target" ]; then
        return 0
    fi

    # Basic hostname/IP validation
    if [[ "$target" =~ ^[a-zA-Z0-9._:/-]+$ ]]; then
        return 0
    fi

    return 1
}

# ============================================================
# Read target
# ============================================================

get_target() {

    local target="$1"

    if [ -n "$target" ]; then
        if ! validate_target "$target"; then
            error "Invalid target: $target"
            exit 1
        fi

        TARGET="$target"
        return
    fi

    echo
    read -rp "$(echo -e "${CYAN}Enter target IP / hostname / subdomain / target file: ${NC}")" TARGET

    if ! validate_target "$TARGET"; then
        error "Invalid target."
        exit 1
    fi
}

# ============================================================
# Choose profile
# ============================================================

choose_profile() {

    echo
    section "Select Scan Profile"

    echo -e "${WHITE}1)${NC} Quick"
    echo "   Fast common-port discovery"
    echo
    echo -e "${WHITE}2)${NC} Standard"
    echo "   Service/version detection + default NSE scripts"
    echo
    echo -e "${WHITE}3)${NC} Full"
    echo "   Scan all TCP ports + service enumeration"
    echo
    echo -e "${WHITE}4)${NC} Aggressive"
    echo "   Full TCP scan + OS/version detection + scripts + traceroute"
    echo
    echo -e "${WHITE}5)${NC} Web"
    echo "   Focus on common HTTP/HTTPS ports"
    echo
    echo -e "${WHITE}6)${NC} UDP"
    echo "   Common UDP service discovery"
    echo
    echo -e "${WHITE}7)${NC} Custom"
    echo "   Enter your own port list"
    echo

    read -rp "$(echo -e "${CYAN}Choose [1-7]: ${NC}")" choice

    case "$choice" in

        1)
            PROFILE="quick"
            ;;

        2)
            PROFILE="standard"
            ;;

        3)
            PROFILE="full"
            ;;

        4)
            PROFILE="aggressive"
            ;;

        5)
            PROFILE="web"
            ;;

        6)
            PROFILE="udp"
            ;;

        7)
            PROFILE="custom"
            ;;

        *)
            error "Invalid selection."
            exit 1
            ;;
    esac
}

# ============================================================
# Build Nmap command
# ============================================================

build_command() {

    NMAP_ARGS=()

    case "$PROFILE" in

        quick)

            NMAP_ARGS+=(
                "-T4"
                "-sS"
                "--top-ports" "1000"
                "-sV"
            )
            ;;

        standard)

            NMAP_ARGS+=(
                "-T4"
                "-sS"
                "-sV"
                "-sC"
            )
            ;;

        full)

            NMAP_ARGS+=(
                "-T4"
                "-sS"
                "-p-"
                "-sV"
                "-sC"
            )
            ;;

        aggressive)

            NMAP_ARGS+=(
                "-T4"
                "-sS"
                "-p-"
                "-A"
            )
            ;;

        web)

            NMAP_ARGS+=(
                "-T4"
                "-sS"
                "-sV"
                "-sC"
                "-p"
                "80,81,443,444,591,593,8000,8008,8080,8081,8443,8888,9000"
            )
            ;;

        udp)

            NMAP_ARGS+=(
                "-T4"
                "-sU"
                "--top-ports"
                "100"
                "-sV"
            )
            ;;

        custom)

            if [ -z "${CUSTOM_PORTS:-}" ]; then
                read -rp "$(echo -e "${CYAN}Enter ports (example: 22,80,443,8000-8100): ${NC}")" CUSTOM_PORTS
            fi

            if [ -z "$CUSTOM_PORTS" ]; then
                error "No ports specified."
                exit 1
            fi

            NMAP_ARGS+=(
                "-T4"
                "-sS"
                "-p"
                "$CUSTOM_PORTS"
                "-sV"
                "-sC"
            )
            ;;

        *)

            error "Unknown scan profile."
            exit 1
            ;;
    esac

    # Additional options

    if [ "$NO_PING" = "yes" ]; then
        NMAP_ARGS+=("-Pn")
    fi

    if [ -n "$TIMING" ]; then
        # Replace existing timing option
        for i in "${!NMAP_ARGS[@]}"; do
            if [ "${NMAP_ARGS[$i]}" = "-T4" ]; then
                NMAP_ARGS[$i]="-T$TIMING"
            fi
        done
    fi

    # Output files are added later
}

# ============================================================
# Create report directory
# ============================================================

create_output_directory() {

    BASE_DIR="nmap-reports"

    mkdir -p "$BASE_DIR"

    timestamp=$(date +"%Y%m%d_%H%M%S")

    if [ -f "$TARGET" ]; then
        target_name=$(basename "$TARGET")
    else
        target_name=$(echo "$TARGET" | sed 's#[/:]#_#g')
    fi

    REPORT_DIR="$BASE_DIR/${target_name}_${timestamp}"

    mkdir -p "$REPORT_DIR"

    success "Report directory: $REPORT_DIR"
}

# ============================================================
# Run scan
# ============================================================

run_scan() {

    section "Scan Configuration"

    echo -e "${WHITE}Target:${NC}       $TARGET"
    echo -e "${WHITE}Profile:${NC}      $PROFILE"
    echo -e "${WHITE}Output:${NC}       $REPORT_DIR"
    echo

    echo -e "${GRAY}Nmap arguments:${NC}"
    printf '%q ' "${NMAP_ARGS[@]}"
    echo
    echo

    read -rp "$(echo -e "${YELLOW}Start scan? [Y/n]: ${NC}")" confirm

    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        warning "Scan cancelled."
        exit 0
    fi

    section "Starting Nmap"

    start_time=$(date +%s)

    # ========================================================
    # Output files
    # ========================================================

    NORMAL_OUTPUT="$REPORT_DIR/nmap.txt"
    XML_OUTPUT="$REPORT_DIR/nmap.xml"
    GREP_OUTPUT="$REPORT_DIR/nmap.gnmap"

    info "Running scan..."
    echo

    nmap \
        "${NMAP_ARGS[@]}" \
        -oN "$NORMAL_OUTPUT" \
        -oX "$XML_OUTPUT" \
        -oG "$GREP_OUTPUT" \
        "$TARGET"

    scan_status=$?

    end_time=$(date +%s)
    duration=$((end_time - start_time))

    echo

    if [ "$scan_status" -eq 0 ]; then

        success "Scan completed successfully."
        success "Scan duration: ${duration}s"

    else

        error "Nmap exited with status: $scan_status"
        warning "Check the output files for details."
    fi
}

# ============================================================
# Generate summary
# ============================================================

generate_summary() {

    section "Scan Summary"

    SUMMARY="$REPORT_DIR/summary.txt"

    {
        echo "============================================================"
        echo "                    EASY NMAP v2"
        echo "============================================================"
        echo
        echo "Target       : $TARGET"
        echo "Profile      : $PROFILE"
        echo "Date         : $(date)"
        echo "Duration     : ${duration}s"
        echo
        echo "------------------------------------------------------------"
        echo "Output Files"
        echo "------------------------------------------------------------"
        echo
        echo "Normal       : nmap.txt"
        echo "XML          : nmap.xml"
        echo "Grepable     : nmap.gnmap"
        echo
        echo "============================================================"
    } > "$SUMMARY"

    echo
    echo -e "${WHITE}Report files:${NC}"
    echo

    ls -lh "$REPORT_DIR"

    echo

    # Extract discovered ports from normal output
    if grep -q "PORT" "$NORMAL_OUTPUT"; then

        echo -e "${GREEN}Discovered services:${NC}"
        echo

        grep -E "^[0-9]+/(tcp|udp)" "$NORMAL_OUTPUT" \
            | head -n 50

        echo
    fi

    echo -e "${GREEN}Summary saved:${NC} $SUMMARY"
}

# ============================================================
# Scan multiple targets from file
# ============================================================

run_target_file() {

    section "Target List Scan"

    info "Target file: $TARGET"

    # Remove blank lines and comments
    mapfile -t TARGETS < <(
        grep -vE '^[[:space:]]*#|^[[:space:]]*$' "$TARGET"
    )

    if [ "${#TARGETS[@]}" -eq 0 ]; then
        error "Target file is empty."
        exit 1
    fi

    echo
    echo -e "${WHITE}Targets found:${NC} ${#TARGETS[@]}"
    echo

    for t in "${TARGETS[@]}"; do
        echo "  - $t"
    done

    echo

    read -rp "$(echo -e "${YELLOW}Start scan? [Y/n]: ${NC}")" confirm

    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        warning "Scan cancelled."
        exit 0
    fi

    LIST_TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    LIST_DIR="nmap-reports/target-list_${LIST_TIMESTAMP}"

    mkdir -p "$LIST_DIR"

    total="${#TARGETS[@]}"
    current=0

    for target_item in "${TARGETS[@]}"; do

        current=$((current + 1))

        echo
        section "Target $current/$total: $target_item"

        TARGET="$target_item"

        timestamp=$(date +"%Y%m%d_%H%M%S")

        safe_target=$(echo "$TARGET" | sed 's#[/:]#_#g')

        REPORT_DIR="$LIST_DIR/${safe_target}_${timestamp}"

        mkdir -p "$REPORT_DIR"

        NORMAL_OUTPUT="$REPORT_DIR/nmap.txt"
        XML_OUTPUT="$REPORT_DIR/nmap.xml"
        GREP_OUTPUT="$REPORT_DIR/nmap.gnmap"

        info "Scanning $TARGET..."

        start_time=$(date +%s)

        nmap \
            "${NMAP_ARGS[@]}" \
            -oN "$NORMAL_OUTPUT" \
            -oX "$XML_OUTPUT" \
            -oG "$GREP_OUTPUT" \
            "$TARGET"

        scan_status=$?

        end_time=$(date +%s)
        duration=$((end_time - start_time))

        if [ "$scan_status" -eq 0 ]; then
            success "$TARGET completed in ${duration}s"
        else
            error "$TARGET failed with status $scan_status"
        fi

    done

    section "Target List Completed"

    success "Reports saved in:"
    echo
    echo "  $LIST_DIR"
    echo
}

# ============================================================
# Parse arguments
# ============================================================

TARGET=""
PROFILE=""
CUSTOM_PORTS=""
NO_PING="no"
TIMING=""

while [[ $# -gt 0 ]]; do

    case "$1" in

        --profile)
            PROFILE="$2"
            shift 2
            ;;

        --ports)
            CUSTOM_PORTS="$2"
            PROFILE="custom"
            shift 2
            ;;

        --all-ports)
            PROFILE="full"
            shift
            ;;

        --udp)
            PROFILE="udp"
            shift
            ;;

        --no-ping)
            NO_PING="yes"
            shift
            ;;

        --timing)
            TIMING="$2"
            shift 2
            ;;

        -h|--help)
            banner
            usage
            exit 0
            ;;

        -*)
            error "Unknown option: $1"
            usage
            exit 1
            ;;

        *)
            if [ -z "$TARGET" ]; then
                TARGET="$1"
            else
                error "Multiple targets supplied."
                exit 1
            fi
            shift
            ;;
    esac

done

# ============================================================
# Main
# ============================================================

banner

check_dependencies
check_privileges

get_target "$TARGET"

# If profile wasn't supplied through CLI, show menu
if [ -z "$PROFILE" ]; then
    choose_profile
fi

# Normalize profile
PROFILE=$(echo "$PROFILE" | tr '[:upper:]' '[:lower:]')

case "$PROFILE" in
    quick|standard|full|aggressive|web|udp|custom)
        ;;
    *)
        error "Invalid profile: $PROFILE"
        echo
        echo "Valid profiles:"
        echo "quick standard full aggressive web udp custom"
        exit 1
        ;;
esac

# Build Nmap command
build_command

# Target file?
if [ -f "$TARGET" ]; then

    run_target_file

else

    create_output_directory

    run_scan

    generate_summary

fi

echo
section "Finished"

success "Easy Nmap v2 completed."
echo
echo -e "${WHITE}Happy enumeration!${NC}"
echo
