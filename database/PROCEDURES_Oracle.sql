execute createUser(201280645,'F','Pepe','12345678','example1@gmail.com','Pepe', 'Aguilar', 'Direccion');
set serveroutput on


CREATE or replace PROCEDURE createUser(
	pid          INT, 
	pisAdmin     char,
	pnickname    VARCHAR,
	ppassword    VARCHAR,
	pemail       VARCHAR,
	pfirstName   VARCHAR,
	plastName    VARCHAR,
	paddress     VARCHAR)
IS
countUser integer;
countNick integer;
countEmail integer; 
BEGIN
    SELECT count(*) into countUser FROM Users WHERE id = pId;
    SELECT count(*) into countNick FROM Users WHERE nickname = pNickname;
    SELECT count(*) into countEmail FROM Users WHERE email = pEmail;
    IF (pId = NULL OR pIsAdmin IS NULL OR pNickname IS NULL OR 
		pPassword IS NULL OR pEmail IS NULL  OR 
		pFirstName = '' OR pLastName = '' or paddress = '') 
        THEN 
		RAISE_APPLICATION_ERROR(-20000,'Error: Null parameter, only phone numbers are optional.');
	ELSIF countUser > 0  
        THEN
        RAISE_APPLICATION_ERROR(-20001,'Error: User already exists.');
        
	ELSIF (LENGTH(pPassword) < 8) THEN
		RAISE value_error;
        RAISE_APPLICATION_ERROR(-20002,'Error: The password must be at least 8 digits.');
        
	ELSIF countNick > 0  THEN
        RAISE_APPLICATION_ERROR(-20003,'Error: Nickname not available, please try another.');
        
	ELSIF countEmail > 0 THEN
        --RAISE 'Error: Email already registered.';
        RAISE_APPLICATION_ERROR(-20004,'Error: Email already registered.');
        
	ELSE 
		BEGIN
			INSERT INTO Users VALUES
			(pId, pIsAdmin, pNickname,cryptf(pPassword), pEmail, pFirstName, pLastName, paddress);
			COMMIT;
		END;
	END IF;
END;

--Proccedure 2

CREATE or replace PROCEDURE updateUser(
	pId         INTEGER, 
	pIsAdmin     char,
	pNickname    VARCHAR,
	pPassword    VARCHAR,
	pEmail       VARCHAR,
	pFirstName   VARCHAR,
	pLastName    VARCHAR,
	pPhoneNumber VARCHAR,
	pHomeNumber  VARCHAR
)
IS
countUser INTEGER;
countNick integer;
countEmail integer;
auxIsadmin char(1);
BEGIN
   
    SELECT isAdmin into auxIsadmin FROM Users WHERE id = pId;
    SELECT count(*) into countUser FROM Users WHERE id = pId;
    SELECT count(*) into countNick FROM  Users  WHERE nickname = pNickname AND id != pId;
    SELECT count(*) into countEmail FROM Users WHERE email = pEmail AND id != pId;

    IF (pId IS NULL OR pIsAdmin IS NULL OR pNickname is null OR 
		pPassword is null OR pEmail is null  OR 
		pFirstName is null OR pLastName is null) THEN
		RAISE_APPLICATION_ERROR(-20005,'Error: Null parameter, only phone numbers are optional.');
        
	ELSIF countUser < 1 THEN
		RAISE_APPLICATION_ERROR(-20006,'Error: User not exists.');
        
	ELSIF (LENGTH(pPassword) < 8) THEN
        RAISE_APPLICATION_ERROR(-20007,'Error: Password have to at least 8 characters.');
        
	ELSIF countNick > 0  THEN
        RAISE_APPLICATION_ERROR(-20008,'Error: Nickname not available, please try another.');
	
	ELSIF countEmail > 0 THEN
        RAISE_APPLICATION_ERROR(-20009,'Error: Email already in use, please try another.');
	
	ELSIF auxIsAdmin != pIsAdmin THEN
	    RAISE_APPLICATION_ERROR(-20010,'Error: Admins can''t be updated to participants, or vice versa.');
	
	ELSE
		BEGIN
			UPDATE Users
			SET nickname = pNickname,
				password = cryptf(pPassword),
				email = pEmail,
				firstName = pFirstName,
				lastName = pLastName,
				phoneNumber = pPhoneNumber,
				homeNumber = pHomeNumber
			WHERE id = pId;
			COMMIT;
		END;
	END IF;
