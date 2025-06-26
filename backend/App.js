const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
// const nodemailer = require("nodemailer");
// const connection = require('./config/db');
const pool = require('./config/db');
const routes = require('./routes/index')
const path = require('path');

const port = process.env.PORT || 5000

const app = express();
app.use(cors({
    origin: [
        'https://projet-devops-gle.fr',
        'http://localhost:3000'
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

app.get('/health', (req, res) => {
    res.status(200).send('OK!');
});

app.get('/', (req, res) => {
    res.status(200).send('je suis dans le truc /');
});

app.use(express.static(path.join(__dirname, 'build')));
app.get('*', (req, res) => {
    if (req.path.startsWith('/api')) {
        res.status(404).send('API route not found');
        return;
    }
    res.sendFile(path.join(__dirname, 'build', 'index.html'));
});

app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});

module.exports = { pool, app };

// const app = express();
// app.use(cors())
// app.use(morgan('tiny'))
// app.use(express.json())
// app.use(express.urlencoded({ extended: true }))
// app.use('/images', express.static(path.join(__dirname + '/public/images')));

// connection.connect(err => {
//     if (err) {
//         console.error('Erreur de connexion MySQL:', err);
//         process.exit(1); // 🔥 Arrête le serveur si la BDD est inaccessible
//     } else {
//         console.log('✅ Base de données connectée');
//     }
// });

// app.use('/pics', routes.pics)
// app.use('/home', routes.home)
// app.use('/about', routes.about)
// app.use('/aboutme', routes.aboutme)
// app.use('/snaps', routes.snaps)
// // app.use('/monitor', routes.monitor)

// app.get('/', (req, res) => {
//     res.status(200).send('je suis dans le truc /')
// })

// const contactEmail = nodemailer.createTransport({
// 	service: 'mailtrap',
// 	auth: {
// 	user: "f7386ca61edea1",
// 	pass: "548870bba3ed2f",
// 	},
// });

// contactEmail.verify((error) => {
// 	if (error) {
// 	console.log(error);
// 	} else {
// 	console.log("Ready to Send");
// 	}
// });

// router.post("/contact", (req, res) => {
// 	const name = req.body.name;
// 	const email = req.body.email;
// 	const message = req.body.message; 
// 	const mail = {
// 	from: name,
// 	to: "guillaume.lequin713@gmail.com",
// 	subject: "Contact Form Submission",
// 	html: `<p>Name: ${name}</p>
// 			<p>Email: ${email}</p>
// 			<p>Message: ${message}</p>`,
// 	};
// 	contactEmail.sendMail(mail, (error) => {
// 	if (error) {
// 		res.json({ status: "ERROR" });
// 	} else {
// 		res.json({ status: "Message Sent" });
// 	}
// 	});
// });

// app.listen(port, () => {
//     console.log(`Server is running on port ${port}`)
// })