#!/bin/bash

# Constants
MAGE_DATA_DIR="$HOME/.local/share/mage"
MAGE_APPS_DIR="$HOME/Applications"
MAGE_ICONS_DIR="$HOME/.local/share/icons"
MAGE_DESKTOP_DIR="$HOME/.local/share/applications"
MAGE_REGISTRY="$MAGE_DATA_DIR/registry.yml"
MAGE_BIN_DIR="/usr/local/bin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging helpers
log_info() {
    echo -e "${BLUE}==>${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

log_warn() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

# Directory setup
ensure_dirs() {
    mkdir -p "$MAGE_DATA_DIR"
    mkdir -p "$MAGE_APPS_DIR"
    mkdir -p "$MAGE_ICONS_DIR"
    mkdir -p "$MAGE_DESKTOP_DIR"
}
