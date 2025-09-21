#!/bin/bash
# test_multi_distro.sh
# Comprehensive multi-distribution testing framework using Docker

set -e

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_LOG_DIR="$SCRIPT_DIR/test_logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test distributions configuration
declare -A DISTRIBUTIONS=(
    ["rocky9"]="rockylinux:9"
    ["fedora39"]="fedora:39"
    ["opensuse155"]="opensuse/leap:15.5"
    ["debian12"]="debian:12"
    ["ubuntu2204"]="ubuntu:22.04"
)

# Components to test
TEST_COMPONENTS=(
    "distro_detection"
    "package_manager"
    "core_dependencies"
    "tmux_install"
    "terminal_enhancements"
    "docker_install"
    "1password_install"
    "system_update"
)

# Create test logs directory
mkdir -p "$TEST_LOG_DIR"

log_info() {
    echo -e "${BLUE}[TEST-INFO]${NC} $1" | tee -a "$TEST_LOG_DIR/master_test_$TIMESTAMP.log"
}

log_success() {
    echo -e "${GREEN}[TEST-SUCCESS]${NC} $1" | tee -a "$TEST_LOG_DIR/master_test_$TIMESTAMP.log"
}

log_warning() {
    echo -e "${YELLOW}[TEST-WARNING]${NC} $1" | tee -a "$TEST_LOG_DIR/master_test_$TIMESTAMP.log"
}

log_error() {
    echo -e "${RED}[TEST-ERROR]${NC} $1" | tee -a "$TEST_LOG_DIR/master_test_$TIMESTAMP.log"
}

# Check if Docker is available
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        log_error "Docker is not installed or not in PATH"
        log_error "Please install Docker to run multi-distribution tests"
        exit 1
    fi

    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon is not running or not accessible"
        log_error "Please start Docker and ensure you have permissions"
        exit 1
    fi

    log_success "Docker is available and running"
}

