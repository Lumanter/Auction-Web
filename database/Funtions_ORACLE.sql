--////////////////////////////crypt funtions
create or replace function cryptf( p_str in varchar2 ) return varchar2
  as
      l_data  varchar2(255);
  begin
     l_data := rpad( p_str, (trunc(length(p_str)/8)+1)*8, chr(0) );
  
      dbms_obfuscation_toolkit.DESEncrypt
          ( input_string => l_data,
            key_string   => 'DBAKey03',
           encrypted_string=> l_data );
 
      return l_data;
  end;


create or replace
  function decryptf( p_str in varchar2 ) return varchar2
  as
      l_data  varchar2(255);
  begin
      dbms_obfuscation_toolkit.DESDecrypt
          ( input_string => p_str,
            key_string   => 'DBAKey03',
            decrypted_string=> l_data );
  
      return rtrim( l_data, chr(0) );
  end;


--//////////////////////////////////////////getMinBid
CREATE OR REPLACE FUNCTION getMinBid(pAuctionId NUMERIC) 
RETURN numeric
Is 
	pImprovementPercent  NUMERIC(14, 2);
	pMinIncrement        NUMERIC(14, 2);
	pBasePrice          NUMERIC(14, 2);
	pBestBidAmount      NUMERIC(14, 2);
    countAuction int;
    auxBid int;
BEGIN
	
    select * into pImprovementPercent from (Select improvementPercent 
    from AuctionParameter where rownum < (select count(*) from AuctionParameter )+1 order by rownum desc) where rownum <=1;
    select * into pMinIncrement from (SELECT minIncrement
    FROM AuctionParameter where rownum < (select count(*) from AuctionParameter )+1 order by rownum desc) where rownum <=1;
    
	SELECT count(*) into countAuction FROM Auction WHERE id = pAuctionId;
      
    
      SELECT bestBidId into auxBid FROM Auction WHERE id = pAuctionId;
      
	IF (countAuction < 1) THEN
		RETURN 0;
		
	ELSE
		BEGIN
			SELECT basePrice 
			INTO pBasePrice 
			FROM Auction WHERE id = pAuctionId;
		
			IF (auxBid IS NULL) THEN
				RETURN pBasePrice + pMinIncrement;
			
			ELSE
				SELECT amount 
				INTO pBestBidAmount
				FROM Bid B
				JOIN Auction A  
				ON A.id = 1 AND B.id = A.bestBidId;
				
				RETURN ROUND(pBestBidAmount + (pBestBidAmount * (pImprovementPercent / 100.0)));
			END IF;
		END;
	END IF;
END;


--/////////////////////////////////////////////////////getActiveAuctions ready

CREATE TYPE TABLE_ActiveAuctionsRES_OBJ AS OBJECT (
    id              INT,
	itemName        VARCHAR(60),
	subCategoryId    INT,
	userId          INT ,
	bestBidId       INT,
	basePrice        NUMERIC(12,2),
	startDate       TIMESTAMP,
	endDate         TIMESTAMP,
	itemDescription VARCHAR(120) ,
	deliveryDetails VARCHAR(120) ,
	itemPhoto       blob,  -- image as byte array
	isClosed         CHAR(1) ,    --/ 'T' from true  /'F' from false,
	itemWasSold      CHAR(1) 
    );

--Create a type of your object 
CREATE TYPE TABLE_ActiveAuctionsRES AS TABLE OF TABLE_ActiveAuctionsRES_OBJ;

--Function Use the type created as Return Type
CREATE OR REPLACE FUNCTION getActiveAuctions (  pCategoryId    INT,
                                                pSubCategoryId INT )
RETURN TABLE_ActiveAuctionsRES
PIPELINED
AS
    CURSOR CURSEUR_ETAPE
    IS
    SELECT 
            A.id,
            A.itemName,
            A.subCategoryId,
            A.userId ,
            A.bestBidId,
            A.basePrice,
            A.startDate,
            A.endDate,
            A.itemDescription ,
            A.deliveryDetails ,
            A.itemPhoto ,  -- image as byte array
            A.isClosed ,    --/ 'T' from true  /'F' from false,
            A.itemWasSold
	FROM Auction A
	JOIN SubCategory S
	ON A.subCategoryId = S.id AND
		A.endDate > CURRENT_TIMESTAMP AND 
		A.isClosed = 'F' AND 
		A.subCategoryId = COALESCE(pSubCategoryId, A.subCategoryId) AND
		S.categoryId = COALESCE(pCategoryId, S.categoryId)
		ORDER BY endDate ASC;
