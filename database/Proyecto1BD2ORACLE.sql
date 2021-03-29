alter session set "_ORACLE_SCRIPT"=true;
Create user usuario identified BY "12345";

DROP TABLE AuctionParameter;
--Table AuctionParameter
CREATE TABLE AuctionParameter (
    id      INTEGER PRIMARY KEY NOT NULL,
    improvementPercent  INTEGER NOT NULL,
    minIncrement        INTEGER NOT NULL,
	dateT               TIMESTAMP NOT NULL  
);
 
--Sequence that generates the autoincremented id's for table AuctionParameter
CREATE SEQUENCE AuctionParameter_sequence;

--Trigger that is responsible for assigning the new id for table AuctionParameter
CREATE OR REPLACE TRIGGER AuctionParameter_on_insert
  BEFORE INSERT ON AuctionParameter
  FOR EACH ROW
BEGIN
  SELECT AuctionParameter_sequence.nextval
  INTO :new.id
  FROM dual;
END;

--Create table category
CREATE TABLE Category (
    id   INTEGER  PRIMARY KEY NOT NULL,
    name VARCHAR(50) NOT NULL
);


--Sequence that generates the autoincremented id's for table Category
CREATE SEQUENCE Category_sequence;

--Trigger that is responsible for assigning the new id for table Category
CREATE OR REPLACE TRIGGER Category_on_insert
  BEFORE INSERT ON Category
  FOR EACH ROW
BEGIN
  SELECT Category_sequence.nextval
  INTO :new.id
  FROM dual;
END;


--Create table for sub category
CREATE TABLE SubCategory (
    id      INTEGER PRIMARY KEY  NOT NULL,
    categoryId  INTEGER REFERENCES Category NOT NULL,
    name        VARCHAR(50) NOT NULL
    
);

--Sequence that generates the autoincremented id's for table SubCategory
CREATE SEQUENCE SubCategory_sequence;

--Trigger that is responsible for assigning the new id for table SubCategory
CREATE OR REPLACE TRIGGER SubCategory_on_insert
  BEFORE INSERT ON SubCategory
  FOR EACH ROW
BEGIN
  SELECT SubCategory_sequence.nextval
  INTO :new.id
  FROM dual;
END;

--Craete tabke Users
CREATE TABLE Users (  -- pluralized since a table can't be named User 
	id        INTEGER PRIMARY KEY NOT NULL,
	isAdmin     CHAR(1) NOT NULL,    --/ 'T' from true  /'F' from false
	nickname    VARCHAR(20) NOT NULL,
	password    VARCHAR(60) NOT NULL,  
	email       VARCHAR(320) NOT NULL,
	firstName   VARCHAR(50) NOT NULL,
	lastName    VARCHAR(50) NOT NULL,
	phoneNumber VARCHAR(8),
	homeNumber  VARCHAR(8)
);

--Sequence that generates the autoincremented id's for table Users
CREATE SEQUENCE Users_sequence;

--Trigger that is responsible for assigning the new id for table SubCategory
CREATE OR REPLACE TRIGGER Users_on_insert
  BEFORE INSERT ON Users
  FOR EACH ROW
BEGIN
  SELECT Users_sequence.nextval
  INTO :new.id
  FROM dual;
END;

--Create table bid
CREATE TABLE Bid (
	id        INTEGER PRIMARY KEY NOT NULL,
	userId    INTEGER REFERENCES Users NOT NULL,
	amount    INTEGER NOT NULL,
	dateT      TIMESTAMP NOT NULL
    
);

--Sequence that generates the autoincremented id's for table Bid
CREATE SEQUENCE Bid_sequence;

--Trigger that is responsible for assigning the new id for table SubCategory
CREATE OR REPLACE TRIGGER Bid_on_insert
  BEFORE INSERT ON Bid
  FOR EACH ROW
BEGIN
  SELECT Bid_sequence.nextval
  INTO :new.id
  FROM dual;
END;

drop table Auction;
--Create table Auction
CREATE TABLE Auction (
	id              INTEGER PRIMARY KEY NOT NULL,
	itemName        VARCHAR(60) NOT NULL,
	subCategoryId    INTEGER REFERENCES SubCategory NOT NULL,
	userId          INTEGER REFERENCES Users NOT NULL,
	bestBidId       INTEGER REFERENCES Bid,
	basePrice        INTEGER NOT NULL,
	startDate       TIMESTAMP NOT NULL,
	endDate         TIMESTAMP NOT NULL,
	itemDescription VARCHAR(120) NOT NULL,
	deliveryDetails VARCHAR(120) NOT NULL,
	itemPhoto       blob,  -- image as byte array
	isClosed         CHAR(1) NOT NULL,    --/ 'T' from true  /'F' from false,
	itemWasSold      CHAR(1)    --/ 'T' from true  /'F' from false
);

--Sequence that generates the autoincremented id's for table Auction
CREATE SEQUENCE Auction_sequence;

--Trigger that is responsible for assigning the new id for table Auction
CREATE OR REPLACE TRIGGER Auction_on_insert
  BEFORE INSERT ON Auction
  FOR EACH ROW
BEGIN
  SELECT Auction_sequence.nextval
  INTO :new.id
  FROM dual;
END;

--add auctionId to table Bid
ALTER TABLE Bid ADD auctionId INTEGER REFERENCES Auction NOT NULL;

--Create table SellerReview
CREATE TABLE SellerReview (
	auctionId INTEGER PRIMARY KEY REFERENCES Auction,
	commentt   VARCHAR(120),
	rating    SMALLINT,
	dateT      TIMESTAMP NOT NULL
);

--Create table Buyer Review
CREATE TABLE BuyerReview (
	auctionId INTEGER PRIMARY KEY REFERENCES Auction,
	commentt   VARCHAR(120),
	rating    SMALLINT,
	dateT      TIMESTAMP NOT NULL
);

















CREATE TABLE pwd_table (id integer primary key, pwd blob);
drop table pwd_table;