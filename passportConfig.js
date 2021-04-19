const LocalStrategy = require('passport-local').Strategy;
const oracledb = require('oracledb');
const {dbConfig, parseUser, parseError} = require('./dbConfig');


function authenticateUser(nickname, password, done) {
    oracledb.getConnection(dbConfig, 
        (error, connection) => {
            connection.execute(`SELECT * FROM c##auctionweb.getLoginUser(:1, :2)`, [nickname, password], {outFormat: oracledb.OUT_FORMAT_OBJECT},
                (error, results) => {
                    if (error) {
                        return done(null, false, {message: parseError(error)});
                    } else {
                        const user = parseUser(results.rows[0]);
                        return done(null, user);  // store user in session cookie
                    }
                }
            )
        }
    )
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
