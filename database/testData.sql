DELETE FROM SellerReview;  -- clean database
DELETE FROM BuyerReview;
ALTER TABLE Auction DROP COLUMN bestBidId;
DELETE FROM Bid;
DELETE FROM Auction;
ALTER TABLE Auction ADD COLUMN bestBidId INT REFERENCES Bid;
DELETE FROM UserPhone;
DELETE FROM Users;

INSERT INTO AuctionParameter (improvementPercent, minIncrement, date) VALUES
(0.05, 5000, NOW());

INSERT INTO Users VALUES
(1, TRUE, 'admin1', crypt('admin1pw', gen_salt('bf')), 'arq@ic43.com', 'Anatolio', 'Ruvalcaba Quesada', 'San Ramon');

INSERT INTO UserPhone VALUES (1, '83462967');
