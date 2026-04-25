const express = require('express');
const router = express.Router();
const { getSpeedInsightsScript } = require('../middlewares/speedInsights');

/**
 * Demo HTML page with Vercel Speed Insights
 * 
 * This is an example route showing how to integrate Speed Insights
 * into HTML pages served by this backend.
 */
router.get('/html-demo', (req, res) => {
  const html = `
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Party Pro - Demo Page with Speed Insights</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
        }
        .container {
            background: white;
            border-radius: 10px;
            padding: 40px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        h1 {
            color: #667eea;
            margin-bottom: 20px;
        }
        .info-box {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }
        .success {
            background: #d4edda;
            border-left-color: #28a745;
            color: #155724;
        }
        code {
            background: #e9ecef;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
        }
        ul {
            line-height: 1.8;
        }
        .badge {
            display: inline-block;
            padding: 5px 10px;
            background: #667eea;
            color: white;
            border-radius: 20px;
            font-size: 12px;
            margin-left: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 My Party Pro <span class="badge">Speed Insights Enabled</span></h1>
        
        <div class="info-box success">
            <strong>✅ Vercel Speed Insights is Active!</strong>
            <p>This page is being monitored for performance metrics.</p>
        </div>

        <div class="info-box">
            <h3>What is Speed Insights?</h3>
            <p>Vercel Speed Insights automatically tracks web performance metrics including:</p>
            <ul>
                <li><strong>LCP (Largest Contentful Paint):</strong> Loading performance</li>
                <li><strong>FID (First Input Delay):</strong> Interactivity</li>
                <li><strong>CLS (Cumulative Layout Shift):</strong> Visual stability</li>
                <li><strong>FCP (First Contentful Paint):</strong> Perceived load speed</li>
                <li><strong>TTFB (Time to First Byte):</strong> Server response time</li>
            </ul>
        </div>

        <div class="info-box">
            <h3>How to Use in Your Application</h3>
            <p>To add Speed Insights to your HTML responses:</p>
            <ol>
                <li>Import the middleware: <code>const { speedInsightsMiddleware } = require('./middlewares/speedInsights');</code></li>
                <li>Apply globally: <code>app.use(speedInsightsMiddleware);</code></li>
                <li>Or apply to specific routes: <code>app.use('/your-route', speedInsightsMiddleware, yourRouter);</code></li>
            </ol>
        </div>

        <div class="info-box">
            <h3>View Your Analytics</h3>
            <p>Once deployed to Vercel, you can view performance metrics in the <a href="https://vercel.com/dashboard" target="_blank">Vercel Dashboard</a> under Speed Insights.</p>
            <p><strong>Note:</strong> Data is only collected in production environments, not during development.</p>
        </div>

        <div class="info-box">
            <h3>API Information</h3>
            <p>This backend provides the following API endpoints:</p>
            <ul>
                <li>🔐 /api/auth - Authentication</li>
                <li>📅 /api/events - Event management</li>
                <li>✅ /api/tasks - Task management</li>
                <li>🤝 /api/suppliers - Supplier management</li>
                <li>⚙️ /api/services - Service management</li>
                <li>👥 /api/coordinators - Coordinator management</li>
                <li>🔔 /api/notifications - Notifications</li>
                <li>👤 /api/clients - Client management</li>
                <li>💰 /api/incomes - Income tracking</li>
                <li>👤 /api/users - User management</li>
                <li>📊 /api/dashboard - Dashboard data</li>
                <li>🔑 /api/roles - Role management</li>
                <li>⚙️ /api/system_users - System user management</li>
            </ul>
        </div>
    </div>
    ${getSpeedInsightsScript()}
</body>
</html>
  `;

  res.type('html').send(html);
});

/**
 * API endpoint to check if Speed Insights is configured
 */
router.get('/speed-insights-status', (req, res) => {
  res.json({
    success: true,
    message: 'Vercel Speed Insights is configured',
    package_version: require('@vercel/speed-insights/package.json').version,
    integration_type: 'middleware',
    demo_page: '/api/demo/html-demo',
    note: 'Speed Insights tracks performance for HTML pages. For API-only endpoints, consider using Vercel Analytics instead.',
    documentation: 'https://vercel.com/docs/speed-insights'
  });
});

module.exports = router;
