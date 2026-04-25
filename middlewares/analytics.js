const { track } = require('@vercel/analytics/server');

/**
 * Vercel Web Analytics Middleware
 * Tracks API requests and custom events for analytics
 */
const analyticsMiddleware = async (req, res, next) => {
    // Only track in production or when VERCEL environment variable is set
    const isVercelEnvironment = process.env.VERCEL || process.env.NODE_ENV === 'production';
    
    if (!isVercelEnvironment) {
        return next();
    }

    try {
        // Track the request as a custom event
        const eventName = 'api_request';
        const properties = {
            method: req.method,
            path: req.path,
            url: req.originalUrl || req.url,
            timestamp: new Date().toISOString()
        };

        // Track the event with request headers for proper attribution
        await track(eventName, properties, {
            headers: req.headers
        });
    } catch (error) {
        // Don't block the request if analytics fails
        console.error('Analytics tracking error:', error.message);
    }

    next();
};

/**
 * Track custom events manually
 * @param {string} eventName - Name of the event to track
 * @param {object} properties - Event properties
 * @param {object} options - Additional options including headers
 */
const trackEvent = async (eventName, properties = {}, options = {}) => {
    const isVercelEnvironment = process.env.VERCEL || process.env.NODE_ENV === 'production';
    
    if (!isVercelEnvironment) {
        console.log('[Analytics - Dev Mode]', eventName, properties);
        return;
    }

    try {
        await track(eventName, properties, options);
    } catch (error) {
        console.error('Analytics tracking error:', error.message);
    }
};

module.exports = {
    analyticsMiddleware,
    trackEvent
};
