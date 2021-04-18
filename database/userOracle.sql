alter session set "_ORACLE_SCRIPT"=true;
CREATE USER auctionWebapp IDENTIFIED BY auctionwebapp ;


GRANT CREATE SESSION TO auctionWebapp;

GRANT SELECT, INSERT, UPDATE ON Auction TO auctionwebapp; 
	GRANT SELECT, INSERT, UPDATE ON Bid TO auctionwebapp; 
	GRANT SELECT, INSERT, UPDATE ON BuyerReview TO auctionwebapp;
	GRANT SELECT, INSERT, UPDATE ON SellerReview TO auctionwebapp;
	GRANT SELECT, INSERT, UPDATE ON Category TO auctionwebapp;
	GRANT SELECT, INSERT, UPDATE ON SubCategory TO auctionwebapp;
	GRANT SELECT, INSERT, UPDATE ON Users TO auctionwebapp;
	GRANT SELECT, INSERT, UPDATE ON UserPhone TO auctionwebapp;
 -- grant crud (minus delete) on all tables
