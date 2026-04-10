#!/bin/bash

# Mage - Universal Linux App Installer
# Version: 1.1.0

set -e

# Find application directory
if [ -L "$0" ]; then
    SCRIPT_PATH=$(readlink -f "$0")
else
    SCRIPT_PATH="$0"
fi
APP_DIR=$(dirname "$SCRIPT_PATH")

# Determine where libraries are
if [ -d "$APP_DIR/lib" ]; then
    # Running from source
    LIB_DIR="$APP_DIR/lib"
elif [ -d "/usr/local/lib/mage" ]; then
    # Running from installed package
    LIB_DIR="/usr/local/lib/mage"
else
    echo "ERROR: Could not find Mage library files."
    exit 1
fi

# Source libraries
# shellcheck source=lib/common.sh
source "$LIB_DIR/common.sh"
# shellcheck source=lib/registry.sh
source "$LIB_DIR/registry.sh"
# shellcheck source=lib/desktop.sh
source "$LIB_DIR/desktop.sh"
# shellcheck source=lib/install_appimage.sh
source "$LIB_DIR/install_appimage.sh"
# shellcheck source=lib/install_tar.sh
source "$LIB_DIR/install_tar.sh"
# shellcheck source=lib/uninstall.sh
source "$LIB_DIR/uninstall.sh"

usage() {
    echo "Mage v1.1.0 - Universal Linux App Installer"
    echo ""
    echo "Usage:"
    echo "  mage --file <path> [options]    Install an AppImage or Tar archive"
    echo "  mage -l, --list                 List all applications installed with mage"
    echo "  mage --uninstall <name>         Uninstall an application"
    echo "  mage -v, --version              Show version"
    echo "  mage -h, --help                 Show this help message"
    echo ""
    echo "Options for installation:"
    echo "  --exec <path>                   Specify the relative path to the executable (tar only)"
    echo ""
}

# Ensure directories and initialize registry
ensure_dirs
registry_init

# Argument parsing
SRC=""
CUSTOM_EXEC=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--version)
            echo "mage v1.1.0"
            exit 0
            ;;
        --file)
            SRC="$2"
            shift 2
            ;;
        --exec)
            CUSTOM_EXEC="$2"
            shift 2
            ;;
        -l|--list)
            registry_list
            exit 0
            ;;
        --uninstall)
            uninstall_app "$2"
            exit 0
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

if [ -z "$SRC" ]; then
    usage
    exit 1
fi

# Detect file type and install
if [[ "$SRC" == *.AppImage ]]; then
    install_appimage "$SRC"
elif [[ "$SRC" == *.tar* ]] || [[ "$SRC" == *.tgz ]]; then
    install_tar "$SRC" "$CUSTOM_EXEC"
else
    log_error "Unsupported file type: $(basename "$SRC")"
    exit 1
fi
