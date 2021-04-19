CREATE USER c##auctionweb IDENTIFIED BY auctionweb;  -- database admin user, where tables and functions/procedures are stored
GRANT ALL PRIVILEGES TO c##auctionweb;

CREATE USER c##auctionwebapp IDENTIFIED BY auctionwebapp;  -- app connection user
GRANT CREATE SESSION TO c##auctionwebapp;

GRANT EXECUTE ON c##auctionweb.getActiveAuctions TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.getActiveCategories TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.getActiveSubCategories TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.getAuctionBids TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.getAuctionInfo TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.getAuctionParameters TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.getBuyerHistory TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.getSellerHistory TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.getLoginUser TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.getSubcategories TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.getUser TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.getUserPhones TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.getUsers TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.createAuction TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.createAuctionParameter TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.createBid TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.createUser TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.createUserPhone TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.updateUser TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.updateBuyerReview TO c##auctionwebapp;
GRANT EXECUTE ON c##auctionweb.updateSellerReview TO c##auctionwebapp;
