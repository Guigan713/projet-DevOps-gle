const express = require('express');
const mysql = require('../config/db')
const router = express.Router()

router.get('/', (req, res) => {
    const sql = 'SELECT * FROM pics'
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
	const sql = "SELECT * FROM pics WHERE id = ?"
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
    const picsData = [
        req.body.shoe_name,
        req.body.shoe_brand,
        req.body.photographer,
        req.body.model,
        req.body.shoe_img
    ]
    const sql = 'INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES (?, ?, ?, ?, ?)'
    console.log(req.body)
    mysql.query(sql, picsData, (err, result) => {
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
	const sql = `UPDATE pics SET (shoe_name, shoe_brand, photographer, model, shoe_img) = (?, ?, ?, ?, ?) WHERE id = ?`
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
	const sql = `DELETE FROM pics WHERE id = ?`
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