BEGIN
    FOR i IN CURSEUR_ETAPE
    LOOP
      PIPE ROW (TABLE_ActiveAuctionsRES_OBJ (   i.id,
                                                i.itemName,
                                                i.subCategoryId,
                                                i.userId  ,
                                                i.bestBidId,
                                                i.basePrice,
                                                i.startDate,
                                                i.endDate  ,
                                                i.itemDescription ,
                                                i.deliveryDetails ,
                                                i.itemPhoto,  -- image as byte array
                                                i.isClosed,    --/ 'T' from true  /'F' from false,
                                                i.itemWasSold));
      EXIT WHEN CURSEUR_ETAPE%NOTFOUND;
   END LOOP;
   RETURN;
END;

--/////////////////////////////////////////////////////////////////////////////////////////
---////////////////////////////////////////---///////////////////////////////////////////////////////////////GetSellerHistory ready  
-- Create Object of your table
CREATE  TYPE TABLE_SellerHistoryRES_OBJ AS OBJECT (
     auctionId     INT,
	itemName      VARCHAR(60),
	basePrice     NUMERIC(14, 2),
	startDate     TIMESTAMP,
	buyerUserId   INT,
	buyerNickname VARCHAR(20),
	amount        NUMERIC(14, 2),
	isClosed      char(1),
	itemWasSold   char(1),
	buyerComment  VARCHAR(120),
	buyerRating   SMALLINT 
);

--Create a type of your object 
CREATE TYPE TABLE_SellerHistoryRES AS TABLE OF TABLE_SellerHistoryRES_OBJ;


--Function Use the type created as Return Type
CREATE OR REPLACE FUNCTION getSellerHistory ( pUserId INT )
RETURN TABLE_SellerHistoryRES
PIPELINED
AS
    CURSOR CURSEUR_ETAPE
    IS
        SELECT A.id auctionId,itemName, basePrice, startDate, U.id buyerUserId, 
		   nickname buyerNickname, amount, isClosed, itemWasSold, commentt buyerComment, 
		   rating buyerRating
    
            FROM Auction A
            LEFT JOIN SellerReview R
                ON R.auctionId = A.id 
            LEFT JOIN Bid B
                ON B.id = A.bestBidId
            LEFT JOIN Users U
                ON U.id = B.userId
            WHERE A.userId = pUserId
            ORDER BY A.startDate DESC;
BEGIN
    FOR i IN CURSEUR_ETAPE
    LOOP
      PIPE ROW (TABLE_SellerHistoryRES_OBJ (i.auctionId ,
                                            i.itemName      ,
                                            i.basePrice     ,
                                            i.startDate     ,
                                            i.buyerUserId   ,
                                            i.buyerNickname ,
                                            i.amount        ,
                                            i.isClosed      ,
                                            i.itemWasSold   ,
                                            i.buyerComment  ,
                                        	i.buyerRating));
      EXIT WHEN CURSEUR_ETAPE%NOTFOUND;
   END LOOP;
   RETURN;
END;
--///////////////////////////////////////Do not touch


--//////////////////////////////////////////getBuyerHistory

-- Create Object of your table
CREATE TYPE TABLE_BuyerHistoryRES_OBJ AS OBJECT (
     auctionId     INT,
	itemName      VARCHAR(60),
	basePrice      Numeric(14,2),
	amount        numeric(14,2),
	bidDate       TIMESTAMP,
	sellerComment  VARCHAR(120),
	sellerRating   SMALLINT
);

--Create a type of your object 
CREATE TYPE TABLE_BuyerHistoryRES AS TABLE OF TABLE_BuyerHistoryRES_OBJ;