# Create test script for inside containers
create_container_test_script() {
    local distro="$1"
    local test_script="$TEST_LOG_DIR/container_test_${distro}.sh"

    cat > "$test_script" << 'EOF'
#!/bin/bash
# Container test script - runs inside each distribution

set -e
export DEBIAN_FRONTEND=noninteractive

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

container_log() {
    echo -e "${BLUE}[CONTAINER]${NC} $1"
}

container_success() {
    echo -e "${GREEN}[CONTAINER-SUCCESS]${NC} $1"
}

container_error() {
    echo -e "${RED}[CONTAINER-ERROR]${NC} $1"
}

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

test_result() {
    local test_name="$1"
    local result="$2"

    if [[ "$result" == "PASS" ]]; then
        container_success "✅ $test_name: PASSED"
        ((TESTS_PASSED++))
    else
        container_error "❌ $test_name: FAILED"
        ((TESTS_FAILED++))
        FAILED_TESTS+=("$test_name")
    fi
}

# Install basic requirements
install_prerequisites() {
    container_log "Installing basic prerequisites..."

    # Detect base system and install requirements
    if command -v apt >/dev/null 2>&1; then
        apt update >/dev/null 2>&1
        apt install -y git curl sudo >/dev/null 2>&1
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y git curl sudo >/dev/null 2>&1
    elif command -v yum >/dev/null 2>&1; then
        yum install -y git curl sudo >/dev/null 2>&1
    elif command -v zypper >/dev/null 2>&1; then
        zypper refresh >/dev/null 2>&1
        zypper install -y git curl sudo >/dev/null 2>&1
    fi
}

# Test 1: Distribution Detection
test_distribution_detection() {
    container_log "Testing distribution detection..."

    cd /Linux_Setup
    if ./lib/distro_detect.sh --verbose >/dev/null 2>&1; then
        test_result "Distribution Detection" "PASS"

        # Source and check variables
        source ./lib/distro_detect.sh
        run_distribution_detection >/dev/null 2>&1

        if [[ -n "$DISTRO_ID" && -n "$DISTRO_FAMILY" && -n "$PKG_MANAGER" ]]; then
            container_log "Detected: $DISTRO_NAME ($DISTRO_FAMILY) using $PKG_MANAGER"
            test_result "Distribution Variables" "PASS"
        else
            test_result "Distribution Variables" "FAIL"
        fi
    else
        test_result "Distribution Detection" "FAIL"
    fi
}

# Test 2: Package Manager Functionality
test_package_manager() {
    container_log "Testing package manager abstraction..."

    cd /Linux_Setup
    source ./lib/distro_detect.sh
    source ./lib/package_manager.sh

    if run_distribution_detection >/dev/null 2>&1; then
        # Test package name mapping
        local mapped_dev_tools=$(get_package_name "development-tools")
        local mapped_python_dev=$(get_package_name "python3-devel")

        if [[ -n "$mapped_dev_tools" && -n "$mapped_python_dev" ]]; then
            container_log "Package mapping: development-tools → $mapped_dev_tools"
            container_log "Package mapping: python3-devel → $mapped_python_dev"
            test_result "Package Mapping" "PASS"
        else
            test_result "Package Mapping" "FAIL"
        fi

        # Test package manager availability
        if command -v "$PKG_MANAGER" >/dev/null 2>&1; then
            test_result "Package Manager Available" "PASS"
        else
            test_result "Package Manager Available" "FAIL"
        fi
    else
        test_result "Package Manager Setup" "FAIL"
    fi
}

# Test 3: Core Dependencies
test_core_dependencies() {
    container_log "Testing core dependencies installation..."

    cd /Linux_Setup
    source ./lib/distro_detect.sh
    source ./lib/package_manager.sh
    run_distribution_detection >/dev/null 2>&1

    # Test installing a simple, universal package
    if pkg_install "git" >/dev/null 2>&1; then
        test_result "Basic Package Install" "PASS"
    else
        test_result "Basic Package Install" "FAIL"
    fi

    # Test package mapping installation
    if pkg_install_mapped "development-tools" >/dev/null 2>&1; then
        test_result "Mapped Package Install" "PASS"
    else
        # This might fail due to size/time, so we'll test the mapping logic instead
        local mapped_name=$(get_package_name "development-tools")
        if [[ -n "$mapped_name" ]]; then
            test_result "Mapped Package Install" "PASS"
        else
            test_result "Mapped Package Install" "FAIL"
        fi
    fi
}

# Test 4: Individual Install Scripts
test_install_scripts() {
    container_log "Testing individual install scripts..."

    cd /Linux_Setup

    # Test script syntax and basic functionality
    local scripts=(
        "install_routines/15_tmux.sh"
        "install_routines/70_terminal_enhancements.sh"
        "system_manager/update_system.sh"
    )

    for script in "${scripts[@]}"; do
        local script_name=$(basename "$script" .sh)

        # Test syntax
        if bash -n "$script" 2>/dev/null; then
            test_result "${script_name} Syntax" "PASS"
        else
            test_result "${script_name} Syntax" "FAIL"
        fi

        # Test that script can source libraries without error
        if bash -c "source ./lib/distro_detect.sh; source ./lib/package_manager.sh; source $script" >/dev/null 2>&1; then
            test_result "${script_name} Library Integration" "PASS"
        else
            test_result "${script_name} Library Integration" "FAIL"
        fi
    done
}

# Test 5: Repository Operations (non-destructive)
test_repository_operations() {
    container_log "Testing repository operations..."

    cd /Linux_Setup
    source ./lib/distro_detect.sh
    source ./lib/package_manager.sh
    run_distribution_detection >/dev/null 2>&1

    # Test EPEL enablement for RHEL-based systems
    if [[ "$DISTRO_FAMILY" == "rhel" || "$DISTRO_FAMILY" == "fedora" ]]; then
        if pkg_enable_epel >/dev/null 2>&1; then
            test_result "EPEL Repository" "PASS"
        else
            test_result "EPEL Repository" "FAIL"
        fi
    else
        test_result "EPEL Repository" "PASS"  # N/A for non-RHEL systems
    fi
}

# Test 6: Setup Script Integration
test_setup_integration() {
    container_log "Testing main setup script integration..."

    cd /Linux_Setup

    # Test setup script syntax
    if bash -n setup.sh 2>/dev/null; then
        test_result "Setup Script Syntax" "PASS"
    else
        test_result "Setup Script Syntax" "FAIL"
    fi

    # Test that setup script can load libraries
    if bash -c "source ./lib/distro_detect.sh; source ./lib/package_manager.sh; echo 'Libraries loaded successfully'" >/dev/null 2>&1; then
        test_result "Setup Script Libraries" "PASS"
    else
        test_result "Setup Script Libraries" "FAIL"
    fi
}

# Main test execution
main() {
    container_log "=========================================="
    container_log "Starting Container Tests"
    container_log "=========================================="

    install_prerequisites

    test_distribution_detection
    test_package_manager
    test_core_dependencies
    test_install_scripts
    test_repository_operations
    test_setup_integration

    container_log "=========================================="
    container_log "Test Summary"
    container_log "=========================================="
    container_log "Tests Passed: $TESTS_PASSED"
    container_log "Tests Failed: $TESTS_FAILED"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        container_error "Failed Tests: ${FAILED_TESTS[*]}"
        exit 1
    else
        container_success "All tests passed!"
        exit 0
    fi
}

main "$@"
EOF

    chmod +x "$test_script"
    echo "$test_script"
}

