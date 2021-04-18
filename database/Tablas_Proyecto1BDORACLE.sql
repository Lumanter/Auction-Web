alter session set "_ORACLE_SCRIPT"=true;
Create user usuario identified BY "12345";

--Table AuctionParameter
CREATE TABLE AuctionParameter (
    id      INT GENERATED ALWAYS AS IDENTITY primary key,
    improvementPercent  numeric(14,2) NOT NULL,
    minIncrement        numeric(14,2) NOT NULL,
	dateT               TIMESTAMP NOT NULL  
);


--Create table category
CREATE TABLE Category (
    id   INT GENERATED ALWAYS AS IDENTITY primary key,
    name VARCHAR(50) NOT NULL
);

--Create table for sub category
CREATE TABLE SubCategory (
    id      INT GENERATED ALWAYS AS IDENTITY primary key,
    categoryId  INT REFERENCES Category NOT NULL,
    name        VARCHAR(100) NOT NULL
    
);


--Create table Users
CREATE TABLE Users (  -- pluralized since a table can't be named User 
	id          INT PRIMARY KEY,
	isAdmin     char(1) NOT NULL,   --'T' if is true, 'F' if is false
	nickname    VARCHAR(20) NOT NULL,
	password    VARCHAR(60) NOT NULL,  -- encrypted via pgcrypto
	email       VARCHAR(320) NOT NULL,
	firstName   VARCHAR(50) NOT NULL,
	lastName    VARCHAR(50) NOT NULL,
	address     VARCHAR(120)
);

--Create table userphone
CREATE TABLE UserPhone ( 
	userId INT NOT NULL REFERENCES Users,
	phone  VARCHAR(8) NOT NULL,
	PRIMARY KEY(userId, phone)
);

--Create table bid
CREATE TABLE Bid (
	id        INT GENERATED ALWAYS AS IDENTITY primary key,
	userId    INTEGER REFERENCES Users NOT NULL,
	amount    numeric(14,2) NOT NULL,
	dateT      TIMESTAMP NOT NULL  
);


--Create table Auction
CREATE TABLE Auction (
	id              INT GENERATED ALWAYS AS IDENTITY primary key, 
	itemName        VARCHAR(60) NOT NULL,
	subCategoryId    INT REFERENCES SubCategory NOT NULL,
	userId          INT REFERENCES Users NOT NULL,
	bestBidId       int references bid, --reference to table bid
	basePrice        NUMERIC(14,2) NOT NULL,
	startDate       TIMESTAMP NOT NULL,
	endDate         TIMESTAMP NOT NULL,
	itemDescription VARCHAR(120) NOT NULL,
	deliveryDetails VARCHAR(120) NOT NULL,
	itemPhoto       blob,  -- image as byte array
	isClosed         CHAR(1) NOT NULL,    --/ 'T' from true  /'F' from false,
	itemWasSold      CHAR(1)    --/ 'T' from true  /'F' from false
);


--add auctionId to table Bid
ALTER TABLE Bid ADD auctionId INT REFERENCES Auction NOT NULL;

--Create table SellerReview
CREATE TABLE SellerReview (
	auctionId INT PRIMARY KEY REFERENCES Auction,
	commentt   VARCHAR(120),
	rating    SMALLINT,
	dateT      TIMESTAMP NOT NULL
);
--Create table Buyer Review
CREATE TABLE BuyerReview (
	auctionId INT PRIMARY KEY REFERENCES Auction,
	commentt   VARCHAR(120),
	rating    SMALLINT,
	dateT      TIMESTAMP NOT NULL
);