--Function Use the type created as Return Type
CREATE OR REPLACE FUNCTION getBuyerHistory ( pUserId INT )
RETURN TABLE_BuyerHistoryRES
PIPELINED
AS
    CURSOR CURSEUR_ETAPE
    IS
            SELECT A.id auctionId, A.itemName, A.basePrice, B.amount, 
            B.datet bidDate , R.commentt sellerComment, R.rating sellerRating
            FROM Bid B
            JOIN Auction A
            ON B.auctionId = A.id AND
            B.userId = pUserId
            LEFT JOIN BuyerReview R
            ON R.auctionId = A.id AND
            A.bestBidId = B.id
            ORDER BY B.dateT DESC;
BEGIN
    FOR i IN CURSEUR_ETAPE
    LOOP
      PIPE ROW (TABLE_BuyerHistoryRES_OBJ (i.auctionId,
                                            i.itemName,
                                            i.basePrice,
                                            i.amount,
                                            i.bidDate,
                                            i.sellerComment,
                                            i.sellerRating));
      EXIT WHEN CURSEUR_ETAPE%NOTFOUND;
   END LOOP;
   RETURN;
END;

--///////////////////////////////////////Do not touch


--/////////////////////////////////////////////////getAuctionBids

-- Create Object of your table
CREATE TYPE TABLE_AuctionBidsRES_OBJ AS OBJECT (
    userId    INT,
	nickname  VARCHAR(20),
	amount    NUMERIC(14, 2),
	dateT      TIMESTAMP
);

--Create a type of your object 
CREATE TYPE TABLE_AuctionBidsRES AS TABLE OF TABLE_AuctionBidsRES_OBJ;

--Function Use the type created as Return Type
CREATE OR REPLACE FUNCTION getAuctionBids ( pAuctionId INT )
RETURN TABLE_AuctionBidsRES
PIPELINED
AS
    CURSOR CURSEUR_ETAPE
    IS
            SELECT B.userId, U.nickname, B.amount, B.dateT
            FROM Bid B
            JOIN Users U
                ON B.userId = U.id
                    AND auctionId = pAuctionId
            ORDER BY dateT DESC;
BEGIN
    FOR i IN CURSEUR_ETAPE
    LOOP
      PIPE ROW (TABLE_AuctionBidsRES_OBJ (  i.userId,
                                            i.nickname,
                                            i.amount,
                                            i.dateT ));
      EXIT WHEN CURSEUR_ETAPE%NOTFOUND;
   END LOOP;
   RETURN;
END;

--/////////////////////////////////////////////////////////don't touch

--////////////////////////////////////////////////////////getActiveSubCategories

-- Create Object of your table
CREATE TYPE TABLE_ActiveSubCategoriesRES_OBJ AS OBJECT (
    id         INT,
	categoryId INT,
	name       VARCHAR(250)
);

--Create a type of your object 
CREATE TYPE TABLE_ActiveSubCategoriesRES AS TABLE OF TABLE_ActiveSubCategoriesRES_OBJ;

--Function Use the type created as Return Type
CREATE OR REPLACE FUNCTION getActiveSubCategories 
RETURN TABLE_ActiveSubCategoriesRES
PIPELINED
AS
    CURSOR CURSEUR_ETAPE
    IS
            
        SELECT S.id, S.categoryId, C.name|| ' - '|| S.name name
        FROM Subcategory S
        JOIN Category C
            ON S.categoryId = C.id
        JOIN Auction A
            ON A.subCategoryId = S.id
                AND A.isClosed = 'F'
        GROUP BY S.id, S.categoryId, S.name, C.name
        ORDER BY C.name, S.name;
BEGIN
    FOR i IN CURSEUR_ETAPE
    LOOP
      PIPE ROW (TABLE_ActiveSubCategoriesRES_OBJ (  i.id ,
                                                    i.categoryId ,
                                                    i.name));
      EXIT WHEN CURSEUR_ETAPE%NOTFOUND;
   END LOOP;
   RETURN;
END;
--////////////////////////////////////////////////////Don't touch

--///////////////////////////////////////////////////Getsubcategories


-- Create Object of your table
CREATE TYPE TABLE_SubCategoriesRES_OBJ AS OBJECT (
    id         INT,
	categoryId INT,
	name       VARCHAR(250)
);

