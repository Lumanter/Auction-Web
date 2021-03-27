const {Pool} = require('pg');


const db = new Pool({
    host: 'localhost',
    user: 'postgres',
    password: 'postgres',
    database: 'auctionweb',
    port: '5432'
});


module.exports = {db};

