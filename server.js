const express = require('express'),
    app = express(),
    session = require('express-session'),
    flash = require('express-flash'),
    passport = require('passport'),
    fileUpload = require('express-fileupload');

const {initializePassport} = require('./passportConfig');
const {query, parseUser, parseError, parseSellerHistory, parseBuyerHistory, parseAuction, parseAuctionInfo, parseDate} = require('./dbConfig');
const {checkIsLogged, checkIsNotLogged, checkIsAdmin, checkIsNotAdmin} = require('./middleware');

    
initializePassport(passport);  // use custom strategy
    

// MIDDLEWARES
app.set("view engine", "ejs");  // use ejs
app.use(express.urlencoded({extended: true}))  // middleware to receive form data in (req.body.param)

app.use(fileUpload());  // set middleware to upload item image

app.use(session({
    secret: 'secret',
    resave: false,  // don't resave session if info hasn't changed
    saveUninitialized: false  // 
}));

app.use(flash());  // enable req.flash method
    
app.use(passport.initialize());
app.use(passport.session());


app.use((req, res, next) => {  // pass ejs local variables on route getters or redirects
    res.locals.user = req.user;  // pass session user
    res.locals.error = req.flash("error");  // pass flash messages
    res.locals.success = req.flash("success");
    next();
});


// ROUTES
app.get('/', (req, res) => {
    res.redirect('/login');
});

app.get('/login', checkIsNotLogged, (req, res) => {
    res.render('login', {nickname: 'the_buyer'});
});


app.post('/login', passport.authenticate('local', {
    successRedirect: '/',
    failureRedirect: '/login',
    failureFlash: true  // pass messages from passportConfig to flash('error')
}));


app.get('/logout', checkIsLogged, (req, res) => {
    req.logOut();  // passport function
    req.flash("success", "You have logged out");
    res.redirect('/login');
});


app.get('/params', [checkIsLogged, checkIsAdmin], async (req, res) => {
    let currentParams = null;  // set current params if available
    try {
        const results = await query('SELECT * FROM getAuctionParameters()');
        if (results.length > 0) {
            currentParams = results[0];
        }
    } catch (error) {}
    res.render('params', {params: currentParams});
});


app.post('/params', async (req, res) => {
    const {improvementpercent, minincrement} = req.body;
    try {
    await query(`CALL createAuctionParameter(${improvementpercent}, ${minincrement})`);
        req.flash("success", "Auction parameters updated!");
        res.redirect('/auctions');
    } catch (error) {
        req.flash("error", parseError(error));
        res.render('params', {error: req.flash("error"), params: {IMPROVEMENTPERCENT: improvementpercent, MININCREMENT: minincrement}});
    }
});


app.get('/users', [checkIsLogged, checkIsAdmin], async (req, res) => {
    let users = [];
    try {
        users = await query('SELECT * FROM getUsers()');
        users = users.map((user) => parseUser(user));
    } catch (error) {
        res.send('An error ocurred retrieving the users');
    }
    res.render('users', {users: users});
});


app.get('/users/new', [checkIsLogged, checkIsAdmin], (req, res) => {
    res.render('users/new');
});


app.post('/users', async (req, res) => {
    const {nickname, email, password, firstName, lastName, address} = req.body;  // take form data
    const id = (isNaN(parseInt(req.body.id)) ? null : parseInt(req.body.id));
    const isAdmin = ((req.body.isAdmin !== undefined) ? 'T' : 'F');

    const procedureCall = `CALL createUser(:1, :2, :3, :4, :5, :6, :7, :8)`;
    const procedureParams = [id, isAdmin, nickname, password, email, firstName, lastName, address];
    
    try {
        await query(procedureCall, procedureParams);
        req.flash("success", `User ${nickname} created`);
        res.redirect(`/users/${id}`);
    } catch (error) {
        req.flash("error", parseError(error));
        res.render('users/new', {error: req.flash("error"), id, isAdmin: (isAdmin == 'T'), nickname, email, firstName, lastName, address});  // pass data to restore user form
    }
});