--Create a type of your object 
CREATE TYPE TABLE_SubCategoriesRES AS TABLE OF TABLE_SubCategoriesRES_OBJ;

--Function Use the type created as Return Type
CREATE OR REPLACE FUNCTION getSubCategories 
RETURN TABLE_SubCategoriesRES
PIPELINED
AS
    CURSOR CURSEUR_ETAPE
    IS
        
        SELECT S.id, S.categoryId, C.name|| ' - '|| S.name  name
        FROM Subcategory S
        JOIN Category C
            ON S.categoryId = C.id
        ORDER BY C.name, S.name;

BEGIN
    FOR i IN CURSEUR_ETAPE
    LOOP
      PIPE ROW (TABLE_SubCategoriesRES_OBJ (  i.id,
                                                    i.categoryId ,
                                                    i.name));
      EXIT WHEN CURSEUR_ETAPE%NOTFOUND;
   END LOOP;
   RETURN;
END;

--//////////////////////////////////////////////////////////////////////

--////////////////////////////////////////////////////////////////////getAuctionInfo READY

-- Create Object of your table
CREATE OR REPLACE TYPE TABLE_AuctionInfoRES_OBJ AS OBJECT (
  auctionId       INT,
	itemName        VARCHAR(60),
	subcategoryName VARCHAR(100),
	sellerId        INT,
	sellerNickname  VARCHAR(50),
	basePrice       NUMERIC(14, 2),
	currentPrice    NUMERIC(14, 2),
	minBid          NUMERIC(14, 2),
	startDate       TIMESTAMP,
	endDate         TIMESTAMP,
	itemDescription VARCHAR(120),
	deliveryDetails VARCHAR(120),
	itemPhoto       blob,
	isClosed        CHAR(1),
	winnerId        INT
);
  
--Create a type of your object 
CREATE TYPE TABLE_AuctionInfoRES AS TABLE OF TABLE_AuctionInfoRES_OBJ;
DROP TYPE TABLE_AuctionInfoRES

CREATE OR REPLACE FUNCTION getAuctionInfo(pId INT)
RETURN TABLE_AuctionInfoRES
PIPELINED

AS
    countAuction int;
    CURSOR CURSEUR_ETAPE
    
    IS         
		SELECT A.id auctionId, A.itemName , S.name subcategoryName, A.userId sellerId, U.nickname sellerNickname,
			   A.basePrice, COALESCE(B.amount, A.basePrice) currentPrice, 
			   getMinBid(A.id) minBid, A.startDate, A.endDate, 
			   A.itemDescription, A.deliveryDetails, A.itemPhoto, 
			   A.isClosed, B.userId winnerId
		FROM Auction A
		JOIN SubCategory S
			ON A.subCategoryId = S.id AND A.id = 1
		JOIN Users U
			ON U.id = A.userId
		LEFT JOIN Bid B
			ON A.bestBidId = B.id;
BEGIN
    select count(*) into countAuction FROM Auction WHERE id = pId;
    IF countAuction < 1 THEN
        RAISE_APPLICATION_ERROR(-20059,'Error: Auction doesn''t exists.');
		
	ELSE
        FOR i IN CURSEUR_ETAPE
        LOOP
          PIPE ROW (TABLE_AuctionInfoRES_OBJ (  i.auctionId,
                                                i.itemName,
                                                i.subcategoryName,
                                                i.sellerId,
                                                i.sellerNickname ,
                                                i.basePrice   ,
                                                i.currentPrice,
                                                i.minBid ,
                                                i.startDate,
                                                i.endDate  ,
                                                i.itemDescription,
                                                i.deliveryDetails,
                                                i.itemPhoto,
                                                i.isClosed ,
                                                i.winnerId ));
          EXIT WHEN CURSEUR_ETAPE%NOTFOUND;
       END LOOP;
   END IF;
   RETURN;
END;

--/////////////////////////////////////////////////////////////////////


-----/////////////////////////////////////////////////////////getLoginUser READY


