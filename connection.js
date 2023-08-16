const mysql = require("mysql");
const dotenv = require("dotenv");

dotenv.config();

const connection = mysql.createConnection({
  host: "localhost", // host for connection
  port: 3306, // default port for mysql is 3306
  database: process.env.DATABASE_NAME, // database from which we want to connect out node application
  user: "root", // username of the mysql connection
  password: process.env.PASSWORD, // password of the mysql connection
  multipleStatements: true
});

// connection.connect();
connection.connect(function (err) {
  if (err) {
    console.log(err);
    console.log("Error occured while connecting");
  } else {
    console.log("Connected to the server successfully!");
  }
});

module.exports = connection;
