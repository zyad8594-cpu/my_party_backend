require('dotenv').config();
const servicesController = require('./controllers/servicesController');
const pool = require('./config/db');

async function run() {
  const req = {
    user: {
      role_name: 'coordinator',
      user_id: 1 // Assuming 1 is a valid coordinator user_id
    }
  };
  
  const res = {
    status: function(s) { this.statusCode = s; return this; },
    json: function(data) { console.log(JSON.stringify(data, null, 2)); },
    send: function() {}
  };

  // Mocking ApiResponse.success format since servicesController uses it
  const ApiResponse = require('./utils/apiResponse');
  
  console.log('Testing getAllServices...');
  await servicesController.getAllServices(req, res);
  
  process.exit();
}

run();
