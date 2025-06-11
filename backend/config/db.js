require('dotenv').config()
const mysql = require('mysql2')

const connection = mysql.createConnection({
    host: process.env.DB_HOST || 'host.docker.internal',
    port: process.env.DB_PORT || 3306,
    user: process.env.DB_USER || 'guillaume',
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME || 'sneakerportfolio',
})

module.exports = connection