CREATE DATABASE auctionweb;

CREATE TABLE AuctionParameter (
	id                 SERIAL PRIMARY KEY,
	improvementPercent NUMERIC(14, 2) NOT NULL,
	minIncrement       NUMERIC(14, 2) NOT NULL,
	date               TIMESTAMP NOT NULL
);

CREATE TABLE Category (
	id   SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);

CREATE TABLE SubCategory (
	id         SERIAL PRIMARY KEY,
	categoryId INT REFERENCES Category NOT NULL,
	name       VARCHAR(100) NOT NULL
);

CREATE TABLE Users (  -- pluralized since a table can't be named User 
	id          BIGINT PRIMARY KEY,
	isAdmin     BOOL NOT NULL,
	nickname    VARCHAR(20) NOT NULL,
	password    VARCHAR(60) NOT NULL,  -- encrypted via pgcrypto
	email       VARCHAR(320) NOT NULL,
	firstName   VARCHAR(50) NOT NULL,
	lastName    VARCHAR(50) NOT NULL,
	phoneNumber VARCHAR(8),
	homeNumber  VARCHAR(8)
);

CREATE TABLE Bid (
	id        SERIAL PRIMARY KEY,
	userId    INT REFERENCES Users NOT NULL,
	amount    NUMERIC(14, 2) NOT NULL,
	date      TIMESTAMP NOT NULL
);

CREATE TABLE Auction (
	id              SERIAL PRIMARY KEY,
	itemName        VARCHAR(60) NOT NULL,
	subCategoryId   INT REFERENCES SubCategory NOT NULL,
	userId          INT REFERENCES Users NOT NULL,
	bestBidId       INT REFERENCES Bid,
	basePrice       NUMERIC(14, 2) NOT NULL,
	startDate       TIMESTAMP NOT NULL,
	endDate         TIMESTAMP NOT NULL,
	itemDescription VARCHAR(120) NOT NULL,
	deliveryDetails VARCHAR(120) NOT NULL,
	itemPhoto       BYTEA,  -- image as byte array
	isClosed        BOOL NOT NULL,
	itemWasSold     BOOL
);
ALTER TABLE Bid ADD COLUMN auctionId INT REFERENCES Auction NOT NULL;  -- add missing Bid column

CREATE TABLE SellerReview (
	auctionId INT PRIMARY KEY REFERENCES Auction,
	comment   VARCHAR(120),
	rating    SMALLINT,
	date      TIMESTAMP NOT NULL
);

CREATE TABLE BuyerReview (
	auctionId INT PRIMARY KEY REFERENCES Auction,
	comment   VARCHAR(120),
	rating    SMALLINT,
	date      TIMESTAMP NOT NULL
);