-- Create Object of your tabledrop type TABLE_LoginUserRES_OBJ force
CREATE OR REPLACE TYPE TABLE_LoginUserRES_OBJ AS OBJECT (
    id          INT,
	isAdmin     char(1) ,   --'T' if is true, 'F' if is false
	nickname    VARCHAR(20) ,
	password    VARCHAR(60) ,  -- encrypted via pgcrypto
	email       VARCHAR(320),
	firstName   VARCHAR(50) ,
	lastName    VARCHAR(50) ,
	address     VARCHAR(120)
);
  
--Create a type of your object 
CREATE TYPE TABLE_LoginUserRES AS TABLE OF TABLE_LoginUserRES_OBJ;


CREATE OR REPLACE FUNCTION getLoginUser(
                                            pNickname    VARCHAR,
                                            pPassword    VARCHAR)
RETURN TABLE_LoginUserRES
PIPELINED
AS
    countUser int;
    encryptedPassword VARCHAR(60);
    CURSOR CURSEUR_ETAPE
    
    IS
        
		SELECT  U.id,
                U.isAdmin ,    --/ 'T' from true  /'F' from false
                U.nickname ,
                U.password,  
                U.email ,
                U.firstName,
                U.lastName,
                U.address  FROM Users U WHERE nickname = pNickname;
                    
                
                
BEGIN
    select password into encryptedPassword from users where nickname = pNickname and cryptf(pPassword) = password;
    SELECT COUNT(*) INTO countUser FROM Users WHERE nickname = pNickname;
    IF countUser > 0 then            
        IF cryptf(pPassword) = encryptedPassword THEN
            FOR i IN CURSEUR_ETAPE
            LOOP
              PIPE ROW (TABLE_LoginUserRES_OBJ (    i.id,
                                                    i.isAdmin ,    --/ 'T' from true  /'F' from false
                                                    i.nickname ,
                                                    i.password,  
                                                    i.email ,
                                                    i.firstName,
                                                    i.lastName,
                                                    i.address ));
              EXIT WHEN CURSEUR_ETAPE%NOTFOUND;
           END LOOP;
        ELSE
            RAISE_APPLICATION_ERROR(-20060,'Error: Incorrect password');    
        END IF;
   ELSE
        RAISE_APPLICATION_ERROR(-20060,'Error: User Nickname doesn''t exists.');
   END IF;
   RETURN;
END;

--///////////////////////////////////////////////////////////////


--///////////////////////////////////////////////////////////////////////getAuctionParameters READY


-- Create Object of your table
CREATE OR REPLACE TYPE TABLE_AuctionParametersRES_OBJ AS OBJECT (
    id      INT ,
    improvementPercent  numeric(14,2),
    minIncrement        numeric(14,2),
	dateT               TIMESTAMP 
);

--Create a type of your object 
CREATE TYPE TABLE_AuctionParametersRES AS TABLE OF TABLE_AuctionParametersRES_OBJ;

CREATE OR REPLACE FUNCTION getAuctionParameters
RETURN TABLE_AuctionParametersRES
PIPELINED
AS
    CURSOR CURSEUR_ETAPE
    
    IS
            
		SELECT  id,
                improvementPercent,
                minIncrement,
                dateT FROM (SELECT id,
                improvementPercent,
                minIncrement,
                dateT 
                FROM AuctionParameter 
                 ORDER BY datet DESC )  WHERE ROWNUM <=1;
BEGIN
            FOR i IN CURSEUR_ETAPE
            LOOP
              PIPE ROW (TABLE_AuctionParametersRES_OBJ (    i.id,
                                                    i.improvementPercent,
                                                    i.minIncrement,
                                                    i.dateT ));
              EXIT WHEN CURSEUR_ETAPE%NOTFOUND;
           END LOOP;
    
   RETURN;
END;


--////////////////////////////////////////////////////////////////



-----//////////////////////////////////////////////////////getUsers ready


-- Create Object of your table

CREATE TYPE TABLE_UsersRES_OBJ AS OBJECT (
    id          INT ,
	isAdmin     char(1) ,   --'T' if is true, 'F' if is false
	nickname    VARCHAR(20) ,
	password    VARCHAR(60) ,  -- encrypted via pgcrypto
	email       VARCHAR(320),
	firstName   VARCHAR(50) ,
	lastName    VARCHAR(50) ,
	address     VARCHAR(120)
);


