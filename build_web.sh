#!/bin/bash

# Build script for web version with custom CSS
# This builds the game and automatically applies your custom CSS

echo "Step 1: Creating Flipper.love from source files..."
zip -r Flipper.love . -x "*.git*" -x "*.DS_Store" -x "*.sh" -x "*.md" -x "game/*" -x "custom-theme/*" -x "Flipper.app/*" > /dev/null 2>&1

echo "Step 2: Building web version..."
npx --yes love.js Flipper.love game -t "Flipper - Coin Flipping Roguelike" --compatibility

# Copy custom CSS if it exists
if [ -f "custom-theme/love.css" ]; then
    echo "Applying custom CSS..."
    cp custom-theme/love.css game/theme/love.css
    echo "Custom CSS applied!"
else
    echo "Warning: custom-theme/love.css not found. Using default CSS."
fi

echo "Build complete! Open game/index.html to test."

