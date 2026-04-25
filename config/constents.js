const auth = require('../middlewares/auth');
const serverBasecPath = 'http://192.168.1.3:3000';

const authorizeRole = {
    full: ()=> auth.authorizeRole(['admin', 'coordinator', 'supplier', 'client']),
    onlyAdmin: ()=> auth.authorizeRole(['admin']),
    onlyAdminAnd: (roles)=>{
        const isArray = Array.isArray(roles);
        if(isArray) return auth.authorizeRole(['admin', ...roles]);
        if(typeof(roles) === 'string' && roles !== '') return auth.authorizeRole(['admin', roles]);
        return auth.authorizeRole(['admin']);
    },
    subAdmin: ()=> auth.authorizeRole(['admin', 'coordinator']),
    fullAdmin: ()=> auth.authorizeRole(['admin', 'coordinator', 'supplier']),
    none: (next)=> next,
    select: (rolse)=> auth.authorizeRole(Array.isArray(rolse) ? rolse : [rolse])
}

module.exports = { authorizeRole, authenticateToken: auth.authenticateToken, serverBasecPath};