app.get('/users/:id', checkIsLogged, async (req, res) => {
    try {
        const userId = (isNaN(parseInt(req.params.id)) ? 'NULL' : parseInt(req.params.id));
        const shownUser = parseUser((await query(`SELECT * FROM getUser(${userId})`))[0]);

        let phones = (await query(`SELECT getUserPhones(${userId}) FROM DUAL`))[0];
        phones = phones[Object.keys(phones)[0]]; 

        let buyerHistory = await query(`SELECT * FROM getBuyerHistory(${userId})`);
        buyerHistory = buyerHistory.map((item) => parseBuyerHistory(item));

        let sellerHistory = await query(`SELECT * FROM getSellerHistory(${userId})`);
        sellerHistory = sellerHistory.map((item) => parseSellerHistory(item));
        
        res.render('users/show', {shownUser, phones, buyerHistory, sellerHistory});
    } catch (error) {
        req.flash("error", parseError(error));
        res.redirect('/users');
    }
});


app.get('/users/:id/edit', [checkIsLogged, checkIsAdmin], async (req, res) => {
    try {
        const userId = req.params.id;
        const editUser = parseUser((await query(`SELECT * FROM getUser(${userId})`))[0]);
        res.render('users/edit', {...editUser});
    } catch (error) {
        req.flash("error", parseError(error));
        res.redirect('/users');
    }
});


app.post('/users/:id/phone', [checkIsLogged, checkIsAdmin], async (req, res) => {
    const {phone} = req.body;
    const id = req.params.id;

    try {
        await query(`CALL createUserPhone(${id}, '${phone}')`);
        req.flash("success", `Phone added`);
        res.redirect(`/users/${id}`);
    } catch (error) {
        req.flash("error", parseError(message));
        res.redirect(`/users/${id}/edit`)
    }   
});


app.post('/users/:id', [checkIsLogged, checkIsAdmin], async (req, res) => {
    const {nickname, email, password, firstName, lastName, address} = req.body;
    const id = req.params.id;

    const procedureCall = `CALL updateUser(:1, :2, :3, :4, :5, :6, :7)`;
    const procedureParams = [id, nickname, password, email, firstName, lastName, address];

    try {
        await query(procedureCall, procedureParams);
        req.flash("success", `User ${nickname} updated`);
        res.redirect(`/users/${id}`);
    } catch (error) {
        req.flash("error", parseError(error));
        res.redirect(`/users/${id}/edit`)
    }
});


app.get('/auctions', checkIsLogged, async (req, res) => {
    let auctions = [],
        categories = [],
        subcategories = [];
    try {
        auctions = await query('SELECT * FROM getActiveAuctions(NULL, NULL)');
        auctions = auctions.map((auction) => parseAuction(auction));

        categories = await query('SELECT * FROM getActiveCategories()');
        categories = categories.map((category) => {
            return { id: category.ID, name: category.NAME }
        });

        subcategories = await query('SELECT * FROM getActiveSubCategories()');
        subcategories = subcategories.map((subcategory) => {
            return { id: subcategory.ID, categoryid: subcategory.CATEGORYID, name: subcategory.NAME }
        });
    } catch (error) {}
    res.render('auctions', {auctions, categories, subcategories});
});


app.post('/auctions', async (req, res) => {
    const filterByCategory = (req.body.filterBy === 'category');
    const categoryId = (filterByCategory) ? req.body.category : 'NULL';
    const subCategoryId = (!filterByCategory) ? req.body.subcategory : 'NULL';

    let auctions = [],
        categories = [],
        subcategories = [];
    try {
        categories = await query('SELECT * FROM getActiveCategories()');
        categories = categories.map((category) => {
            return { id: category.ID, name: category.NAME }
        });

        subcategories = await query('SELECT * FROM getActiveSubCategories()');
        subcategories = subcategories.map((subcategory) => {
            return { id: subcategory.ID, categoryid: subcategory.CATEGORYID, name: subcategory.NAME }
        });

        auctions = await query(`SELECT * FROM getActiveAuctions(${categoryId}, ${subCategoryId})`);
        auctions = auctions.map((auction) => parseAuction(auction));
    } catch (error) {
        console.log(parseError(error));
    }
    res.render('auctions', {auctions, categories, subcategories});
});


