CREATE FUNCTION getMinBid(_auctionId INT) 
RETURNS NUMERIC(14, 2) AS $$
DECLARE 
	_improvementPercent NUMERIC(14, 2);
	_minIncrement       NUMERIC(14, 2);
	_basePrice          NUMERIC(14, 2);
	_bestBidAmount      NUMERIC(14, 2);
BEGIN
	SELECT improvementPercent, minIncrement 
	INTO _improvementPercent, _minIncrement 
	FROM AuctionParameter ORDER BY date DESC LIMIT 1;
	
	IF NOT EXISTS(SELECT * FROM Auction WHERE id = _auctionId) THEN
		RETURN 0;
		
	ELSE
		BEGIN
			SELECT basePrice 
			INTO _basePrice 
			FROM Auction WHERE id = _auctionId;
		
			IF ((SELECT bestBidId FROM Auction WHERE id = _auctionId) IS NULL) THEN
				RETURN _basePrice + _minIncrement;
			
			ELSE
				SELECT amount 
				INTO _bestBidAmount
				FROM Bid B
				JOIN Auction A  
				ON A.id = 1 AND B.id = A.bestBidId;
				
				RETURN _bestBidAmount + (_bestBidAmount * _improvementPercent);
			END IF;
		END;
	END IF;
END;
$$ LANGUAGE PLPGSQL;




CREATE FUNCTION getActiveAuctions(
	_categoryId    INT,
	_subCategoryId INT) 
RETURNS SETOF Auction AS $$
	SELECT A.*
	FROM Auction A
	JOIN SubCategory S
	ON A.subCategoryId = S.id AND
		A.endDate > NOW() AND 
		A.isClosed = FALSE AND 
		A.subCategoryId = COALESCE(_subCategoryId, A.subCategoryId) AND
		S.categoryId = COALESCE(_categoryId, S.categoryId)
		ORDER BY endDate DESC;
$$ LANGUAGE SQL;




CREATE FUNCTION getAuctionBids(
	_auctionId    INT) 
RETURNS SETOF Bid AS $$
	SELECT *
	FROM Bid
	WHERE auctionId = _auctionId
	ORDER BY date DESC;
$$ LANGUAGE SQL;




CREATE FUNCTION getSellerHistory(
	_userId INT) 
RETURNS TABLE (
	auctionId     INT,
	itemName      VARCHAR(60),
	basePrice     NUMERIC(14, 2),
	startDate     TIMESTAMP,
	buyerUserId   INT,
	buyerNickname VARCHAR(20),
	amount        NUMERIC(14, 2),
	winDate       TIMESTAMP,
	buyerComment  VARCHAR(120),
	buyerRating   SMALLINT
) AS $$
	SELECT A.id, itemName, basePrice, startDate, U.id, 
		   nickname, amount, R.date, comment, rating
	FROM Auction A
	LEFT JOIN SellerReview R
		ON R.auctionId = A.id 
	LEFT JOIN Bid B
		ON B.id = A.bestBidId
	LEFT JOIN Users U
		ON U.id = B.userId
	WHERE A.userId = _userId
	ORDER BY startDate DESC;
$$ LANGUAGE SQL;




CREATE FUNCTION getBuyerHistory(
	_userId INT) 
RETURNS TABLE (
	auctionId     INT,
	itemName      VARCHAR(60),
	basePrice     NUMERIC(14, 2),
	amount        NUMERIC(14, 2),
	bidDate       TIMESTAMP,
	sellerComment VARCHAR(120),
	sellerRating  SMALLINT
) AS $$
	SELECT A.id, itemName, basePrice, amount, 
		   B.date, comment, rating
	FROM Bid B
	JOIN Auction A
		ON B.auctionId = A.id AND
		   B.userId = _userId
	LEFT JOIN BuyerReview R
		ON R.auctionId = A.id AND
		   A.bestBidId = B.id
	ORDER BY B.date DESC;
$$ LANGUAGE SQL;




CREATE FUNCTION getLoginUser(
	_nickname    VARCHAR(20),
	_password    VARCHAR(15)) 
RETURNS SETOF Users AS $$
DECLARE
	encryptedPassword VARCHAR(60);
BEGIN
	IF NOT EXISTS(SELECT * FROM Users WHERE nickname = _nickname) THEN
		RAISE 'Error: User % doesn''t exists.', _nickname;
	ELSE
		BEGIN
			SELECT password 
			INTO encryptedPassword
			FROM Users WHERE nickname = _nickname;
			
			IF (crypt(_password, encryptedPassword) = encryptedPassword) THEN
				RETURN QUERY SELECT * FROM Users WHERE nickname = _nickname;
			ELSE
				RAISE 'Error: Incorrect password for user %.', _nickname;
			END IF;
		END;
	END IF;
END;
$$ LANGUAGE PLPGSQL;




CREATE FUNCTION getAuctionParameters() 
RETURNS SETOF AuctionParameter AS $$
	SELECT * 
	FROM AuctionParameter 
	ORDER BY date DESC 
	LIMIT 1;
$$ LANGUAGE SQL;




CREATE FUNCTION getUsers() 
RETURNS SETOF Users AS $$
	SELECT * FROM Users ORDER BY nickname;
$$ LANGUAGE SQL;




CREATE FUNCTION getUser(_id INT) 
RETURNS SETOF Users AS $$
BEGIN
	IF NOT EXISTS(SELECT * FROM Users WHERE id = _id) THEN
		RAISE 'Error: User with id % doesn''t exists.', _id;
	ELSE 
		RETURN QUERY SELECT * FROM Users WHERE id = _id;
	END IF;
END;
$$ LANGUAGE PLPGSQL;




CREATE FUNCTION getSubCategories() 
RETURNS SETOF SubCategory AS $$
	SELECT * FROM SubCategory ORDER BY name;
$$ LANGUAGE SQL;




CREATE  FUNCTION getActiveAuctions() 
RETURNS SETOF Auction AS $$
	SELECT * FROM Auction WHERE NOW() < endDate ORDER BY endDate ASC;
$$ LANGUAGE SQL;




CREATE FUNCTION getAuction(_id INT) 
RETURNS SETOF Auction AS $$
	SELECT * FROM Auction WHERE id = _id;
$$ LANGUAGE SQL;
