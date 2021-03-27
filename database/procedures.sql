CREATE PROCEDURE createUser(
	_id          BIGINT, 
	_isAdmin     BOOL,
	_nickname    VARCHAR(20),
	_password    VARCHAR(15),
	_email       VARCHAR(320),
	_firstName   VARCHAR(50),
	_lastName    VARCHAR(50),
	_phoneNumber VARCHAR(8),
	_homeNumber  VARCHAR(8))
LANGUAGE PLPGSQL AS $$
BEGIN
    IF ((_id IS NULL) OR (_isAdmin IS NULL) OR (COALESCE(TRIM(_nickname),'') = '') OR 
		(COALESCE(TRIM(_password),'') = '') OR (COALESCE(TRIM(_email),'') = '')  OR 
		(COALESCE(TRIM(_firstName),'') = '') OR (COALESCE(TRIM(_lastName),'') = '')) THEN
		RAISE 'Error: Null parameter, only phone numbers are optional.';
		
	ELSIF EXISTS(SELECT * FROM Users WHERE id = _id) THEN
		RAISE 'Error: User already exists.';
		
	ELSIF (LENGTH(_password) < 8) THEN
		RAISE 'Error: Password have to at least 8 characters.';
	
	ELSIF EXISTS(SELECT * FROM Users WHERE nickname = _nickname) THEN
		RAISE 'Error: Nickname not available, please try another.';
	
	ELSIF EXISTS(SELECT * FROM Users WHERE email = _email) THEN
		RAISE 'Error: Email already registered.';

	ELSE
		BEGIN
			INSERT INTO Users VALUES
			(_id, _isAdmin, _nickname, crypt(_password, gen_salt('bf')), _email, _firstName, _lastName, _phoneNumber, _homeNumber);
			COMMIT;
		END;
	END IF;
END;$$




CREATE PROCEDURE updateUser(
	_id          BIGINT, 
	_isAdmin     BOOL,
	_nickname    VARCHAR(20),
	_password    VARCHAR(15),
	_email       VARCHAR(320),
	_firstName   VARCHAR(50),
	_lastName    VARCHAR(50),
	_phoneNumber VARCHAR(8),
	_homeNumber  VARCHAR(8))
LANGUAGE PLPGSQL AS $$
BEGIN
    IF ((_id IS NULL) OR (_isAdmin IS NULL) OR (COALESCE(TRIM(_nickname),'') = '') OR 
		(COALESCE(TRIM(_password),'') = '') OR (COALESCE(TRIM(_email),'') = '')  OR 
		(COALESCE(TRIM(_firstName),'') = '') OR (COALESCE(TRIM(_lastName),'') = '')) THEN
		RAISE 'Error: Null parameter, only phone numbers are optional.';
		
	ELSIF NOT EXISTS(SELECT * FROM Users WHERE id = _id) THEN
		RAISE 'Error: User not exists.';
		
	ELSIF (LENGTH(_password) < 8) THEN
		RAISE 'Error: Password have to at least 8 characters.';
	
	ELSIF EXISTS(SELECT * FROM Users WHERE nickname = _nickname AND id != _id) THEN
		RAISE 'Error: Nickname not available, please try another.';
	
	ELSIF EXISTS(SELECT * FROM Users WHERE email = _email AND id != _id) THEN
		RAISE 'Error: Email already in use, please try another.';

	ELSIF ((SELECT isAdmin FROM Users WHERE id = _id) != _isAdmin) THEN
		RAISE 'Error: Admins can''t be updated to participants, or vice versa.';
	
	ELSE
		BEGIN
			UPDATE Users
			SET nickname = _nickname,
				password = crypt(_password, gen_salt('bf')),
				email = _email,
				firstName = _firstName,
				lastName = _lastName,
				phoneNumber = _phoneNumber,
				homeNumber = _homeNumber
			WHERE id = _id;
			COMMIT;
		END;
	END IF;
END;$$




CREATE PROCEDURE createAdmin(
	_id          BIGINT,
	_nickname    VARCHAR(20),
	_password    VARCHAR(15),
	_email       VARCHAR(320),
	_firstName   VARCHAR(50),
	_lastName    VARCHAR(50),
	_phoneNumber VARCHAR(8),
	_homeNumber  VARCHAR(8))
LANGUAGE PLPGSQL AS $$
BEGIN
	CALL createUser(_id, TRUE, _nickname, _password, _email, _firstName, _lastName, _phoneNumber, _homeNumber);
END;$$




CREATE PROCEDURE updateAdmin(
	_id          BIGINT,
	_nickname    VARCHAR(20),
	_password    VARCHAR(15),
	_email       VARCHAR(320),
	_firstName   VARCHAR(50),
	_lastName    VARCHAR(50),
	_phoneNumber VARCHAR(8),
	_homeNumber  VARCHAR(8))
