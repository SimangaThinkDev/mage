# mage

Installs any `.AppImage` with a terminal command and desktop launcher entry.

## Install

```bash
curl -LO https://github.com/SimangaThinkDev/mage/releases/latest/download/mage.deb
sudo apt install ./mage.deb
```

## Usage

```bash
mage --file path/to/app.AppImage
```

This will:
- Copy the AppImage to `~/Applications/`
- Create a terminal command named after the file
- Add an entry to your app launcher

## Options

```
--file <path>   Path to the .AppImage file to install
-h, --help      Show this help message
```

## Release a new version

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will build and publish `mage.deb` automatically.
