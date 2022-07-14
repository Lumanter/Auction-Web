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
	Users,
	UserPhone
	TO auctionwebapp; -- grant crud (minus delete) on all tables
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO auctionwebapp;  -- sequences are used in auto incremental id's like auction
