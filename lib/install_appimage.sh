#!/bin/bash

install_appimage() {
    local src="$1"
    local app_name
    app_name=$(basename "$src" .AppImage | tr '[:upper:]' '[:lower:]')
    local dest="$MAGE_APPS_DIR/$app_name.AppImage"
    local bin_link="$MAGE_BIN_DIR/$app_name"

    log_info "Installing AppImage: $app_name"
    ensure_dirs

    if [ ! -f "$src" ]; then
        log_error "Source file not found: $src"
        exit 1
    fi

    log_info "Moving AppImage to $MAGE_APPS_DIR"
    cp "$src" "$dest"
    chmod +x "$dest"

    log_info "Extracting icon..."
    local tmp_dir
    tmp_dir=$(mktemp -d)
    # AppImage specific extraction
    (cd "$tmp_dir" && "$dest" --appimage-extract '*.png' > /dev/null 2>&1 || "$dest" --appimage-extract '*.svg' > /dev/null 2>&1 || true)
    
    local src_icon
    src_icon=$(find_icon_in_dir "$tmp_dir/squashfs-root" "$app_name")
    local icon_ref
    icon_ref=$(install_icon "$src_icon" "$app_name")
    rm -rf "$tmp_dir"

    local desktop_file
    desktop_file=$(create_desktop_entry "$app_name" "$dest" "$icon_ref")

    log_info "Creating terminal command (may ask for sudo)..."
    sudo ln -sf "$dest" "$bin_link"

    registry_add "$app_name" "appimage" "$src" "$dest" "$bin_link" "$desktop_file" "$icon_ref"
    
    log_success "Successfully installed $app_name"
}
