CREATE or replace TRIGGER updateBestBidTrigger
BEFORE INSERT ON Bid
FOR EACH ROW
BEGIN

	UPDATE Auction A
	SET bestBidId = :new.id
	WHERE A.id = :new.auctionId;
	
END;

