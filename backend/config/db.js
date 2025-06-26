require('dotenv').config()
const mysql = require('mysql2/promise');


const poolPromise = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

module.exports = poolPromise;
// const connection = mysql.createConnection({
//     host: process.env.DB_HOST,
//     port: process.env.DB_PORT || 3306,
//     user: process.env.DB_USER || 'guillaume',
//     password: process.env.DB_PASSWORD,
//     database: process.env.DB_NAME || 'sneakerportfolio',
// })


// module.exports = connection

// let connection;

// async function connectWithRetry() {
//   while (!connection) {
//     try {
//       connection = await mysql.createConnection({
//         host: process.env.DB_HOST || 'localhost',
//         user: process.env.DB_USER,
//         password: process.env.DB_PASSWORD,
//         database: process.env.DB_NAME,
//         port: process.env.DB_PORT
//       });
//       console.log('Base de données connectée !');
//     } catch (err) {
//       console.error("Erreur de connexion MySQL (nouvel essai dans 5s):", err.message);
//       await new Promise(res => setTimeout(res, 5000));
//     }
//   }
//   return connection;
// }

// module.exports = connectWithRetry;

