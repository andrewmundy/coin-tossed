#!/bin/bash

# Build script for web version with custom CSS
# This builds the game and automatically applies your custom CSS

echo "Step 1: Creating Flipper.love from source files..."
zip -r Flipper.love . -x "*.git*" -x "*.DS_Store" -x "*.sh" -x "*.md" -x "game/*" -x "custom-theme/*" -x "Flipper.app/*" > /dev/null 2>&1

echo "Step 2: Building web version..."
npx --yes love.js Flipper.love game -t "Stater - Coinlike Roguelike" --compatibility

# Copy custom CSS if it exists
if [ -f "custom-theme/love.css" ]; then
    echo "Step 3: Applying custom CSS..."
    cp custom-theme/love.css game/theme/love.css
    echo "Custom CSS applied!"
else
    echo "Warning: custom-theme/love.css not found. Using default CSS."
fi

# Inject scaling fix into HTML
if [ -f "scale-fix.js" ]; then
    echo "Step 4: Injecting responsive scaling fix..."
    # Copy the scale fix to the game directory
    cp scale-fix.js game/scale-fix.js
    
    # Add script tag to index.html if it doesn't exist
    if ! grep -q "scale-fix.js" game/index.html; then
        # Insert script tag before closing </head> tag
        sed -i '' 's|</head>|    <script src="scale-fix.js"></script>\n  </head>|' game/index.html
        echo "Scaling fix injected!"
    else
        echo "Scaling fix already present."
    fi
fi

echo "Build complete! Open game/index.html to test."

