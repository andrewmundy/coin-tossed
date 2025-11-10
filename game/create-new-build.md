Step 1: Create a .love file
First, package your game:
zip -9 -r Flipper.love . -x "_.git_" -x "_.DS_Store" -x "build_mac.sh" -x "Flipper.love"
cd /Users/andrewmundy/Development/Flipperzip -9 -r Flipper.love . -x "_.git*" -x "*.DS_Store" -x "build_mac.sh" -x "Flipper.love"
Step 2: Install love.js
npm install -g love.js
npm install -g love.js
Step 3: Convert to web
love-js Flipper.love game -t "Flipper - Coin Flipping Roguelike"
love-js Flipper.love game -t "Flipper - Coin Flipping Roguelike"
