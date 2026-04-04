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

echo "==> Creating desktop entry..."
mkdir -p "$(dirname "$DESKTOP_FILE")"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=$APP_NAME
Exec=$DEST
Icon=utilities-terminal
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

