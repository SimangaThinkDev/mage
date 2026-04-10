#!/bin/bash

uninstall_app() {
    local name="$1"
    
    if ! registry_exists "$name"; then
        log_error "App '$name' is not registered with mage."
        exit 1
    fi

    log_info "Uninstalling $name..."

    local installed_to
    installed_to=$(registry_get_field "$name" "installed_to")
    local bin_link
    bin_link=$(registry_get_field "$name" "bin_link")
    local desktop_file
    desktop_file=$(registry_get_field "$name" "desktop_file")
    local icon
    icon=$(registry_get_field "$name" "icon")

    # Remove files
    if [ -n "$installed_to" ] && [ -e "$installed_to" ]; then
        log_info "Removing $installed_to"
        rm -rf "$installed_to"
    fi

    if [ -n "$bin_link" ] && [ -L "$bin_link" ]; then
        log_info "Removing symlink $bin_link (may ask for sudo)"
        sudo rm "$bin_link"
    fi

    if [ -n "$desktop_file" ] && [ -f "$desktop_file" ]; then
        log_info "Removing desktop entry $desktop_file"
        rm "$desktop_file"
    fi

    if [ -n "$icon" ] && [ -f "$icon" ] && [[ "$icon" == "$MAGE_ICONS_DIR"* ]]; then
        log_info "Removing icon $icon"
        rm "$icon"
    fi

    # Clean registry
    registry_remove "$name"
    
    # Update desktop database
    update-desktop-database "$MAGE_DESKTOP_DIR" || true

    log_success "Successfully uninstalled $name"
}