END;


--Proccedure 3


CREATE OR REPLACE PROCEDURE createAdmin(
	pId          INTEGER,
	pNickname    VARCHAR,
	pPassword    VARCHAR,
	pEmail       VARCHAR,
	pFirstName   VARCHAR,
	pLastName    VARCHAR,
	pPhoneNumber VARCHAR,
	pHomeNumber  VARCHAR
)
IS
BEGIN
	 createUser(pId, 'T', pNickname, pPassword, pEmail, pFirstName, pLastName, pPhoneNumber, pHomeNumber);
END;




--Proccedure 5


CREATE or replace PROCEDURE updateAdmin(
	pId          INTEGER,
	pNickname    VARCHAR,
	pPassword    VARCHAR,
	pEmail       VARCHAR,
	pFirstName   VARCHAR,
	pLastName    VARCHAR,
	pPhoneNumber VARCHAR,
	pHomeNumber  VARCHAR
)
IS
BEGIN
    updateUser(pId, 'T', pNickname, pPassword, pEmail, pFirstName, pLastName, pPhoneNumber, pHomeNumber);
END;




CREATE or replace PROCEDURE createParticipant(
	pId          INTEGER,
	pNickname    VARCHAR,
	pPassword    VARCHAR,
	pEmail       VARCHAR,
	pFirstName   VARCHAR,
	pLastName    VARCHAR,
	pPhoneNumber VARCHAR,
	pHomeNumber  VARCHAR
)
IS
BEGIN
	 createUser(pId, 'F', pNickname, pPassword, pEmail, pFirstName, pLastName, pPhoneNumber, pHomeNumber);
END;




CREATE PROCEDURE updateParticipant(
	pId          INTEGER,
	pNickname    VARCHAR,
	pPassword    VARCHAR,
	pEmail       VARCHAR,
	pFirstName   VARCHAR,
	pLastName    VARCHAR,
	pPhoneNumber VARCHAR,
	pHomeNumber  VARCHAR
)
IS
BEGIN
	 updateUser(pId, 'F', pNickname, pPassword, pEmail, pFirstName, pLastName, pPhoneNumber, pHomeNumber);
END;


CREATE or replace PROCEDURE createAuction(
	pItemName        VARCHAR,
	pSubCategoryId   INT,
	pUserId          INT,
	pBasePrice       NUMERIC,
	pEndDate         TIMESTAMP,
	pItemDescription VARCHAR,
	pDeliveryDetails VARCHAR,
	pItemPhoto       blob
)
IS
countUser INTEGER;
countSubC integer;
auxIsadmin char(1);
BEGIN
   SELECT count(*) into countSubC FROM SubCategory WHERE id = pSubCategoryId;
    SELECT isAdmin into auxIsadmin FROM Users WHERE id = pUserId;
    SELECT count(*) into countUser FROM Users WHERE id = pUserId;
    IF (pItemName is null OR pSubCategoryId IS NULL OR 
		pUserId IS NULL OR pBasePrice IS NULL OR pEndDate IS NULL 
		OR pItemDescription is null OR 
		pDeliveryDetails is null) 
        THEN
			RAISE_APPLICATION_ERROR(-20011,'Error: Null parameter, only item photo is optional.');
	
	ELSIF countSubC < 1 THEN
        RAISE_APPLICATION_ERROR(-20012,'Error: Subcategory doesn''t exists.');

	ELSIF countUser < 0  THEN
        RAISE_APPLICATION_ERROR(-20013,'Error: User doesn''t exists.');
	
	ELSIF auxIsadmin = 'T' THEN
        RAISE_APPLICATION_ERROR(-20014,'Error: Admin users can''t create auctions.');
	
	ELSIF (pBasePrice <= 0) THEN        
        RAISE_APPLICATION_ERROR(-20015,'Error: Base price has to be higher than 0.');
	
	ELSIF (pEndDate <= CURRENT_TIMESTAMP) THEN
        RAISE_APPLICATION_ERROR(-20016,'Error: Finishing date has to be higher than current date.');
	
	ELSIF pItemPhoto IS NOT NULL AND LENGTH(pItemPhoto) > 25600 THEN    
        RAISE_APPLICATION_ERROR(-20018,'Error: Item photo can''t exceed 25KB.');
	
	
	ELSE
		BEGIN
			INSERT INTO Auction (itemName, subCategoryId, userId, bestBidId, basePrice, startDate, endDate, itemDescription, deliveryDetails, itemPhoto, isClosed, itemWasSold) VALUES
			(pItemName, pSubCategoryId, pUserId, NULL, pBasePrice, CURRENT_TIMESTAMP, pEndDate, pItemDescription, pDeliveryDetails, pItemPhoto, 'F', NULL);
			COMMIT;
		END;
	END IF;
