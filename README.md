# mage

Installs `.AppImage` and `.tar` archives with a terminal command and desktop launcher entry.

`mage` keeps your `~/Applications` directory organized and automatically creates CLI symlinks and desktop launcher entries for standalone Linux applications.

## Features

- **AppImage Support**: Standard AppImage installation with icon extraction.
- **Tar Support**: Supports `.tar.gz`, `.tar.xz`, `.tar.bz2`, and `.tar`.
- **Heuristic Detection**: Automatically finds the main executable and icon in extracted archives.
- **App Registry**: Keeps track of all installed applications in a central registry.
- **List & Uninstall**: Easily list installed apps or remove them completely.
- **Modular Design**: Clean, bash-based modular architecture.

## Installation

```bash
curl -LO https://github.com/SimangaThinkDev/mage/releases/latest/download/mage.deb
sudo apt install ./mage.deb
```

## Usage

### Install an AppImage
```bash
mage --file path/to/app.AppImage
```

### Install a Tar Archive
```bash
mage --file path/to/app.tar.gz
```

*Note: If mage cannot find the executable, you can specify it manually:*
```bash
mage --file path/to/app.tar.gz --exec bin/app-binary
```

### List Installed Apps
```bash
mage --list
```

### Uninstall an App
```bash
mage --uninstall <name>
```

## Options

| Option | Description |
|--------|-------------|
| `--file <path>` | Path to the .AppImage or .tar file to install |
| `--exec <path>` | Relative path to the executable inside the archive (tar only) |
| `-l, --list` | List all applications installed with mage |
| `--uninstall <name>` | Uninstall an application by name |
| `-h, --help` | Show help message |
| `-v, --version` | Show version |

## Registry

`mage` tracks installations in `~/.local/share/mage/registry.yml`. This file stores metadata about each installed app, including its original source and where it was installed.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