LANGUAGE PLPGSQL AS $$
BEGIN
	CALL updateUser(_id, TRUE, _nickname, _password, _email, _firstName, _lastName, _phoneNumber, _homeNumber);
END;$$




CREATE PROCEDURE createParticipant(
	_id          BIGINT,
	_nickname    VARCHAR(20),
	_password    VARCHAR(15),
	_email       VARCHAR(320),
	_firstName   VARCHAR(50),
	_lastName    VARCHAR(50),
	_phoneNumber VARCHAR(8),
	_homeNumber  VARCHAR(8))
LANGUAGE PLPGSQL AS $$
BEGIN
	CALL createUser(_id, FALSE, _nickname, _password, _email, _firstName, _lastName, _phoneNumber, _homeNumber);
END;$$




CREATE PROCEDURE updateParticipant(
	_id          BIGINT,
	_nickname    VARCHAR(20),
	_password    VARCHAR(15),
	_email       VARCHAR(320),
	_firstName   VARCHAR(50),
	_lastName    VARCHAR(50),
	_phoneNumber VARCHAR(8),
	_homeNumber  VARCHAR(8))
LANGUAGE PLPGSQL AS $$
BEGIN
	CALL updateUser(_id, FALSE, _nickname, _password, _email, _firstName, _lastName, _phoneNumber, _homeNumber);
END;$$




CREATE PROCEDURE createAuction(
	_itemName        VARCHAR(60),
	_subCategoryId   INT,
	_userId          INT,
	_basePrice       NUMERIC(14, 2),
	_endDate         TIMESTAMP,
	_itemDescription VARCHAR(120),
	_deliveryDetails VARCHAR(120),
	_itemPhoto       BYTEA)
LANGUAGE PLPGSQL AS $$
BEGIN
	IF ((COALESCE(TRIM(_itemName),'') = '') OR (_subCategoryId IS NULL) OR 
		(_userId IS NULL) OR (_basePrice IS NULL) OR (_endDate IS NULL) 
		OR (COALESCE(TRIM(_itemDescription),'') = '') OR 
		(COALESCE(TRIM(_deliveryDetails),'') = '')) THEN
			RAISE 'Error: Null parameter, only item photo is optional.';
			
	ELSIF NOT EXISTS(SELECT * FROM SubCategory WHERE id = _subCategoryId) THEN
		RAISE 'Error: Subcategory doesn''t exists.';
	
	ELSIF NOT EXISTS(SELECT * FROM Users WHERE id = _userId) THEN
		RAISE 'Error: User doesn''t exists.';
	
	ELSIF ((SELECT isAdmin FROM Users WHERE id = _userId) = TRUE) THEN
		RAISE 'Error: Admin users can''t create auctions.';
	
	ELSIF (_basePrice <= 0) THEN
		RAISE 'Error: Base price has to be higher than 0.';
	
	ELSIF (_endDate <= NOW()) THEN
		RAISE 'Error: Finishing date has to be higher than current date.';
	
	ELSIF NOT EXISTS(SELECT * FROM Users WHERE id = _userId) THEN
		RAISE 'Error: User doesn''t exists.';
	
	ELSIF (_itemPhoto IS NOT NULL AND LENGTH(_itemPhoto) > 25600) THEN
		RAISE 'Error: Item photo can''t exceed 25KB.';
	
	ELSE
		BEGIN
			INSERT INTO Auction (itemName, subCategoryId, userId, bestBidId, basePrice, startDate, endDate, itemDescription, deliveryDetails, itemPhoto, isClosed, itemWasSold) VALUES
			(_itemName, _subCategoryId, _userId, NULL, _basePrice, NOW(), _endDate, _itemDescription, _deliveryDetails, _itemPhoto, FALSE, NULL);
			COMMIT;
		END;
	END IF;
END;$$




CREATE PROCEDURE createBid(
	_userId    INT,
	_amount    NUMERIC(14, 2),
	_auctionId INT)
LANGUAGE PLPGSQL AS $$
BEGIN
	IF ((_userId IS NULL) OR (_amount IS NULL) OR (_auctionId IS NULL)) THEN
			RAISE 'Error: Null parameter, all required.';
			
	ELSIF NOT EXISTS(SELECT * FROM Users WHERE id = _userId) THEN
		RAISE 'Error: User doesn''t exists.';
	
	ELSIF NOT EXISTS(SELECT * FROM Auction WHERE id = _auctionId) THEN
		RAISE 'Error: Auction doesn''t exists.';
	
	ELSIF ((SELECT endDate FROM Auction WHERE id = _auctionId) >= NOW()) THEN
		RAISE 'Error: Auction ended.';
	
	ELSIF (_amount < getMinBid(_auctionId)) THEN
		RAISE 'Error: Insufficient bid, minimum: ₡%.', getMinBid(_auctionId);
		
	ELSE 
		BEGIN
			INSERT INTO Bid (auctionId, userId, amount, date) VALUES
			(_auctionId, _userId, _amount, NOW());
			COMMIT;
		END;
	END IF;
