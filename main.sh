#!/bin/bash

set -e

usage() {
    echo "Usage: mage --file <path-to.AppImage>"
    echo ""
    echo "Options:"
    echo "  --file <path>   Path to the .AppImage file to install"
    echo "  -h, --help      Show this help message"
}

case "$1" in
    -h|--help) usage; exit 0 ;;
    --file) SRC="$2" ;;
    *) usage; exit 1 ;;
esac

if [ -z "$SRC" ]; then
    usage
    exit 1
fi

SRC="$2"
APP_NAME="$(basename "$SRC" .AppImage | tr '[:upper:]' '[:lower:]')"
DEST_DIR="$HOME/Applications"
DEST="$DEST_DIR/$APP_NAME.AppImage"

DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME.desktop"
BIN_LINK="/usr/local/bin/$APP_NAME"

echo "==> Creating Applications directory..."
mkdir -p "$DEST_DIR"

echo "==> Moving AppImage..."
if [ -f "$SRC" ]; then
    cp "$SRC" "$DEST"
else
    echo "ERROR: $SRC not found"
    exit 1
fi

echo "==> Making AppImage executable..."
chmod +x "$DEST"

echo "==> Creating terminal command (may ask for sudo)..."
sudo ln -sf "$DEST" "$BIN_LINK"

echo "==> Extracting icon..."
TMP_DIR="$(mktemp -d)"
ICON_REF="utilities-terminal"
(cd "$TMP_DIR" && "$DEST" --appimage-extract '*.png' > /dev/null 2>&1 || "$DEST" --appimage-extract '*.svg' > /dev/null 2>&1 || true)
ICON_SRC="$(find "$TMP_DIR/squashfs-root" -maxdepth 3 \( -name "*.png" -o -name "*.svg" \) 2>/dev/null | head -n 1)"
if [ -n "$ICON_SRC" ]; then
    EXT="${ICON_SRC##*.}"
    mkdir -p "$HOME/.local/share/icons"
    cp "$ICON_SRC" "$HOME/.local/share/icons/$APP_NAME.$EXT"
    ICON_REF="$HOME/.local/share/icons/$APP_NAME.$EXT"
fi
rm -rf "$TMP_DIR"

echo "==> Creating desktop entry..."
mkdir -p "$(dirname "$DESKTOP_FILE")"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=$APP_NAME
Exec=$DEST
Icon=$ICON_REF
Type=Application
Categories=Utility;
EOF

chmod +x "$DESKTOP_FILE"

echo "==> Updating desktop database..."
update-desktop-database ~/.local/share/applications || true

echo "✅ Done!"
echo "You can now:"
echo " - Run '$APP_NAME' in terminal"
echo " - Find '$APP_NAME' in your app launcher"

