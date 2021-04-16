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


const parseDate = (date) => date.toISOString().replace('T', ' ').replace('Z', ' ').split('.')[0];


function parseSellerHistory(history) {
    return {
        auctionid: history.AUCTIONID,
        itemname: history.ITEMNAME,
        baseprice: history.BASEPRICE,
        startdate: parseDate(history.STARTDATE),
        buyerUserId: history.BUYERUSERID,
        buyerNickname: history.BUYERNICKNAME,
        amount: history.AMOUNT,
        isClosed: (history.ISCLOSED ? history.ISCLOSED == 'T' : null),
        itemWasSold: (history.ITEMWASSOLD ? history.ITEMWASSOLD == 'T' : null),
        buyerComment: history.BUYERCOMMENT,
        buyerRating: history.BUYERRATING
    }
}


function parseBuyerHistory(history) {
    return {
        auctionid: history.AUCTIONID,
        itemname: history.ITEMNAME,
        baseprice: history.BASEPRICE,
        amount: history.AMOUNT,
        biddate: parseDate(history.BIDDATE),
        windate: (history.WINDATE ? parseDate(history.WINDATE) : null),
        sellercomment: history.SELLERCOMMENT,
        sellerrating: history.SELLERRATING
    }
}


module.exports = {dbConfig, query, parseUser, parseError, parseDate, parseSellerHistory, parseBuyerHistory};
