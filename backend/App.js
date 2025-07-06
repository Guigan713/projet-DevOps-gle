const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
// const nodemailer = require("nodemailer");
const pool = require('./config/db');
const routes = require('./routes/index')
const path = require('path');

const promClient = require('prom-client');

const port = process.env.PORT || 5000

const app = express();

const register = new promClient.Registry();

app.use(cors({
    origin: [
        'http://localhost:3000',
        'http://sneakerportfolio.eu',
        'https://sneakerportfolio.eu'
    ],
    methods: "GET,HEAD,PUT,PATCH,POST,DELETE",
    credentials: true,
    allowedHeaders: ["Content-Type", "Authorization"]
}));
app.use(morgan('tiny'))
app.use(express.json())
app.use(express.urlencoded({ extended: true }))
app.use('/api/images', express.static(path.join(__dirname + '/public/images')));

app.use('/api/pics', routes.pics)
app.use('/api/home', routes.home)
app.use('/api/about', routes.about)
app.use('/api/aboutme', routes.aboutme)
app.use('/api/snaps', routes.snaps)
// app.use('/monitor', routes.monitor)

// endpoint pour métriques prometheus
app.get('/metrics', async (req, res) => {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
});

app.get('/health', (req, res) => {
    res.status(200).send('OK!');
});

app.get('/', (req, res) => {
    res.status(200).json({ 
        message: 'Sneaker Portfolio API', 
        version: '1.0.0',
        endpoints: ['/api/pics', '/api/home', '/api/about', '/api/aboutme', '/api/snaps']
    });
});

app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});

module.exports = { pool, app };