END;




CREATE or replace PROCEDURE createBid(
	pUserId    INTEGER,
	pAmount    numeric,
	pAuctionId INTEGER
)
IS
countUser integer;
countAuction integer;
dateAux TIMESTAMP;
BEGIN 
    
    SELECT endDate into dateAux  FROM Auction WHERE id = pAuctionId;
    SELECT count(*) into countUser FROM Users WHERE id = pUserId;
    SELECT count(*) into countAuction FROM Auction WHERE id = pAuctionId;
	
    IF (pUserId IS NULL OR pAmount IS NULL OR pAuctionId IS NULL) THEN
		RAISE_APPLICATION_ERROR(-20019,'Error: Null parameter, all required.');
		
	ELSIF countUser < 1 THEN
		RAISE_APPLICATION_ERROR(-20020,'Error: User doesn''t exists.');
	
	ELSIF countAuction < 1 THEN
		RAISE_APPLICATION_ERROR(-20021,'Error: Auction doesn''t exists.');
	
	ELSIF ( dateAux >= CURRENT_TIMESTAMP) THEN
		RAISE_APPLICATION_ERROR(-20022,'Error: Auction ended.');
	
	ELSIF (pAmount < getMinBid(pAuctionId)) THEN
		--RAISE 'Error: Insufficient bid, minimum: ?%.', getMinBid(_auctionId);
		RAISE_APPLICATION_ERROR(-20023,'Error: Insufficient bid');
	
	ELSE 
		BEGIN
			INSERT INTO Bid (auctionId, userId, amount, dateT) VALUES (pAuctionId, pUserId, pAmount, CURRENT_TIMESTAMP);
			COMMIT;
		END;
	END IF;
END;




CREATE OR REPLACE PROCEDURE createAuctionParameter(
	pImprovementPercent Numeric,
	pMinIncrement       Numeric
)
IS

countImprovement numeric;
countMinIncrement numeric;
BEGIN 
    select * into countImprovement from (Select improvementPercent from AuctionParameter where rownum < (select count(*) from AuctionParameter )+1 order by rownum desc) where rownum <=1;
    select * into countMinIncrement from (SELECT minIncrement FROM AuctionParameter where rownum < (select count(*) from AuctionParameter )+1 order by rownum desc) where rownum <=1;

    IF (pImprovementPercent IS NULL OR pMinIncrement IS NULL) THEN
		RAISE_APPLICATION_ERROR(-20024,'Error: Null parameter, all required.');
	
	ELSIF (pImprovementPercent <= 0 OR pMinIncrement <= 0) THEN
        RAISE_APPLICATION_ERROR(-20024,'Error: Parameters have to be greater than 0.');
	
	ELSIF (countImprovement = pImprovementPercent AND
		  countMinIncrement = pMinIncrement) THEN
        RAISE_APPLICATION_ERROR(-20024,'Error: Auction parameters identical to current ones.');

	ELSE 
		BEGIN
			INSERT INTO AuctionParameter (improvementPercent, minIncrement, dateT) VALUES
			(pImprovementPercent, pMinIncrement, CURRENT_TIMESTAMP);
			COMMIT;
		END;
	END IF;
