function checkIsLogged(req, res, next) {  
    if (req.isAuthenticated()) {  // middleware to redirect non logged users
        return next();
    } else {
        res.redirect("/login");
    }
};


function checkIsNotLogged(req, res, next) {  
    if (req.isAuthenticated()) {  // middleware to redirect logged users
        res.redirect(`/users/${req.user.id}`);
    } else {
        return next();
    }
};


function checkIsAdmin(req, res, next) {  
    if (req.user.isadmin) {  // middleware to redirect non admin users
        return next();
    } else {
        res.redirect(`/users/${req.user.id}`);
    }
};


function checkIsNotAdmin(req, res, next) {  
    if (req.user.isadmin) {  // middleware to redirect admin users
        res.redirect(`/users/${req.user.id}`);
    } else {
        return next();
    }
};

module.exports = {checkIsLogged, checkIsNotLogged, checkIsAdmin, checkIsNotAdmin}

