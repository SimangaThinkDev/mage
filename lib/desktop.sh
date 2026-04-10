#!/bin/bash

create_desktop_entry() {
    local name="$1"
    local exec_path="$2"
    local icon_path="$3"
    local desktop_file="$MAGE_DESKTOP_DIR/$name.desktop"

    log_info "Creating desktop entry..."
    cat > "$desktop_file" <<EOF
[Desktop Entry]
Name=$name
Exec=$exec_path
Icon=$icon_path
Type=Application
Categories=Utility;
EOF
    chmod +x "$desktop_file"
    update-desktop-database "$MAGE_DESKTOP_DIR" || true
    echo "$desktop_file"
}

find_icon_in_dir() {
    local dir="$1"
    local app_name="$2"
    # Search for files named after the app first
    local icon
    icon=$(find "$dir" -maxdepth 5 \( -name "$app_name.png" -o -name "$app_name.svg" \) 2>/dev/null | head -n 1)
    
    if [ -z "$icon" ]; then
        # Search for any png or svg
        icon=$(find "$dir" -maxdepth 5 \( -name "*.png" -o -name "*.svg" \) 2>/dev/null | head -n 1)
    fi
    echo "$icon"
}

install_icon() {
    local src_icon="$1"
    local app_name="$2"
    
    if [ -z "$src_icon" ]; then
        echo "utilities-terminal"
        return
    fi

    local ext="${src_icon##*.}"
    local dest_icon="$MAGE_ICONS_DIR/$app_name.$ext"
    
    cp "$src_icon" "$dest_icon"
    echo "$dest_icon"
}
