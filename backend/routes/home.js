const express = require('express');
const mysql = require('../config/db')
const router = express.Router()

router.get('/', (req, res) => {
	console.log(`requête pour l'image : ${req.params.home_img}`)
    const sql = 'SELECT * FROM home'
    mysql.query(sql, (err, result) => {
        if (err) {
            res.status(500).send('error retrieving data from database')
        } else {
            console.table(result)
            res.status(200).json(result)
        }
    })
})

router.get("/:id", (req, res) => {
	const { id } = req.params
	const sql = "SELECT * FROM home WHERE id = ?"
	const values = [id]
	mysql.query(sql, values, (err, result) => {
		if (err) {
			res.status(500).send("Error retrieving data from database")
		} else {
			console.table(result)
			res.status(200).json(result)
		}
	})
})

router.post('/', (req, res) => {
    const homeData = [
        req.body.home_img,
        req.body.hello_title,
        req.body.gui_title,
    ]
    const sql = 'INSERT INTO home (home_img, hello_title, gui_title) VALUES (?, ?, ?)'
    console.log(req.body)
    mysql.query(sql, homeData, (err, result) => {
        if (err) {
            res.status(500).send("Error retrieving data from database")
        } else {
            console.table(result)
			res.status(200).json(result)
        }
    })
})

router.put("/:id", (req, res) => {
	const { id } = req.params
	const sql = `UPDATE home SET (home_img, hello_title, gui_title) = (?, ?, ?) WHERE id = ?`
	console.log(req.body)
	const values = [req.body, id]
	mysql.query(sql, values, (err, result) => {
		if (err) {
			res.status(500).send("Error retrieving data from database")
		} else {
			console.table(result)
			res.status(200).json(result)
		}
	})
})

router.delete("/:id", (req, res) => {
	const { id } = req.params
	const sql = `DELETE FROM home WHERE id = ?`
	const values = [id]
	mysql.query(sql, values, (err, result) => {
		if (err) {
			res.status(500).send("Error retrieving data from database")
		} else {
			console.table(result)
			res.status(200).json(result)
		}
	})
})

module.exports = router