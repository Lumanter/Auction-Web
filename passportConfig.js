const LocalStrategy = require('passport-local').Strategy;
const {db} = require('./dbConfig');
const bcrypt = require('bcrypt');


function authenticateUser(nickname, password, done) {
    db.query(`SELECT * FROM getLoginUser($1, $2)`, [nickname, password],
    (error, results) => {
        if (error) {
            return done(null, false, {message: error.message});
        } else {
            const user = results.rows[0];
            return done(null, user);  // store user in session cookie
        }
    });
};


function initializePassport(passport) {
    passport.use(
        new LocalStrategy({
            usernameField: "nickname",  // input named nickname in login.ejs
            passwordField: "password"
        }, authenticateUser)
    );
    passport.serializeUser((user, done) => done(null, user));  
    passport.deserializeUser((user, done) =>  done(null, user));
}


module.exports = {initializePassport};
