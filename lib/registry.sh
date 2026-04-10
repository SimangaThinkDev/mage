#!/bin/bash

registry_init() {
    if [ ! -f "$MAGE_REGISTRY" ]; then
        mkdir -p "$(dirname "$MAGE_REGISTRY")"
        echo "apps:" > "$MAGE_REGISTRY"
    fi
}

registry_exists() {
    local name="$1"
    grep -q "  - name: $name" "$MAGE_REGISTRY" 2>/dev/null
}

registry_add() {
    local name="$1"
    local type="$2"
    local source="$3"
    local installed_to="$4"
    local bin_link="$5"
    local desktop_file="$6"
    local icon="$7"
    local timestamp
    timestamp=$(date -Iseconds)

    if registry_exists "$name"; then
        log_warn "App '$name' already in registry. Updating..."
        registry_remove "$name"
    fi

    cat >> "$MAGE_REGISTRY" <<EOF
  - name: $name
    type: $type
    source: $source
    installed_to: $installed_to
    bin_link: $bin_link
    desktop_file: $desktop_file
    icon: $icon
    installed_at: $timestamp
EOF
}

registry_remove() {
    local name="$1"
    # Find the start line of the entry
    local start_line
    start_line=$(grep -n "  - name: $name" "$MAGE_REGISTRY" | cut -d: -f1)
    
    if [ -n "$start_line" ]; then
        # Each entry is 8 lines long. Delete 8 lines starting from start_line.
        sed -i "${start_line},$((start_line + 7))d" "$MAGE_REGISTRY"
    fi
}

registry_list() {
    echo -e "Installed Applications:"
    echo -e "------------------------------------------------"
    printf "%-15s | %-10s | %-20s\n" "Name" "Type" "Installed At"
    echo -e "------------------------------------------------"
    
    # Parse the yaml and print relevant fields
    grep "  - name:" "$MAGE_REGISTRY" | while read -r line; do
        local name="${line#*name: }"
        local type
        type=$(grep -A 1 "  - name: $name" "$MAGE_REGISTRY" | grep "type:" | cut -d: -f2 | xargs)
        local installed_at
        installed_at=$(grep -A 7 "  - name: $name" "$MAGE_REGISTRY" | grep "installed_at:" | cut -d: -f2- | xargs)
        
        printf "%-15s | %-10s | %-20s\n" "$name" "$type" "$installed_at"
    done
}

registry_get_field() {
    local name="$1"
    local field="$2"
    grep -A 7 "  - name: $name" "$MAGE_REGISTRY" | grep "$field:" | cut -d: -f2- | xargs
}
