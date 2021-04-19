--Trigger that updates the best BID when a new one is inserted
CREATE or replace TRIGGER updateBestBidTrigger
after INSERT ON Bid
FOR EACH ROW
BEGIN

	UPDATE Auction A
	SET bestBidId = :new.id
	WHERE A.id = :new.auctionId;
	
END;

