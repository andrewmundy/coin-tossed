// Auto-scaling fix for love.js games
// This makes the game scale to fit the screen while maintaining aspect ratio

(function() {
    const GAME_WIDTH = 800;
    const GAME_HEIGHT = 600;
    const ASPECT_RATIO = GAME_WIDTH / GAME_HEIGHT;

    function scaleCanvas() {
        const canvas = document.getElementById('canvas');
        if (!canvas) return;

        const windowWidth = window.innerWidth;
        const windowHeight = window.innerHeight;
        const windowAspect = windowWidth / windowHeight;

        let scale;
        if (windowAspect > ASPECT_RATIO) {
            // Window is wider than game - fit to height
            scale = windowHeight / GAME_HEIGHT;
        } else {
            // Window is taller than game - fit to width
            scale = windowWidth / GAME_WIDTH;
        }

        // Apply scaling
        const scaledWidth = GAME_WIDTH * scale;
        const scaledHeight = GAME_HEIGHT * scale;

        canvas.style.width = scaledWidth + 'px';
        canvas.style.height = scaledHeight + 'px';
        
        // Keep the internal resolution the same
        if (!canvas.width || canvas.width === 0) {
            canvas.width = GAME_WIDTH;
            canvas.height = GAME_HEIGHT;
        }
    }

    // Scale on load
    window.addEventListener('load', scaleCanvas);
    
    // Scale on resize
    window.addEventListener('resize', scaleCanvas);
    
    // Scale immediately if canvas exists
    if (document.readyState === 'complete') {
        scaleCanvas();
    }
    
    // Try to scale periodically for the first few seconds (in case canvas loads late)
    let attempts = 0;
    const scaleInterval = setInterval(function() {
        scaleCanvas();
        attempts++;
        if (attempts > 10) {
            clearInterval(scaleInterval);
        }
    }, 500);
})();

