/**
 * Test script for Vercel Speed Insights middleware
 * 
 * This script tests that the Speed Insights tracking script is correctly
 * injected into HTML responses.
 */

const { generateSpeedInsightsScript, speedInsightsMiddleware } = require('./middlewares/speedInsights');

console.log('🧪 Testing Vercel Speed Insights Integration\n');

// Test 1: Generate Speed Insights Script
console.log('Test 1: Generate Speed Insights Script');
console.log('==========================================');
const script = generateSpeedInsightsScript({ debug: true, sampleRate: 0.5 });
console.log('✅ Generated script:');
console.log(script);
console.log('');

// Test 2: Middleware with HTML response
console.log('Test 2: Middleware HTML Injection');
console.log('==========================================');

const mockReq = {};
const mockRes = {
    _headers: { 'content-type': 'text/html' },
    get: function(name) {
        return this._headers[name.toLowerCase()];
    },
    send: function(data) {
        this.sentData = data;
    }
};

const middleware = speedInsightsMiddleware({ debug: true });

// Simulate middleware call
middleware(mockReq, mockRes, () => {});

// Test with HTML that has </head>
const testHTML1 = `
<!DOCTYPE html>
<html>
<head>
    <title>Test Page</title>
</head>
<body>
    <h1>Hello World</h1>
</body>
</html>
`;

mockRes.send(testHTML1);

if (mockRes.sentData.includes('window.si')) {
    console.log('✅ Speed Insights script successfully injected into HTML with </head> tag');
} else {
    console.log('❌ Failed to inject script into HTML with </head> tag');
}
console.log('');

// Test 3: Middleware with HTML that only has </body>
console.log('Test 3: HTML Injection (only </body> tag)');
console.log('==========================================');

const mockRes2 = {
    _headers: { 'content-type': 'text/html' },
    get: function(name) {
        return this._headers[name.toLowerCase()];
    },
    send: function(data) {
        this.sentData = data;
    }
};

middleware(mockReq, mockRes2, () => {});

const testHTML2 = `
<!DOCTYPE html>
<html>
<body>
    <h1>Hello World</h1>
</body>
</html>
`;

mockRes2.send(testHTML2);

if (mockRes2.sentData.includes('window.si')) {
    console.log('✅ Speed Insights script successfully injected into HTML with </body> tag');
} else {
    console.log('❌ Failed to inject script into HTML with </body> tag');
}
console.log('');

// Test 4: Middleware with non-HTML response
console.log('Test 4: Non-HTML Response (should not inject)');
console.log('==========================================');

const mockRes3 = {
    _headers: { 'content-type': 'application/json' },
    get: function(name) {
        return this._headers[name.toLowerCase()];
    },
    send: function(data) {
        this.sentData = data;
    }
};

middleware(mockReq, mockRes3, () => {});

const testJSON = JSON.stringify({ message: 'Hello World' });
mockRes3.send(testJSON);

if (!mockRes3.sentData.includes('window.si')) {
    console.log('✅ Script correctly NOT injected into JSON response');
} else {
    console.log('❌ Script incorrectly injected into JSON response');
}
console.log('');

console.log('🎉 All tests completed!');
console.log('');
console.log('Note: The middleware is now active in index.js and will automatically');
console.log('inject Speed Insights tracking into any HTML responses served by the API.');
