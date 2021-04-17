const oracledb = require('oracledb');
oracledb.fetchAsBuffer = [oracledb.BLOB];  // fetch image blobs as buffers

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
        buyeruserid: history.BUYERUSERID,
        buyernickname: history.BUYERNICKNAME,
        amount: history.AMOUNT,
        isclosed: (history.ISCLOSED ? history.ISCLOSED == 'T' : null),
        itemwasSold: (history.ITEMWASSOLD ? history.ITEMWASSOLD == 'T' : null),
        buyercomment: history.BUYERCOMMENT,
        buyerrating: history.BUYERRATING
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


function parseAuction(auction) {
    return {
        id: auction.ID,
        itemname: auction.ITEMNAME,
        subcategoryid: auction.SUBCATEGORYID,
        userid: auction.USERID,
        bestbidid: auction.BESTBIDID,
        baseprice: auction.BASEPRICE,
        startdate: parseDate(auction.STARTDATE),
        enddate: parseDate(auction.ENDDATE),
        itemdescription: auction.ITEMDESCRIPTION,
        deliverydetails: auction.DELIVERYDETAILS,
        itemphoto: auction.ITEMPHOTO,
        isclosed: (auction.ISCLOSED ? auction.ISCLOSED == 'T' : null),
        itemwassold: (auction.ITEMWASSOLD ? auction.ITEMWASSOLD == 'T' : null)
    }
}


function parseAuctionInfo(auction) {
    return {
        auctionid: auction.AUCTIONID,
        itemname: auction.ITEMNAME,
        subcategoryname: auction.SUBCATEGORYNAME,
        sellerid: auction.SELLERID,
        sellernickname: auction.SELLERNICKNAME,
        baseprice: auction.BASEPRICE,
        currentprice: auction.CURRENTPRICE,
        minbid: auction.MINBID,
        startdate: parseDate(auction.STARTDATE),
        enddate: parseDate(auction.ENDDATE),
        itemdescription: auction.ITEMDESCRIPTION,
        deliverydetails: auction.DELIVERYDETAILS,
        itemphoto: auction.ITEMPHOTO,
        isclosed: (auction.ISCLOSED ? auction.ISCLOSED == 'T' : null),
        winnerid: auction.WINNERID
    }
}


module.exports = {dbConfig, query, parseUser, parseError, parseDate, parseSellerHistory, parseBuyerHistory, parseAuction, parseAuctionInfo};
