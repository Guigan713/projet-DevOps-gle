const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
// const nodemailer = require("nodemailer");
const connection = require('./config/db');
const routes = require('./routes/index')
// const router = express.Router();
const path = require('path');

const port = process.env.PORT || 5000

const app = express();
app.use(cors())
app.use(morgan('tiny'))
app.use(express.json())
app.use(express.urlencoded({ extended: true }))
app.use('/images', express.static(path.join(__dirname + '/public/images')));

connection.connect(err => {
    if (err) {
        console.error('Erreur de connexion MySQL:', err);
        process.exit(1); // 🔥 Arrête le serveur si la BDD est inaccessible
    } else {
        console.log('✅ Base de données connectée');
    }
});

app.use('/pics', routes.pics)
app.use('/home', routes.home)
app.use('/about', routes.about)
app.use('/aboutme', routes.aboutme)
app.use('/snaps', routes.snaps)
// app.use('/monitor', routes.monitor)

app.get('/', (req, res) => {
    res.status(200).send('je suis dans le truc /')
})

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

app.listen(port, () => {
    console.log(`Server is running on port ${port}`)
})