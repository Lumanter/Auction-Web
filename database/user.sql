REVOKE ALL ON DATABASE auctionweb FROM PUBLIC;  -- revoke PUBLIC default privileges on auctionweb databse

CREATE USER auctionwebapp WITH PASSWORD 'auctionwebapp';  -- create basic users
GRANT CONNECT ON DATABASE auctionweb TO auctionwebapp;  -- grant to connect
GRANT SELECT, INSERT, UPDATE ON 
	Auction, 
	Bid, 
	BuyerReview, 
	SellerReview, 
	Category, 
	SubCategory, 
	Users 
	TO auctionwebapp; -- grant crud (minus delete) on all tables
