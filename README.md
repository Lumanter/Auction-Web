# Auction-Web
Auction website built with Node, Express and EJS. Built with heavy focus on stored functions/procedures and roles. Two database versions implemented: PostgreSQL and Oracle.
<br/>
<html><img src="https://github.com/marianosegura/Auction-Web/blob/main/database_diagram.png" width="900" height="954"></html>

<br/>

**Roles**: admins and users.  

**Admins Features**
- create/edit users
- configure global auction parameters

**Users Features** (Seller/Buyers)
- create/bid/close auctions
- review as seller/buyer

<br/>

List of **Stored Functions**:  

- getMinBid
- getActiveAuctions
- getAuctionBids
- getSellerHistory
- getBuyerHistory
- getLoginUser
- getAuctionParameters
- getUsers
- getUser
- getActiveCategories
- getActiveSubCategories
- getSubCategories
- getAuctionInfo
- getUserPhones


List of **Stored Procedures**:  

- createUser
- updateUser
- createAuction
- createBid
- createAuctionParameter
- updateSellerReview
- updateBuyerReview
- updateClosedAuctions
- createUserPhone
