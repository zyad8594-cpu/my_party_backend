# Vercel Speed Insights Configuration

This project has been configured with Vercel Speed Insights to track Core Web Vitals metrics.

## Overview

Vercel Speed Insights is primarily designed for client-side applications. Since this is an Express.js API backend, the integration is set up to:

1. Automatically inject Speed Insights tracking script into any HTML responses
2. Provide utilities for manual HTML generation with Speed Insights support

## Automatic Integration

The `speedInsightsMiddleware` in `middlewares/speedInsights.js` automatically injects the Speed Insights tracking script into any HTML responses served by this backend.

### Configuration Options

You can configure Speed Insights using environment variables:

```env
# Enable debug mode (default: false, auto-enabled in development)
NODE_ENV=development

# Sample rate for tracking (0.0 to 1.0, default: 1.0)
# Use 0.5 to track only 50% of events for cost optimization
SPEED_INSIGHTS_SAMPLE_RATE=1.0
```

## Manual Integration

If you need to manually add Speed Insights to HTML content, you can use the utility function:

```javascript
const { generateSpeedInsightsScript } = require('./middlewares/speedInsights');

// Generate the tracking script
const trackingScript = generateSpeedInsightsScript({
    debug: true,
    sampleRate: 0.5
});

// Include it in your HTML
const html = `
<!DOCTYPE html>
<html>
<head>
    <title>My Page</title>
    ${trackingScript}
</head>
<body>
    <h1>Hello World</h1>
</body>
</html>
`;
```

## Vercel Dashboard Setup

To enable Speed Insights in your Vercel project:

1. Go to your project in the Vercel dashboard
2. Navigate to the "Speed Insights" tab
3. Click the "Enable" button
4. Deploy your application to Vercel

After deployment, the tracking script at `/_vercel/speed-insights/script.js` will be automatically served by Vercel's infrastructure.

## For Frontend Applications

If you have a separate frontend application (React, Vue, Next.js, etc.) that consumes this API:

1. Install `@vercel/speed-insights` in your frontend project
2. Follow the framework-specific integration guide at https://vercel.com/docs/speed-insights/quickstart
3. The frontend will track its own Core Web Vitals independently

## Metrics Tracked

Speed Insights automatically tracks:

- **First Contentful Paint (FCP)**: Time until first content is rendered
- **Largest Contentful Paint (LCP)**: Time until largest content element is rendered
- **First Input Delay (FID)**: Time until page becomes interactive
- **Cumulative Layout Shift (CLS)**: Visual stability of the page
- **Time to First Byte (TTFB)**: Server response time

## Cost Management

Speed Insights has usage-based pricing. To reduce costs:

1. Set `SPEED_INSIGHTS_SAMPLE_RATE` to a value less than 1.0 (e.g., 0.5 for 50% sampling)
2. Monitor usage in the Vercel dashboard
3. Use the `beforeSend` option to filter specific events (can be added to the middleware)

## Additional Resources

- [Speed Insights Quickstart](https://vercel.com/docs/speed-insights/quickstart)
- [Speed Insights Package Documentation](https://vercel.com/docs/speed-insights/package)
- [Managing Usage & Costs](https://vercel.com/docs/speed-insights/managing-usage)
