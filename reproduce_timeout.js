const https = require('https');

console.log('--- Testing HTTPS connection to fcm.googleapis.com ---');

const options = {
  hostname: 'fcm.googleapis.com',
  port: 443,
  path: '/',
  method: 'GET'
  // family: 4 // Force IPv4
};

const req = https.request(options, (res) => {
  console.log(`STATUS: ${res.statusCode}`);
  res.on('data', (d) => {
    // console.log(d.toString());
  });
});

req.on('error', (e) => {
  console.error(`❌ Connection failed: ${e.message}`);
});

req.setTimeout(5000, () => {
    console.log('🕒 Request timed out after 5s');
    req.destroy();
});

req.end();
