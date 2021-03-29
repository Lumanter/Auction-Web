const express = require('express');
const app = express();
const session = require('express-session');
const flash = require('express-flash');
const passport = require('passport');
const fileUpload = require('express-fileupload');

const {initializePassport} = require('./passportConfig');
const {db} = require('./dbConfig');
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
    res.render('login');
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
        const results = await db.query('SELECT * FROM getAuctionParameters()');
        if (results.rows.length > 0) {
            currentParams = results.rows[0];
        }
    } catch (error) {}
    res.render('params', {params: currentParams});
});


app.post('/params', async (req, res) => {
    const {improvementpercent, minincrement} = req.body;
    try {
        await db.query('CALL createAuctionParameter($1, $2)', [improvementpercent, minincrement]);
        req.flash("success", "Auction parameters updated!");
        res.redirect('/auctions');
    } catch (error) {
        req.flash("error", error.message);
        res.render('params', {error: req.flash("error"), params: {improvementpercent, minincrement}});
    }
});


app.get('/users', [checkIsLogged, checkIsAdmin], async (req, res) => {
    let users = {};
    try {
        users = (await db.query('SELECT * FROM getUsers()')).rows;
    } catch (error) {
        res.send('An error ocurred retrieving the users');
    }
    res.render('users', {users: users});
});


app.get('/users/new', [checkIsLogged, checkIsAdmin], (req, res) => {
    res.render('users/new');
});


app.post('/users/new', async (req, res) => {
    const {nickname, email, password, firstName, lastName, phoneNumber, homeNumber} = req.body;  // take form data
    const id = (isNaN(parseInt(req.body.id)) ? null : parseInt(req.body.id));
    const isAdmin = (req.body.isAdmin !== undefined);

    const procedureCall = `CALL createUser($1, $2, $3, $4, $5, $6, $7, $8, $9)`;
    const procedureParams = [id, isAdmin, nickname, password, email, firstName, lastName, phoneNumber, homeNumber];
    
    try {
        await db.query(procedureCall, procedureParams);
        req.flash("success", `User ${nickname} created`);
        res.redirect(`/users/${id}`);
    } catch (error) {
        req.flash("error", error.message);
        res.render('users/new', {error: req.flash("error"), id, isAdmin, nickname, email, firstName, lastName, phoneNumber, homeNumber});  // pass data to restore user form
    }
});


app.get('/users/:id', checkIsLogged, async (req, res) => {
    try {
        const userId = (isNaN(parseInt(req.params.id)) ? null : parseInt(req.params.id));
        const shownUser = (await db.query('SELECT * FROM getUser($1)', [userId])).rows[0];
        res.render('users/show', {shownUser: shownUser});
    } catch (error) {
        req.flash("error", error.message);
        res.redirect('/users');
    }
});


app.get('/users/:id/edit', [checkIsLogged, checkIsAdmin], async (req, res) => {
    try {
        const userId = req.params.id;
        const editUser = (await db.query('SELECT * FROM getUser($1)', [userId])).rows[0];
        res.render('users/edit', {...editUser});
    } catch (error) {
        req.flash("error", error.message);
        res.redirect('/users');
    }
});


app.post('/users/:id', [checkIsLogged, checkIsAdmin], async (req, res) => {
    const {nickname, email, password, firstName, lastName, phoneNumber, homeNumber} = req.body;
    const id = req.params.id;

    const procedureCall = `CALL updateUser($1, $2, $3, $4, $5, $6, $7, $8)`;
    const procedureParams = [id, nickname, password, email, firstName, lastName, phoneNumber, homeNumber];
    
    try {
        await db.query(procedureCall, procedureParams);
        req.flash("success", `User ${nickname} updated`);
        res.redirect(`/users/${id}`);
    } catch (error) {
        req.flash("error", error.message);
        res.redirect(`/users/${id}/edit`)
    }
});


app.get('/auctions', checkIsLogged, (req, res) => {
    res.render('auctions');
});


app.get('/auctions/new', [checkIsLogged, checkIsNotAdmin], async (req, res) => {
    let subcategories = {};
    try {
        subcategories = (await db.query('SELECT * FROM getSubCategories()')).rows;
    } catch (error) {}
    res.render('auctions/new', {subcategories});
});


app.post('/auctions/new', async (req, res) => {
    const {itemName, subCategoryId, basePrice, itemDescription, deliveryDetails} = req.body;
    const endDate = req.body.endDate.replace('T', ' ');
    const userId = req.user.id;
    let itemPhoto = null;
    if (req.files) {
        itemPhoto = req.files.itemPhoto.data;  // image as blob object (accepted in PostgreSQL BYTEA field)
    }
    
    const procedureCall = 'CALL createAuction($1, $2, $3, $4, $5, $6, $7, $8);'
    const procedureParams = [itemName, subCategoryId, userId, basePrice, endDate, itemDescription, deliveryDetails, itemPhoto];

    try {
        await db.query(procedureCall, procedureParams);
        req.flash("success", `Auction ${itemName} created`);
        res.redirect('/auctions');
    } catch (error) {
        let subcategories = {};
        try {
            subcategories = (await db.query('SELECT * FROM getSubCategories()')).rows;
        } catch (error) {}

        req.flash("error", error.message);
        res.render('auctions/new', {error: req.flash("error"), subcategories, itemName, basePrice, itemDescription, deliveryDetails, endDate: endDate.replace(' ', 'T')});
    }
    
});


app.get("*", function (req, res) {
    res.send("Error 404: Page not found");
});


app.listen(3000, () => {
    console.log('Auction Web server at localhost:3000...')
});
