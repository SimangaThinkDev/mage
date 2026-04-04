# mage

Installs any `.AppImage` with a terminal command and desktop launcher entry.

## Usage

### Run directly

```bash
bash main.sh --file path/to/app.AppImage
```

### Install via apt (`.deb`)

```bash
# Build the package
dpkg-deb --build deb mage.deb

# Install
sudo apt install ./mage.deb
```

After install, run:

```bash
mage --file path/to/app.AppImage
```

This will:
- Copy the AppImage to `~/Applications/`
- Create a terminal command named after the file
- Add an entry to your app launcher
