const express = require("express");
const bodyParser = require("body-parser");
const session = require("express-session");
const path = require("path");

const loginRouter = require("./routes/auth/login");
const signUpRouter = require("./routes/auth/signUp");
const itemsRouter = require("./routes/items");
const offerRouter = require("./routes/offer");
const buyNowRouter = require("./routes/buy_now");
const profileRouter = require("./routes/profile");
const boughtRouter = require("./routes/bought");
const listedRouter = require("./routes/listed");
const { processing } = require("./middleware");

const app = express();

// Require static assets from public folder
app.use(express.static(path.join(__dirname, 'public')));

// Set 'views' directory for any views 
// being rendered res.render()
// Set view engine as EJS
// app.engine('h', require('ejs').renderFile);
app.set('view engine', 'ejs');

app.use(session({
  secret: process.env.SESSION_SECRET,
  saveUninitialized: false,
  resave: false
}));


app.use(bodyParser.urlencoded({extended:false}));
app.use(bodyParser.json());
// app.use(checkLoginStatus);
app.use(processing);

app.use("/login", loginRouter);
app.use("/signUp", signUpRouter);
app.use("/items", itemsRouter);
app.use("/buyNow",buyNowRouter);
app.use("/profile", profileRouter);
app.use("/bought", boughtRouter);
app.use("/listed", listedRouter);
app.use("/offer", offerRouter);


app.get("/", (req, res,) => {
  res.redirect("/login");
});

app.listen(process.env.PORT, () => {
  console.log(`Listening on port ${process.env.PORT}`);
});
