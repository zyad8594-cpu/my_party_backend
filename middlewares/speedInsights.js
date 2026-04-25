/**
 * Vercel Speed Insights Middleware
 * 
 * This middleware injects the Vercel Speed Insights script into HTML responses.
 * Speed Insights tracks web performance metrics (Web Vitals) for client-side applications.
 * 
 * Note: This middleware only works with HTML responses. For API-only backends,
 * Speed Insights should be integrated on the frontend/client side instead.
 * 
 * Usage:
 * - Apply this middleware to routes that serve HTML content
 * - The script will automatically track performance metrics when the page loads in a browser
 * - Data will only be collected in production environments (not in development)
 */

const { injectSpeedInsights } = require('@vercel/speed-insights');

/**
 * Middleware to inject Speed Insights into HTML responses
 * This intercepts the response and adds the tracking script to HTML content
 */
function speedInsightsMiddleware(req, res, next) {
  // Store the original send function
  const originalSend = res.send;

  // Override the send function
  res.send = function (data) {
    // Check if the response is HTML
    const contentType = res.get('Content-Type');
    
    if (contentType && contentType.includes('text/html') && typeof data === 'string') {
      // Inject Speed Insights script into HTML
      // The injectSpeedInsights() function returns the script tag that should be added
      const speedInsightsScript = getSpeedInsightsScript();
      
      // Try to inject before closing body tag, or before closing html tag, or append
      if (data.includes('</body>')) {
        data = data.replace('</body>', `${speedInsightsScript}</body>`);
      } else if (data.includes('</html>')) {
        data = data.replace('</html>', `${speedInsightsScript}</html>`);
      } else {
        data = data + speedInsightsScript;
      }
    }

    // Call the original send function with potentially modified data
    originalSend.call(this, data);
  };

  next();
}

/**
 * Generate the Speed Insights script tag
 * This script will be injected into HTML pages to track performance
 */
function getSpeedInsightsScript() {
  // Speed Insights script - this loads the tracking library
  // The actual implementation uses the inject function from @vercel/speed-insights
  return `
    <script type="module">
      import { injectSpeedInsights } from 'https://cdn.jsdelivr.net/npm/@vercel/speed-insights@2.0.0/dist/index.mjs';
      injectSpeedInsights();
    </script>
  `;
}

/**
 * Alternative: Generate Speed Insights script for server-side rendering
 * This can be used to manually add Speed Insights to your HTML templates
 */
function getSpeedInsightsScriptForSSR() {
  return getSpeedInsightsScript();
}

module.exports = {
  speedInsightsMiddleware,
  getSpeedInsightsScript,
  getSpeedInsightsScriptForSSR
};
