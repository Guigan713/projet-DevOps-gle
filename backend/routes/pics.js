const express = require('express');
const pool = require('../config/db');
const router = express.Router();

router.get('/', async (req, res) => {
    const sql = 'SELECT * FROM pics';
    try {
        const [rows] = await pool.query(sql);
        console.table(rows);
        res.status(200).json(rows);
    } catch (err) {
        console.error('Erreur SELECT all pics:', err);
        res.status(500).send('error retrieving data from database');
    }
});

router.get("/:id", async (req, res) => {
    const sql = "SELECT * FROM pics WHERE id = ?";
    try {
        const [rows] = await pool.query(sql, [req.params.id]);
        if (rows.length === 0) {
            res.status(404).send("Pic not found");
        } else {
            res.status(200).json(rows[0]);
        }
    } catch (err) {
        console.error('Erreur SELECT by id:', err);
        res.status(500).send("Error retrieving data from database");
    }
});

router.post('/', async (req, res) => {
    const sql = "INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES (?, ?, ?, ?, ?)";
    const picsData = [
        req.body.shoe_name,
        req.body.shoe_brand,
        req.body.photographer,
        req.body.model,
        req.body.shoe_img
    ];
    try {
        const [result] = await pool.query(sql, picsData);
        const [rows] = await pool.query("SELECT * FROM pics WHERE id = ?", [result.insertId]);
        if (rows.length === 0) {
            res.status(200).json({ id: result.insertId });
        } else {
            res.status(200).json(rows[0]);
        }
    } catch (err) {
        console.error('Erreur INSERT:', err);
        res.status(500).send("Error inserting data into database");
    }
});

router.put("/:id", async (req, res) => {
    const sql = "UPDATE pics SET shoe_name = ?, shoe_brand = ?, photographer = ?, model = ?, shoe_img = ? WHERE id = ?";
    const values = [
        req.body.shoe_name,
        req.body.shoe_brand,
        req.body.photographer,
        req.body.model,
        req.body.shoe_img,
        req.params.id
    ];
    try {
        await pool.query(sql, values);
        const [rows] = await pool.query("SELECT * FROM pics WHERE id = ?", [req.params.id]);
        if (rows.length === 0) {
            res.status(200).json({ id: req.params.id });
        } else {
            res.status(200).json(rows[0]);
        }
    } catch (err) {
        console.error('Erreur UPDATE:', err);
        res.status(500).send("Error updating data in database");
    }
});

router.delete("/:id", async (req, res) => {
    const sql = `DELETE FROM pics WHERE id = ?`;
    try {
        const [result] = await pool.query(sql, [req.params.id]);
        console.table(result);
        res.status(200).json(result);
    } catch (err) {
        console.error('Erreur DELETE:', err);
        res.status(500).send("Error retrieving data from database");
    }
});

module.exports = router;


