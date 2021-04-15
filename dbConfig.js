const oracledb = require('oracledb');


const dbConfig = {
    user: "c##auctionweb",
    password: 'auctionweb',
    connectString: 'localhost/orcl'
};

async function db() {
    return await oracledb.getConnection({
        user: "c##auctionweb",
        password: 'auctionweb',
        connectString: 'localhost/orcl'
    });
} 


async function query(query, bindings=[]) {
    let results = await (await db()).execute(query, bindings, {outFormat: oracledb.OUT_FORMAT_OBJECT});
    return results.rows;
}


function parseUser (user) {
    return {
        id: user.ID,
        isadmin: (user.ISADMIN == 'T'),
        nickname: user.NICKNAME,
        email: user.EMAIL,
        firstname: user.FIRSTNAME,
        lastname: user.LASTNAME,
        address: user.ADDRESS
    }
}


function parseError(error) {
    let msg = error.message;
    msg = msg.substring(msg.indexOf(":") + 2);  // cut error code number
    msg = msg.substring(0, msg.indexOf("ORA")-1);  // cut error line number
    return msg; 
}


module.exports = {dbConfig, query, parseUser, parseError};
