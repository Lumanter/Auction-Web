const express = require('express');
const app = express();
const {db} = require('./dbConfig');
const bcrypt = require('bcrypt');
const session = require('express-session');
const flash = require('express-flash');
const passport = require('passport');
const {initializePassport} = require('./passportConfig');


initializePassport(passport);  // use custom strategy


// MIDDLEWARES
app.set("view engine", "ejs");  // use ejs
app.use(express.urlencoded({extended: false}))  // middleware to receive form data in (req.body.param)

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


function checkIsLogged(req, res, next) {  
    if (req.isAuthenticated()) {  // middleware to redirect non logged users
        return next();
    } else {
        res.redirect("/login");
    }
};


function checkIsNotLogged(req, res, next) {  
    if (req.isAuthenticated()) {  // middleware to redirect logged users
        res.redirect("/auctions");
    } else {
        return next();
    }
};


// ROUTES
app.get('/', (req, res) => {
    res.redirect('/login');
});


app.get('/users/new', checkIsNotLogged, (req, res) => {
    res.render('register');
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
        res.redirect('/');
    } catch (error) {
        req.flash("error", error.message);
        res.render('register', {error: req.flash("error"), id, isAdmin, nickname, email, firstName, lastName, phoneNumber, homeNumber});  // pass data to restore user form
    }
});


app.get('/login', checkIsNotLogged, (req, res) => {
    res.render('login');
});


app.post('/login', passport.authenticate('local', {
    successRedirect: '/auctions',
    failureRedirect: '/login',
    failureFlash: true  // pass messages from passportConfig to flash('error')
}));


app.get('/auctions', checkIsLogged, (req, res) => {
    res.render('auctions');
});


app.get('/logout', checkIsLogged, (req, res) => {
    req.logOut();  // passport function
    req.flash("success", "You have logged out");
    res.redirect('/login');
});


app.get('/params', checkIsLogged, async (req, res) => {
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


app.get("*", function (req, res) {
    res.send("Error 404: Page not found");
});


app.listen(3000, () => {
    console.log('Server at port 3000...')
});
