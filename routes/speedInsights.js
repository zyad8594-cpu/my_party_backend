const express = require('express');
const router = express.Router();
const ApiResponse = require('../utils/apiResponse');
const { getSpeedInsightsConfig, getSpeedInsightsScriptTag } = require('../utils/speedInsights');

/**
 * @route   GET /api/speed-insights/config
 * @desc    Get Speed Insights configuration
 * @access  Public
 */
router.get('/config', (req, res) => {
    try {
        const config = getSpeedInsightsConfig({
            debug: req.query.debug === 'true',
            sampleRate: req.query.sampleRate ? parseFloat(req.query.sampleRate) : undefined,
            route: req.query.route || null,
        });

        ApiResponse.success(res, 'Speed Insights configuration retrieved', config);
    } catch (error) {
        ApiResponse.error(res, 'Failed to get Speed Insights configuration', 500, error);
    }
});

/**
 * @route   GET /api/speed-insights/script
 * @desc    Get Speed Insights script tag for HTML injection
 * @access  Public
 */
router.get('/script', (req, res) => {
    try {
        const scriptTag = getSpeedInsightsScriptTag();
        res.type('text/plain').send(scriptTag);
    } catch (error) {
        ApiResponse.error(res, 'Failed to get Speed Insights script', 500, error);
    }
});

/**
 * @route   GET /api/speed-insights/health
 * @desc    Check if Speed Insights is configured
 * @access  Public
 */
router.get('/health', (req, res) => {
    try {
        const packageJson = require('../package.json');
        const speedInsightsVersion = packageJson.dependencies['@vercel/speed-insights'];
        
        ApiResponse.success(res, 'Speed Insights is configured', {
            installed: !!speedInsightsVersion,
            version: speedInsightsVersion,
            status: 'active',
        });
    } catch (error) {
        ApiResponse.error(res, 'Failed to check Speed Insights status', 500, error);
    }
});

module.exports = router;