app.get('/auctions/new', [checkIsLogged, checkIsNotAdmin], async (req, res) => {
    let subcategories = {};
    try {
        subcategories = await query('SELECT * FROM getSubCategories()');
        subcategories = subcategories.map((i) => {
            return {
                id: i.ID,
                categoryid: i.CATEGORYID,
                name: i.NAME
            }
        });
    } catch (error) {}

    res.render('auctions/new', {subcategories});
});


app.post('/auctions/new', async (req, res) => {
    const {itemName, subCategoryId, basePrice, itemDescription, deliveryDetails} = req.body;
    const endDate = req.body.endDate.replace('T', ' ');
    const userId = req.user.id;
    let itemPhoto = null;
    if (req.files) {
        itemPhoto = req.files.itemPhoto.data;  // image as blob object
    }

    const procedureCall = `CALL createAuction('${itemName}', ${subCategoryId}, ${userId}, ${basePrice}, TIMESTAMP '${endDate}', '${itemDescription}', '${deliveryDetails}', :1)`
    const procedureParams = [itemPhoto];

    try {
        await query(procedureCall, procedureParams);
        req.flash("success", `Auction ${itemName} created`);
        res.redirect('/auctions');
    } catch (error) {
        let subcategories = [];
        try {
            subcategories = await query('SELECT * FROM getSubCategories()');
            subcategories = subcategories.map((i) => {
                return {
                    id: i.ID,
                    categoryid: i.CATEGORYID,
                    name: i.NAME
                }
            });
        } catch (error) {}
        req.flash("error", parseError(error));
        res.render('auctions/new', {error: req.flash("error"), subcategories, itemName, basePrice, itemDescription, deliveryDetails, endDate: endDate.replace(' ', 'T')});
    }
});


app.get('/auctions/:id', checkIsLogged, async (req, res) => {
    try {
        const auctionId = (isNaN(parseInt(req.params.id)) ? 'NULL' : parseInt(req.params.id));
        
        const auctionInfo = parseAuctionInfo((await query(`SELECT * FROM getAuctionInfo(${auctionId})`))[0]);

        let bids = await query(`SELECT * FROM getAuctionBids(${auctionId})`);
        bids = bids.map((i) => {
            return {
                userid: i.USERID,
                nickname: i.NICKNAME,
                amount: i.AMOUNT,
                date: parseDate(i.DATET)
            }
        });

        res.render('auctions/show', {...auctionInfo, bids});
    } catch (error) {
        req.flash("error", parseError(error));
        res.redirect('/auctions');
    }
});


app.post('/auctions/:id/bid', [checkIsLogged, checkIsNotAdmin], async (req, res) => {
    const auctionId = req.params.id,
        bidAmount = req.body.bidamount,
        userId = req.user.id;
    try {
        await query(`CALL createBid(${userId}, ${bidAmount}, ${auctionId})`);
        req.flash("success", 'Successful bid!');
    } catch (error) {
        req.flash("error", parseError(error));
    }
    res.redirect(`/auctions/${auctionId}`);
});


app.post('/auctions/:id/reviewbuyer', [checkIsLogged, checkIsNotAdmin], async (req, res) => {
    const auctionId = req.params.id,
        comment = req.body.buyerReviewComment,
        rating = req.body.buyerReviewRating,
        itemWasSold = (req.body.buyerReviewItemWasSold !== undefined);
    try {
        await query('CALL updateBuyerReview($1, $2, $3, $4)', [auctionId, comment, rating, itemWasSold]);
        req.flash("success", 'Review updated');
        res.redirect(`/users/${req.body.winnerId}`);
    } catch (error) {
        req.flash("error", parseError(error));
        res.redirect(`/auctions/${auctionId}`);
    }
});


app.post('/auctions/:id/reviewseller', [checkIsLogged, checkIsNotAdmin], async (req, res) => {
    const auctionId = req.params.id,
        comment = req.body.sellerReviewComment,
        rating = req.body.sellerReviewRating;
    try {
        await query('CALL updateSellerReview($1, $2, $3)', [auctionId, comment, rating]);
        req.flash("success", 'Review updated');
        res.redirect(`/users/${req.body.sellerId}`);
    } catch (error) {
        req.flash("error", parseError(error));
        res.redirect(`/auctions/${auctionId}`);
    }
});


app.get("*", function (req, res) {
    res.send("Error 404: Page not found");
});


app.listen(3000, () => {
    console.log('Auction Web server at localhost:3000...')
});
