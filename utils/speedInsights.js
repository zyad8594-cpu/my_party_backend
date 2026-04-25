const { injectSpeedInsights } = require('@vercel/speed-insights');

/**
 * Speed Insights Configuration Utility
 * 
 * This module provides Speed Insights integration for the backend.
 * Since this is a backend API, Speed Insights tracking happens on the client side.
 * This utility can be used when serving HTML or providing configuration to frontend clients.
 */

/**
 * Get Speed Insights configuration
 * This can be used to pass configuration to frontend applications
 * 
 * @param {Object} options - Speed Insights options
 * @param {boolean} options.debug - Enable debug mode (default: false in production)
 * @param {number} options.sampleRate - Sample rate for events (0-1, default: 1)
 * @param {string} options.route - Dynamic route of the page
 * @returns {Object} Speed Insights configuration
 */
function getSpeedInsightsConfig(options = {}) {
    return {
        debug: options.debug || process.env.NODE_ENV !== 'production',
        sampleRate: options.sampleRate || 1,
        route: options.route || null,
        framework: 'express',
    };
}

/**
 * Generate Speed Insights script tag for HTML injection
 * Use this when serving HTML pages from the backend
 * 
 * @returns {string} HTML script tag for Speed Insights
 */
function getSpeedInsightsScriptTag() {
    return `
    <script>
        window.si = window.si || function () { (window.siq = window.siq || []).push(arguments); };
    </script>
    <script type="module">
        import { injectSpeedInsights } from '/_vercel/speed-insights/script.js';
        injectSpeedInsights();
    </script>
    `;
}

/**
 * Initialize Speed Insights in a browser context
 * This function is primarily for documentation purposes as the backend doesn't run in a browser
 * 
 * @param {Object} options - Speed Insights options
 * @returns {Object|null} Speed Insights instance or null if not in browser context
 */
function initSpeedInsights(options = {}) {
    // Check if we're in a browser environment
    if (typeof window === 'undefined') {
        console.log('Speed Insights: Not in browser environment. Speed Insights tracking is client-side only.');
        return null;
    }

    // Initialize Speed Insights with options
    const config = getSpeedInsightsConfig(options);
    return injectSpeedInsights(config);
}

module.exports = {
    getSpeedInsightsConfig,
    getSpeedInsightsScriptTag,
    initSpeedInsights,
};
