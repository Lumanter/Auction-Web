const pg = require('pg');
pg.types.setTypeParser(1114, (str) => str);  // don't parse timestamps strings into date js objects
const {Pool} = pg;


const db = new Pool({
    host: 'localhost',
    user: 'auctionwebapp',
    password: 'auctionwebapp',
    database: 'auctionweb',
    port: '5432'
});


module.exports = {db};