END;$$




CREATE PROCEDURE createAuctionParameter(
	_improvementPercent NUMERIC(14, 2),
	_minIncrement       NUMERIC(14, 2))
LANGUAGE PLPGSQL AS $$
BEGIN
	IF ((_improvementPercent IS NULL) OR (_minIncrement IS NULL)) THEN
		RAISE 'Error: Null parameter, all required.';
	
	ELSIF ((_improvementPercent <= 0) OR (_minIncrement <= 0)) THEN
		RAISE 'Error: Parameters have to be greater than 0.';
	
	ELSIF (((SELECT improvementPercent FROM AuctionParameter ORDER BY date DESC LIMIT 1) = _improvementPercent) AND
		  ((SELECT minIncrement FROM AuctionParameter ORDER BY date DESC LIMIT 1) = _minIncrement)) THEN
		RAISE 'Error: Auction parameters identical to current ones.';
	
	ELSE 
		BEGIN
			INSERT INTO AuctionParameter (improvementPercent, minIncrement, date) VALUES
			(_improvementPercent, _minIncrement, NOW());
			COMMIT;
		END;
	END IF;
END;$$




CREATE PROCEDURE updateSellerReview(
	_auctionId INT,
	_comment   VARCHAR(120),
	_rating    SMALLINT)
LANGUAGE PLPGSQL AS $$
BEGIN
	IF (_auctionId IS NULL) THEN
		RAISE 'Error: Null auction id.';
	
	ELSIF NOT EXISTS(SELECT * FROM SellerReview WHERE auctionId = _auctionId) THEN
		RAISE 'Error: Can''t leave review, auction still open.';
		
	ELSIF ((_rating IS NOT NULL) AND ((_rating < 0) OR (_rating > 5))) THEN
		RAISE 'Error: Rating must be between 0 and 5.';
		
	ELSE 
		BEGIN
			UPDATE SellerReview
		   	SET comment = _comment,
		   		rating = _rating
		   	WHERE auctionId = _auctionId;
			COMMIT;
		END;
	END IF;
END;$$




CREATE PROCEDURE updateBuyerReview(
	_auctionId   INT,
	_comment     VARCHAR(120),
	_rating      SMALLINT,
	_itemWasSold BOOL)
LANGUAGE PLPGSQL AS $$
BEGIN
	IF ((_auctionId IS NULL) OR (_itemWasSold IS NULL)) THEN
		RAISE 'Error: Null auction id or indication if item was sold.';
	
	ELSIF NOT EXISTS(SELECT * FROM BuyerReview WHERE auctionId = _auctionId) THEN
		RAISE 'Error: Can''t leave review, auction still open.';
		
	ELSIF ((_rating IS NOT NULL) AND ((_rating < 0) OR (_rating > 5))) THEN
		RAISE 'Error: Rating must be between 0 and 5.';
		
	ELSE 
		BEGIN
			UPDATE BuyerReview
		   	SET comment = _comment,
		   		rating = _rating
		   	WHERE auctionId = _auctionId;
			COMMIT;
			
			UPDATE Auction
			SET itemWasSold = _itemWasSold
			WHERE id = _auctionId;
			COMMIT;
		END;
	END IF;
END;$$




CREATE PROCEDURE updateClosedAuctions()
LANGUAGE PLPGSQL AS $$
DECLARE
	auctionRow RECORD;
BEGIN
	FOR auctionRow IN SELECT * FROM Auction  -- implicit cursor
	LOOP
		IF ((auctionRow.isClosed = FALSE) AND
			(auctionRow.endDate <= NOW())) THEN
			BEGIN
				UPDATE Auction
				SET isClosed = TRUE
				WHERE id = auctionRow.id;
				COMMIT;
				
				IF (auctionRow.bestBidId IS NOT NULL) THEN
					BEGIN
						IF NOT EXISTS(SELECT * FROM SellerReview WHERE auctionId = auctionRow.id) THEN
							INSERT INTO SellerReview (auctionId, date) VALUES
							(auctionRow.id, NOW());
							COMMIT;
						END IF;
						
						IF NOT EXISTS(SELECT * FROM BuyerReview WHERE auctionId = auctionRow.id) THEN
							INSERT INTO BuyerReview (auctionId, date) VALUES
							(auctionRow.id, NOW());
							COMMIT;
						END IF;
					END;
				END IF;
			END;
		END IF;
	END LOOP;
END;$$

CALL updateClosedAuctions();

SELECT id, itemName, endDate, isClosed, bestBidId FROM Auction WHERE id = 5;
SELECT * FROM SellerReview; SELECT * FROM BuyerReview;

UPDATE Auction SET isClosed = FALSE WHERE id = 5;
DELETE FROM SellerReview WHERE auctionId = 5;
DELETE FROM BuyerReview WHERE auctionId = 5;
