const express = require('express');
const pool = require('../config/db');
const router = express.Router();

router.get('/', async (req, res) => {
    const sql = 'SELECT * FROM aboutme';
    try {
        const [rows] = await pool.query(sql);
        console.table(rows);
        res.status(200).json(rows);
    } catch (err) {
        console.error('Erreur SELECT all aboutme:', err);
        res.status(500).send('error retrieving data from database');
    }
});

router.get("/:id", async (req, res) => {
    const sql = "SELECT * FROM aboutme WHERE id = ?";
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
    const sql = 'INSERT INTO aboutme (aboutme_img) VALUES (?)';
    const aboutmeData = [req.body.aboutme_img];
    try {
        const [result] = await pool.query(sql, aboutmeData);
        console.table(result);
        res.status(200).json({ insertId: result.insertId });
    } catch (err) {
        console.error('Erreur INSERT:', err);
        res.status(500).send("Error inserting data into database");
    }
});

router.put("/:id", async (req, res) => {
    const sql = `UPDATE aboutme SET aboutme_img = ? WHERE id = ?`;
    const values = [req.body.aboutme_img, req.params.id];
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
    const sql = `DELETE FROM aboutme WHERE id = ?`;
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


