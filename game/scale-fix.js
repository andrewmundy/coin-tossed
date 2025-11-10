// Auto-scaling fix for love.js games
// Scale canvas to fit screen while maintaining aspect ratio

(function() {
    const GAME_WIDTH = 800;
    const GAME_HEIGHT = 600;
    const ASPECT_RATIO = GAME_WIDTH / GAME_HEIGHT;
    
    // Detect mobile devices
    function isMobile() {
        return window.IS_MOBILE_DEVICE || false;
    }

    function resizeCanvas() {
        const canvas = document.getElementById('canvas');
        const loadingCanvas = document.getElementById('loadingCanvas');
        
        if (!canvas) return;

        // Get viewport dimensions
        const viewportWidth = window.innerWidth;
        const viewportHeight = window.innerHeight;
        const viewportAspect = viewportWidth / viewportHeight;

        let scale;
        
        if (isMobile()) {
            // Mobile: scale to fill screen (may crop some edges)
            const scaleX = viewportWidth / GAME_WIDTH;
            const scaleY = viewportHeight / GAME_HEIGHT;
            scale = Math.max(scaleX, scaleY);  // Fill screen
            
            // Center using CSS transforms
            const transformOrigin = 'center center';
            const transform = 'scale(' + scale + ')';
            
            canvas.style.transformOrigin = transformOrigin;
            canvas.style.transform = transform;
            canvas.style.position = 'absolute';
            canvas.style.left = '50%';
            canvas.style.top = '50%';
            canvas.style.marginLeft = '-' + (GAME_WIDTH / 2) + 'px';
            canvas.style.marginTop = '-' + (GAME_HEIGHT / 2) + 'px';
            
            if (loadingCanvas) {
                loadingCanvas.style.transformOrigin = transformOrigin;
                loadingCanvas.style.transform = transform;
                loadingCanvas.style.position = 'absolute';
                loadingCanvas.style.left = '50%';
                loadingCanvas.style.top = '50%';
                loadingCanvas.style.marginLeft = '-' + (GAME_WIDTH / 2) + 'px';
                loadingCanvas.style.marginTop = '-' + (GAME_HEIGHT / 2) + 'px';
            }
        } else {
            // Desktop: maintain aspect ratio with letterboxing
            if (viewportAspect > ASPECT_RATIO) {
                // Viewport is wider - fit to height
                scale = viewportHeight / GAME_HEIGHT;
            } else {
                // Viewport is taller - fit to width
                scale = viewportWidth / GAME_WIDTH;
            }

            // Use CSS transform to scale
            const transformOrigin = 'top left';
            const transform = 'scale(' + scale + ')';
            
            canvas.style.transformOrigin = transformOrigin;
            canvas.style.transform = transform;
            canvas.style.position = 'absolute';
            
            if (loadingCanvas) {
                loadingCanvas.style.transformOrigin = transformOrigin;
                loadingCanvas.style.transform = transform;
                loadingCanvas.style.position = 'absolute';
            }

            // Center the scaled canvas
            const scaledWidth = GAME_WIDTH * scale;
            const scaledHeight = GAME_HEIGHT * scale;
            const offsetX = (viewportWidth - scaledWidth) / 2;
            const offsetY = (viewportHeight - scaledHeight) / 2;
            
            canvas.style.left = offsetX + 'px';
            canvas.style.top = offsetY + 'px';
            
            if (loadingCanvas) {
                loadingCanvas.style.left = offsetX + 'px';
                loadingCanvas.style.top = offsetY + 'px';
            }
        }
    }

    // Make resizeCanvas globally accessible
    window.resizeCanvas = resizeCanvas;
    
    // Resize on window load and resize
    window.addEventListener('load', resizeCanvas);
    window.addEventListener('resize', resizeCanvas);
    window.addEventListener('orientationchange', function() {
        setTimeout(resizeCanvas, 100);
    });
    
    // Keep trying to resize for the first few seconds (until love.js loads)
    const resizeInterval = setInterval(resizeCanvas, 100);
    setTimeout(function() {
        clearInterval(resizeInterval);
    }, 5000);
    
    // Initial resize
    resizeCanvas();

    // Override LÖVE's mouse position handling to account for scaling
    // Store the original Module if it exists
    let originalModule = window.Module;
    
    // Wait for Module to be available, then wrap its input handlers
    setTimeout(function() {
        if (window.Module && window.Module.canvas) {
            // The canvas coordinate transformation is handled by the browser
            // because we're using CSS transform, which automatically adjusts
            // mouse/touch coordinates
        }
    }, 1000);

    // Prevent zoom on double tap (iOS)
    document.addEventListener('touchstart', function(event) {
        if (event.touches.length > 1) {
            event.preventDefault();
        }
    }, { passive: false });

    let lastTouchEnd = 0;
    document.addEventListener('touchend', function(event) {
        const now = (new Date()).getTime();
        if (now - lastTouchEnd <= 300) {
            event.preventDefault();
        }
        lastTouchEnd = now;
    }, false);

    // Prevent context menu on long press (mobile)
    window.addEventListener('contextmenu', function(e) {
        e.preventDefault();
    });
})();