END;




CREATE OR REPLACE PROCEDURE updateSellerReview(
	pAuctionId INTEGER,
	pComment   VARCHAR,
	pRating    smallint)
IS
countSeller integer;
BEGIN
    SELECT count(*) into countSeller FROM SellerReview WHERE auctionId = pAuctionId;
    
	IF (pAuctionId IS NULL) THEN
        RAISE_APPLICATION_ERROR(-20025,'Error: Null auction id.');
        
	ELSIF countSeller < 1 THEN
        RAISE_APPLICATION_ERROR(-20026,'Error: Can''t leave review, auction still open.');
		
	ELSIF (pRating IS NOT NULL AND pRating < 0 OR pRating > 5) THEN
        RAISE_APPLICATION_ERROR(-20027,'Error: Rating must be between 0 and 5.');
		
		
	ELSE 
		BEGIN
			UPDATE SellerReview
		   	SET commentt = pComment,
		   		rating = pRating
		   	WHERE auctionId = pAuctionId;
			COMMIT;
		END;
	END IF;
END;




CREATE OR REPLACE PROCEDURE updateBuyerReview(
	pAuctionId   INTEGER,
	pComment     VARCHAR,
	pRating      smallInt,
	pItemWasSold CHAR
)
IS
countBuyer integer;
BEGIN
    SELECT count(*) into countBuyer FROM BuyerReview WHERE auctionId = pAuctionId;

    IF (pAuctionId IS NULL OR pItemWasSold IS NULL) THEN
        RAISE_APPLICATION_ERROR(-20028,'Error: Null auction id or indication if item was sold.');
		
	ELSIF countBuyer < 1 THEN
		RAISE_APPLICATION_ERROR(-20029,'Error: Can''t leave review, auction still open.');
		
	ELSIF pRating IS NOT NULL AND (pRating < 0 OR pRating > 5) THEN
		RAISE_APPLICATION_ERROR(-20030,'Error: Rating must be between 0 and 5.');
		
	ELSE 
		BEGIN
			UPDATE BuyerReview
		   	SET commentt = pComment,
		   		rating = pRating
		   	WHERE auctionId = pAuctionId;
			COMMIT;
			
			UPDATE Auction
			SET itemWasSold = pItemWasSold
			WHERE id = pAuctionId;
			COMMIT;
		END;
	END IF;
END;




CREATE or replace PROCEDURE updateClosedAuctions()
is

	auctionRow RECORD;
BEGIN
	FOR auctionRow IN SELECT * FROM Auction  -- implicit cursor
	LOOP
    end loop;
end;		IF auctionRow.isClosed = FALSE AND
			auctionRow.endDate <= current_TIMESTAMP THEN
			BEGIN
				UPDATE Auction
				SET isClosed = TRUE
				WHERE id = auctionRow.id;
				COMMIT;
				
				IF auctionRow.bestBidId IS NOT NULL THEN
					BEGIN
						INSERT INTO SellerReview (auctionId, dateT) VALUES
						(auctionRow.id, CURRENT_TIMESATMP);
						COMMIT;
				
						INSERT INTO BuyerReview (auctionId, dateT) VALUES
						(auctionRow.id, CURRENT_TIMESATMP);
						COMMIT;
					END;
				END IF;
			END;
		END IF;
	END LOOP;
END;

SELECT updateClosedAuctions();

SELECT id, itemName, endDate, isClosed FROM Auction WHERE id = 5;
SELECT * FROM SellerReview; SELECT * FROM BuyerReview;

UPDATE Auction SET isClosed = FALSE WHERE id = 5;
DELETE FROM SellerReview WHERE auctionId = 5;
DELETE FROM BuyerReview WHERE auctionId = 5;



