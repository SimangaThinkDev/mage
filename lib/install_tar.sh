#!/bin/bash

install_tar() {
    local src="$1"
    local custom_exec="$2"
    
    # Extract app name from filename (remove .tar, .tar.gz, .tgz, .tar.xz, .tar.bz2)
    local app_name
    app_name=$(basename "$src")
    app_name="${app_name%.tar.gz}"
    app_name="${app_name%.tgz}"
    app_name="${app_name%.tar.xz}"
    app_name="${app_name%.tar.bz2}"
    app_name="${app_name%.tar}"
    app_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')

    local dest_dir="$MAGE_APPS_DIR/$app_name"
    local bin_link="$MAGE_BIN_DIR/$app_name"

    log_info "Installing Tar archive: $app_name"
    ensure_dirs

    if [ ! -f "$src" ]; then
        log_error "Source file not found: $src"
        exit 1
    fi

    # Create destination directory
    mkdir -p "$dest_dir"

    log_info "Extracting to $dest_dir..."
    case "$src" in
        *.tar.gz|*.tgz) tar -xzf "$src" -C "$dest_dir" --strip-components=1 2>/dev/null || tar -xzf "$src" -C "$dest_dir" ;;
        *.tar.xz) tar -xJf "$src" -C "$dest_dir" --strip-components=1 2>/dev/null || tar -xJf "$src" -C "$dest_dir" ;;
        *.tar.bz2) tar -xjf "$src" -C "$dest_dir" --strip-components=1 2>/dev/null || tar -xjf "$src" -C "$dest_dir" ;;
        *.tar) tar -xf "$src" -C "$dest_dir" --strip-components=1 2>/dev/null || tar -xf "$src" -C "$dest_dir" ;;
        *) log_error "Unsupported archive format"; exit 1 ;;
    esac

    # Finding the executable
    local exec_path=""
    if [ -n "$custom_exec" ]; then
        exec_path="$dest_dir/$custom_exec"
    else
        log_info "Hunting for executable..."
        # 1. Parse .desktop file if it exists
        local bundled_desktop
        bundled_desktop=$(find "$dest_dir" -name "*.desktop" | head -n 1)
        if [ -n "$bundled_desktop" ]; then
            exec_path=$(grep "^Exec=" "$bundled_desktop" | cut -d= -f2 | cut -d' ' -f1)
            # If path is relative, make it absolute
            if [[ "$exec_path" != /* ]]; then
                # Find where the executable is relative to root
                local exe_name
                exe_name=$(basename "$exec_path")
                exec_path=$(find "$dest_dir" -name "$exe_name" -type f -executable | head -n 1)
            fi
        fi

        # 2. Look for executable named after the app
        if [ -z "$exec_path" ] || [ ! -x "$exec_path" ]; then
            exec_path=$(find "$dest_dir" -maxdepth 2 -name "$app_name" -type f -executable | head -n 1)
        fi

        # 3. Look for any executable in the root
        if [ -z "$exec_path" ] || [ ! -x "$exec_path" ]; then
            exec_path=$(find "$dest_dir" -maxdepth 1 -type f -executable | head -n 1)
        fi
    fi

    if [ -z "$exec_path" ] || [ ! -x "$exec_path" ]; then
        log_error "Could not find a valid executable. Please specify with --exec <relative-path>"
        exit 1
    fi
    log_info "Found executable: $exec_path"

    # Finding the icon
    log_info "Hunting for icon..."
    local src_icon
    src_icon=$(find_icon_in_dir "$dest_dir" "$app_name")
    local icon_ref
    icon_ref=$(install_icon "$src_icon" "$app_name")

    local desktop_file
    desktop_file=$(create_desktop_entry "$app_name" "$exec_path" "$icon_ref")

    log_info "Creating terminal command (may ask for sudo)..."
    sudo ln -sf "$exec_path" "$bin_link"

    registry_add "$app_name" "tar" "$src" "$dest_dir" "$bin_link" "$desktop_file" "$icon_ref"
    
    log_success "Successfully installed $app_name"
}
