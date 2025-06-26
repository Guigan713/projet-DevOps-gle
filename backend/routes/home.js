const express = require('express');
const pool = require('../config/db');
const router = express.Router();

router.get('/', async (req, res) => {
    const sql = 'SELECT * FROM home';
    try {
        const [rows] = await pool.query(sql);
        console.table(rows);
        res.status(200).json(rows);
    } catch (err) {
        console.error('Erreur SELECT all home:', err);
        res.status(500).send('error retrieving data from database');
    }
});

router.get("/:id", async (req, res) => {
    const sql = "SELECT * FROM home WHERE id = ?";
    const values = [req.params.id];
    try {
        const [rows] = await pool.query(sql, values);
        console.table(rows);
        res.status(200).json(rows);
    } catch (err) {
        console.error('Erreur SELECT by id:', err);
        res.status(500).send("Error retrieving data from database");
    }
});

router.post('/', async (req, res) => {
    const sql = 'INSERT INTO home (home_img, hello_title, gui_title) VALUES (?, ?, ?)';
    const homeData = [
        req.body.home_img,
        req.body.hello_title,
        req.body.gui_title,
    ];
    try {
        const [result] = await pool.query(sql, homeData);
        console.table(result);
        res.status(200).json({ insertId: result.insertId });
    } catch (err) {
        console.error('Erreur INSERT:', err);
        res.status(500).send("Error inserting data into database");
    }
});

router.put("/:id", async (req, res) => {
    const sql = `UPDATE home SET home_img = ?, hello_title = ?, gui_title = ? WHERE id = ?`;
    const values = [
        req.body.home_img,
        req.body.hello_title,
        req.body.gui_title,
        req.params.id
    ];
    try {
        const [result] = await pool.query(sql, values);
        console.table(result);
        res.status(200).json(result);
    } catch (err) {
        console.error('Erreur UPDATE:', err);
        res.status(500).send("Error updating database");
    }
});

router.delete("/:id", async (req, res) => {
    const sql = `DELETE FROM home WHERE id = ?`;
    const values = [req.params.id];
    try {
        const [result] = await pool.query(sql, values);
        console.table(result);
        res.status(200).json(result);
    } catch (err) {
        console.error('Erreur DELETE:', err);
        res.status(500).send("Error deleting from database");
    }
});

module.exports = router;


// const express = require('express');
// const mysql = require('../config/db')
// const router = express.Router()

// router.get('/', (req, res) => {
// 	console.log(`requête pour l'image : ${req.params.home_img}`)
//     const sql = 'SELECT * FROM home'
//     mysql.query(sql, (err, result) => {
//         if (err) {
//             res.status(500).send('error retrieving data from database')
//         } else {
//             console.table(result)
//             res.status(200).json(result)
//         }
//     })
// })

// router.get("/:id", (req, res) => {
// 	const { id } = req.params
// 	const sql = "SELECT * FROM home WHERE id = ?"
// 	const values = [id]
// 	mysql.query(sql, values, (err, result) => {
// 		if (err) {
// 			res.status(500).send("Error retrieving data from database")
// 		} else {
// 			console.table(result)
// 			res.status(200).json(result)
// 		}
// 	})
// })

// router.post('/', (req, res) => {
//     const homeData = [
//         req.body.home_img,
//         req.body.hello_title,
//         req.body.gui_title,
//     ]
//     const sql = 'INSERT INTO home (home_img, hello_title, gui_title) VALUES (?, ?, ?)'
//     console.log(req.body)
//     mysql.query(sql, homeData, (err, result) => {
//         if (err) {
//             res.status(500).send("Error retrieving data from database")
//         } else {
//             console.table(result)
// 			res.status(200).json(result)
//         }
//     })
// })

// router.put("/:id", (req, res) => {
// 	const { id } = req.params
// 	const sql = `UPDATE home SET (home_img, hello_title, gui_title) = (?, ?, ?) WHERE id = ?`
// 	console.log(req.body)
// 	const values = [req.body, id]
// 	mysql.query(sql, values, (err, result) => {
// 		if (err) {
// 			res.status(500).send("Error retrieving data from database")
// 		} else {
// 			console.table(result)
// 			res.status(200).json(result)
// 		}
// 	})
// })

// router.delete("/:id", (req, res) => {
// 	const { id } = req.params
// 	const sql = `DELETE FROM home WHERE id = ?`
// 	const values = [id]
// 	mysql.query(sql, values, (err, result) => {
// 		if (err) {
// 			res.status(500).send("Error retrieving data from database")
// 		} else {
// 			console.table(result)
// 			res.status(200).json(result)
// 		}
// 	})
// })

// module.exports = router