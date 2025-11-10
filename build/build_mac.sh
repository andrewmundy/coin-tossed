#!/bin/bash
# Build script for macOS executable

echo "Building Flipper.app for macOS..."

# Check if love.app exists
if [ ! -d "/Applications/love.app" ]; then
    echo "Error: LÖVE not found at /Applications/love.app"
    echo "Please download LÖVE from https://love2d.org and install it first"
    exit 1
fi

# Create the .love file
zip -r Flipper.love . -x "*.git*" -x "*.DS_Store" -x "*.sh" -x "Flipper.love" -x "Flipper.app/*"

# Copy LÖVE app
cp -r /Applications/love.app Flipper.app

# Place the .love file inside the app bundle
cp Flipper.love Flipper.app/Contents/Resources/

# Rename the executable
mv Flipper.app/Contents/MacOS/love Flipper.app/Contents/MacOS/Flipper

# Update Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleName Flipper" Flipper.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.yourname.flipper" Flipper.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable Flipper" Flipper.app/Contents/Info.plist

echo "✅ Flipper.app created successfully!"
echo "You can now run it by double-clicking Flipper.app"