--Create a type of your object 
CREATE TYPE TABLE_UsersRES AS TABLE OF TABLE_UsersRES_OBJ;


CREATE OR REPLACE FUNCTION getUsers
RETURN TABLE_UsersRES
PIPELINED
AS
    CURSOR CURSEUR_ETAPE
    
    IS
      SELECT 
            id,                   
            isAdmin  ,    --/ 'T' from true  /'F' from false
            nickname ,
            password ,  
            email    ,
            firstName,
            lastName    ,
            address
      FROM Users ORDER BY nickname;
BEGIN
            FOR i IN CURSEUR_ETAPE
            LOOP
              PIPE ROW (TABLE_UsersRES_OBJ ( 
                                                    i.id,                   
                                                    i.isAdmin  ,    --/ 'T' from true  /'F' from false
                                                    i.nickname ,
                                                    i.password ,  
                                                    i.email    ,
                                                    i.firstName,
                                                    i.lastName    ,
                                                    i.address ));
              EXIT WHEN CURSEUR_ETAPE%NOTFOUND;
           END LOOP;
    
   RETURN;
END;
--////////////////////////////////////////////////////////////////////////////////////

--///////////////////////////////////////////////////////////////////////get user ready


CREATE OR REPLACE FUNCTION getUser(pId INT)
RETURN TABLE_UsersRES
PIPELINED
AS
    countUser int;
    CURSOR CURSEUR_ETAPE
    
    IS
      SELECT 
            id,                   
            isAdmin  ,    --/ 'T' from true  /'F' from false
            nickname ,
            password ,  
            email    ,
            firstName,
            lastName    ,
            address
      FROM  Users WHERE id = pId;
BEGIN
        SELECT count(*) into countUser FROM Users WHERE id = pid;
        if countUser > 0 then
            FOR i IN CURSEUR_ETAPE
            LOOP
              PIPE ROW (TABLE_UsersRES_OBJ ( 
                                                    i.id,                   
                                                    i.isAdmin  ,    --/ 'T' from true  /'F' from false
                                                    i.nickname ,
                                                    i.password ,  
                                                    i.email    ,
                                                    i.firstName,
                                                    i.lastName    ,
                                                    i.address ));
              EXIT WHEN CURSEUR_ETAPE%NOTFOUND;
           END LOOP;
        else
            RAISE_APPLICATION_ERROR(-20060,'Error: User doesn''t exists.');
   
        end if;
   RETURN;
END;
--//////////////////////////////////////////////////////////////////

--//////////////////////////////////////////////////////////////getActiveCategories


-- Create Object of your table
CREATE TYPE TABLE_ActiveCategoriesRES_OBJ AS OBJECT (
    id   INT,
    name VARCHAR(50) 
);
  
--Create a type of your object 
CREATE TYPE TABLE_ActiveCategoriesRES AS TABLE OF TABLE_ActiveCategoriesRES_OBJ;


CREATE OR REPLACE FUNCTION getActiveCategories
RETURN TABLE_ActiveCategoriesRES
PIPELINED
AS
    CURSOR CURSEUR_ETAPE
    
    IS
      SELECT  C.id, C.name
        FROM Category C
        JOIN SubCategory S
            ON C.id = S.categoryId
        JOIN Auction A
            ON A.subCategoryId = S.id 
                AND A.isClosed = 'F'
        GROUP BY C.id, C.name
        ORDER BY C.name;
BEGIN
            FOR i IN CURSEUR_ETAPE
            LOOP
              PIPE ROW (TABLE_ActiveCategoriesRES_OBJ ( 
                                                    i.id,                   
                                                    i.name 
                                                     ));
              EXIT WHEN CURSEUR_ETAPE%NOTFOUND;
           END LOOP;
    
   RETURN;
END;


--/////////////////////////////////////////////////////////////////
--/////////////////////////////////////////////////////////////////get userPhones


CREATE or replace FUNCTION getUserPhones(pUserId INT)
RETURN String is 
phones String(500):='';
begin
    for i in (Select userId, phone from UserPhone)
    loop
    if i.userId = pUserId then
        phones := phones || i.phone ||', ';
    end if;
    end loop;
    return phones ;
end;
