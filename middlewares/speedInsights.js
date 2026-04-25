/**
 * Vercel Speed Insights Middleware
 * 
 * This middleware automatically injects Vercel Speed Insights tracking script
 * into HTML responses. This allows tracking of Core Web Vitals metrics for any
 * HTML pages served by this Express backend.
 * 
 * Note: Speed Insights is primarily designed for client-side applications.
 * For API-only backends, this middleware will be inactive unless HTML is served.
 */

/**
 * Generates the Speed Insights tracking script
 * @param {Object} options - Configuration options
 * @param {number} options.sampleRate - Percentage of events to send (0-1)
 * @param {boolean} options.debug - Enable debug mode
 * @returns {string} The tracking script HTML
 */
function generateSpeedInsightsScript(options = {}) {
    const { sampleRate = 1, debug = false } = options;
    
    // Generate configuration if options are provided
    let configScript = '';
    if (sampleRate !== 1 || debug) {
        const config = {};
        if (sampleRate !== 1) config.sampleRate = sampleRate;
        if (debug) config.debug = debug;
        
        configScript = `<script>window.speedInsightsConfig = ${JSON.stringify(config)};</script>\n`;
    }
    
    // The Speed Insights tracking script (as per Vercel documentation)
    const trackingScript = `<script>
  window.si = window.si || function () { (window.siq = window.siq || []).push(arguments); };
</script>
<script defer src="/_vercel/speed-insights/script.js"></script>`;
    
    return configScript + trackingScript;
}

/**
 * Express middleware to inject Speed Insights into HTML responses
 * @param {Object} options - Configuration options
 * @returns {Function} Express middleware function
 */
function speedInsightsMiddleware(options = {}) {
    const script = generateSpeedInsightsScript(options);
    
    return function(req, res, next) {
        // Store original send function
        const originalSend = res.send;
        
        // Override send function
        res.send = function(data) {
            // Check if response is HTML
            const contentType = res.get('Content-Type');
            if (contentType && contentType.includes('text/html') && typeof data === 'string') {
                // Inject Speed Insights script before closing </head> tag or before </body>
                if (data.includes('</head>')) {
                    data = data.replace('</head>', `${script}\n</head>`);
                } else if (data.includes('</body>')) {
                    data = data.replace('</body>', `${script}\n</body>`);
                }
            }
            
            // Call original send with modified data
            originalSend.call(this, data);
        };
        
        next();
    };
}

module.exports = {
    speedInsightsMiddleware,
    generateSpeedInsightsScript
};