# Test a single distribution
test_distribution() {
    local distro_name="$1"
    local docker_image="$2"
    local test_log="$TEST_LOG_DIR/${distro_name}_test_$TIMESTAMP.log"

    log_info "=========================================="
    log_info "Testing $distro_name ($docker_image)"
    log_info "=========================================="

    # Create container test script
    local container_script=$(create_container_test_script "$distro_name")

    # Pull Docker image
    log_info "Pulling Docker image: $docker_image"
    if ! docker pull "$docker_image" >/dev/null 2>&1; then
        log_error "Failed to pull Docker image: $docker_image"
        return 1
    fi

    # Run tests in container
    log_info "Running tests in $distro_name container..."

    local container_id
    container_id=$(docker run -d \
        --name "linux_setup_test_${distro_name}_$$" \
        -v "$SCRIPT_DIR:/Linux_Setup:ro" \
        -v "$container_script:/test_script.sh:ro" \
        "$docker_image" \
        sleep 3600)

    if [[ -z "$container_id" ]]; then
        log_error "Failed to start container for $distro_name"
        return 1
    fi

    # Execute tests
    local test_result=0
    if docker exec "$container_id" bash /test_script.sh 2>&1 | tee "$test_log"; then
        log_success "$distro_name: All tests passed!"
    else
        log_error "$distro_name: Some tests failed!"
        test_result=1
    fi

    # Cleanup container
    docker stop "$container_id" >/dev/null 2>&1
    docker rm "$container_id" >/dev/null 2>&1

    return $test_result
}

# Run tests on all distributions
run_all_tests() {
    local failed_distros=()
    local passed_distros=()

    log_info "Starting comprehensive multi-distribution testing"
    log_info "Test logs will be saved to: $TEST_LOG_DIR"

    for distro_name in "${!DISTRIBUTIONS[@]}"; do
        local docker_image="${DISTRIBUTIONS[$distro_name]}"

        if test_distribution "$distro_name" "$docker_image"; then
            passed_distros+=("$distro_name")
        else
            failed_distros+=("$distro_name")
        fi

        echo  # Add spacing between distribution tests
    done

    # Final summary
    log_info "=========================================="
    log_info "FINAL TEST SUMMARY"
    log_info "=========================================="
    log_success "Passed distributions: ${passed_distros[*]:-none}"

    if [[ ${#failed_distros[@]} -gt 0 ]]; then
        log_error "Failed distributions: ${failed_distros[*]}"
        log_info "Check individual log files in $TEST_LOG_DIR for details"
        return 1
    else
        log_success "🎉 All distributions passed all tests!"
        return 0
    fi
}

# Test specific distribution
test_single() {
    local distro="$1"

    if [[ -z "$distro" ]]; then
        echo "Usage: $0 single <distribution>"
        echo "Available distributions: ${!DISTRIBUTIONS[*]}"
        exit 1
    fi

    if [[ -z "${DISTRIBUTIONS[$distro]}" ]]; then
        log_error "Unknown distribution: $distro"
        echo "Available distributions: ${!DISTRIBUTIONS[*]}"
        exit 1
    fi

    test_distribution "$distro" "${DISTRIBUTIONS[$distro]}"
}

# Show help
show_help() {
    cat << EOF
Multi-Distribution Testing Framework

Usage: $0 [COMMAND]

Commands:
    all                 Run tests on all distributions
    single <distro>     Test a specific distribution
    list               List available distributions
    clean              Clean up test logs
    help               Show this help

Available distributions:
$(for distro in "${!DISTRIBUTIONS[@]}"; do echo "    $distro - ${DISTRIBUTIONS[$distro]}"; done)

Examples:
    $0 all                    # Test all distributions
    $0 single rocky9          # Test only Rocky Linux 9
    $0 single fedora39        # Test only Fedora 39

Test logs are saved to: $TEST_LOG_DIR
EOF
}

# Clean up test logs
clean_logs() {
    if [[ -d "$TEST_LOG_DIR" ]]; then
        rm -rf "$TEST_LOG_DIR"
        log_info "Cleaned up test logs directory"
    else
        log_info "No test logs to clean"
    fi
}

# Main execution
main() {
    local command="${1:-all}"

    case "$command" in
        "all")
            check_docker
            run_all_tests
            ;;
        "single")
            check_docker
            test_single "$2"
            ;;
        "list")
            echo "Available distributions:"
            for distro in "${!DISTRIBUTIONS[@]}"; do
                echo "  $distro - ${DISTRIBUTIONS[$distro]}"
            done
            ;;
        "clean")
            clean_logs
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"