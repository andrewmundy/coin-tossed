# Building Flipper Executables

This guide explains how to create standalone executables for different platforms.

## Quick Start - .love File (All Platforms)

The simplest distribution method. Anyone with LÖVE installed can run it:

```bash
zip -r Flipper.love . -x "*.git*" -x "*.DS_Store" -x "*.sh" -x "*.md"
```

Users can run it with: `love Flipper.love`

---

## macOS Executable

### Method 1: Using the Build Script (Easiest)

```bash
chmod +x build_mac.sh
./build_mac.sh
```

### Method 2: Manual Steps

1. **Create the .love file:**

   ```bash
   zip -r Flipper.love . -x "*.git*" -x "*.DS_Store"
   ```

2. **Copy LÖVE.app:**

   ```bash
   cp -r /Applications/love.app Flipper.app
   ```

3. **Add your game:**

   ```bash
   cp Flipper.love Flipper.app/Contents/Resources/
   ```

4. **Rename executable:**

   ```bash
   mv Flipper.app/Contents/MacOS/love Flipper.app/Contents/MacOS/Flipper
   ```

5. **Update Info.plist:**
   ```bash
   /usr/libexec/PlistBuddy -c "Set :CFBundleName Flipper" Flipper.app/Contents/Info.plist
   /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.yourname.flipper" Flipper.app/Contents/Info.plist
   /usr/libexec/PlistBuddy -c "Set :CFBundleExecutable Flipper" Flipper.app/Contents/Info.plist
   ```

**Result:** `Flipper.app` - Double-click to run!

---

## Windows Executable

### Prerequisites

- Download LÖVE for Windows from https://love2d.org
- Extract `love.exe` and DLLs

### Steps

1. **Create the .love file** (on Mac or Windows):

   ```bash
   zip -r Flipper.love . -x "*.git*" -x "*.DS_Store"
   ```

2. **Combine with love.exe** (on Windows):

   ```cmd
   copy /b love.exe+Flipper.love Flipper.exe
   ```

3. **Include DLLs:**
   - Copy all `.dll` files from LÖVE's directory next to `Flipper.exe`

**Result:** `Flipper.exe` + DLLs folder

### Distribution

Package everything in a ZIP:

- Flipper.exe
- All DLL files
- license.txt (from LÖVE)

---

## Linux Executable

### Method 1: AppImage (Recommended)

1. **Create the .love file:**

   ```bash
   zip -r Flipper.love . -x "*.git*" -x "*.DS_Store"
   ```

2. **Use love-appimage tool:**

   ```bash
   # Install love-appimage
   wget https://github.com/love2d-community/love-appimages/releases/download/11.4/love-11.4-x86_64.AppImage
   chmod +x love-11.4-x86_64.AppImage

   # Create AppImage
   ./love-11.4-x86_64.AppImage --appimage-extract
   cp Flipper.love squashfs-root/
   # Package it back up
   ```

### Method 2: Debian Package

Create a `.deb` package with:

- Game files in `/usr/share/games/flipper/`
- Desktop entry in `/usr/share/applications/`
- Launcher script in `/usr/bin/`

---

## Web Version (Using love.js)

To run in a browser:

### Method 1: Using the Build Script (Easiest - Includes Custom CSS)

```bash
chmod +x build_web.sh
./build_web.sh
```

This automatically builds the game and applies your custom CSS from `custom-theme/love.css`.

### Method 2: Manual Build

1. **Install love.js:**

   ```bash
   npm install -g love.js
   ```

2. **Build:**

   ```bash
   npx --yes love.js Flipper.love game -t "Flipper - Coin Flipping Roguelike" --compatibility
   ```

3. **Optional - Apply Custom CSS:**

   If you want custom styling, copy your CSS over the generated one:

   ```bash
   cp custom-theme/love.css game/theme/love.css
   ```

4. **Result:** HTML5 version you can host online!

### Customizing the Web Theme

Edit `custom-theme/love.css` to customize the look of the web version. Your changes will be automatically applied when using `build_web.sh`.

---

## File Sizes & Distribution

- **.love file**: ~500KB (smallest, requires LÖVE)
- **macOS .app**: ~15-20MB
- **Windows .exe + DLLs**: ~10-15MB
- **Linux AppImage**: ~15-20MB

## Recommended Distribution Method

For **itch.io** or **Game Jolt**:

- Upload separate builds for each platform
- Also include the .love file for Linux users

For **Steam**:

- Use platform-specific executables
- Include LÖVE runtime in the package

---

## Notes

- The **.love file** is just a ZIP with your game files
- All methods bundle LÖVE with your game
- macOS apps may need code signing for distribution
- Windows executables may trigger antivirus warnings without signing

## Quick Test

After building, test that:

1. Game launches without errors
2. All assets load correctly
3. Sounds play properly
4. File paths work (use relative paths only!)
