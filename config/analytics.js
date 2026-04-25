/**
 * Vercel Analytics Configuration
 * 
 * This module provides analytics utilities for the My Party Pro backend.
 * 
 * Note: Vercel Web Analytics is primarily designed for client-side tracking.
 * The main implementation is in the public/index.html file.
 * 
 * For server-side monitoring, consider:
 * - Vercel Speed Insights (@vercel/speed-insights)
 * - Custom logging and metrics
 * - Third-party APM tools
 */

/**
 * Track a custom event (placeholder for future server-side tracking)
 * @param {string} eventName - Name of the event
 * @param {object} properties - Event properties
 */
const trackEvent = (eventName, properties = {}) => {
    // Currently, Vercel Analytics doesn't support server-side event tracking
    // This is a placeholder for future implementation or custom analytics
    if (process.env.NODE_ENV === 'development') {
        console.log(`[Analytics] Event: ${eventName}`, properties);
    }
};

/**
 * Track API endpoint usage (custom implementation)
 * @param {string} endpoint - API endpoint path
 * @param {string} method - HTTP method
 * @param {number} duration - Request duration in ms
 */
const trackApiCall = (endpoint, method, duration) => {
    if (process.env.NODE_ENV === 'development') {
        console.log(`[Analytics] API Call: ${method} ${endpoint} - ${duration}ms`);
    }
    // Future: Send to custom analytics service or logging platform
};

/**
 * Middleware to track API calls (optional usage)
 */
const analyticsMiddleware = (req, res, next) => {
    const startTime = Date.now();
    
    res.on('finish', () => {
        const duration = Date.now() - startTime;
        trackApiCall(req.path, req.method, duration);
    });
    
    next();
};

module.exports = {
    trackEvent,
    trackApiCall,
    analyticsMiddleware
};
