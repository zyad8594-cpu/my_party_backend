require('dotenv').config();
const servicesController = require('./controllers/servicesController');
const pool = require('./config/db');

async function run() {
  const req = {
    user: {
      role_name: 'admin',
      user_id: 1 // Assuming 1 could be admin
    }
  };
  
  const res = {
    status: function(s) { this.statusCode = s; return this; },
    json: function(data) { console.log(JSON.stringify(data).substring(0, 500) + '...'); },
    send: function() {}
  };

  const ApiResponse = require('./utils/apiResponse');
  
  console.log('Testing getAllServices with ADMIN...');
  try {
      await servicesController.getAllServices(req, res);
  } catch(e) {
      console.log('Error:', e);
  }
  
  process.exit();
}

run();
