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


// const express = require('express');
// const mysql = require('../config/db')
// const router = express.Router()

// router.get('/', (req, res) => {
//     const sql = 'SELECT * FROM pics'
//     mysql.query(sql, (err, result) => {
//         if (err) {
//             res.status(500).send('error retrieving data from database')
//         } else {
//             console.table(result)
//             res.status(200).json(result)
//         }
//     })
// })

// // router.get("/:id", (req, res) => {
// // 	const { id } = req.params
// // 	const sql = "SELECT * FROM pics WHERE id = ?"
// // 	const values = [id]
// // 	mysql.query(sql, values, (err, result) => {
// // 		if (err) {
// // 			res.status(500).send("Error retrieving data from database")
// // 		} else {
// // 			console.table(result)
// // 			res.status(200).json(result);
// // 		}
// // 	})
// // })
// router.get("/:id", (req, res) => {
//   const { id } = req.params;
//   const sql = "SELECT * FROM pics WHERE id = ?";
//   mysql.query(sql, [id], (err, result) => {
//     if (err) {
//       res.status(500).send("Error retrieving data from database");
//     } else if (result.length === 0) {
//       res.status(404).send("Pic not found");
//     } else {
//       res.status(200).json(result[0]);
//     }
//   });
// });

// // router.post('/', (req, res) => {
// //     const picsData = [
// //         req.body.shoe_name,
// //         req.body.shoe_brand,
// //         req.body.photographer,
// //         req.body.model,
// //         req.body.shoe_img
// //     ]
// //     const sql = 'INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES (?, ?, ?, ?, ?)'
// //     console.log(req.body)
// //     mysql.query(sql, picsData, (err, result) => {
// //         if (err) {
// //             res.status(500).send("Error retrieving data from database")
// //         } else {
// //             console.table(result)
// // 			res.status(200).json(result)
// //         }
// //     })
// // })
// router.post('/', (req, res) => {
//   const picsData = [
//     req.body.shoe_name,
//     req.body.shoe_brand,
//     req.body.photographer,
//     req.body.model,
//     req.body.shoe_img,
//   ];
//   const sql = "INSERT INTO pics (shoe_name, shoe_brand, photographer, model, shoe_img) VALUES (?, ?, ?, ?, ?)";
//   mysql.query(sql, picsData, (err, result) => {
//     if (err) {
//       res.status(500).send("Error inserting data into database");
//     } else {
//       const newPicId = result.insertId;
//       mysql.query("SELECT * FROM pics WHERE id = ?", [newPicId], (err2, rows) => {
//         if (err2 || rows.length === 0) {
//           res.status(200).json({ id: newPicId });
//         } else {
//           res.status(200).json(rows[0]);
//         }
//       });
//     }
//   });
// });

// // router.put("/:id", (req, res) => {
// // 	const { id } = req.params
// // 	const sql = `UPDATE pics SET shoe_name = ?, shoe_brand = ?, photographer = ?, model = ?, shoe_img = ? WHERE id = ?`
// // 	console.log(req.body)
// // 	const values = [req.body.shoe_name, req.body.shoe_brand, req.body.photographer, req.body.model, req.body.shoe_img, id]
// // 	mysql.query(sql, values, (err, result) => {
// // 		if (err) {
// // 			res.status(500).send("Error retrieving data from database")
// // 		} else {
// // 			console.table(result)
// // 			res.status(200).json(result)
// // 		}
// // 	})
// // })
// router.put("/:id", (req, res) => {
//   const { id } = req.params;
//   const sql = "UPDATE pics SET shoe_name = ?, shoe_brand = ?, photographer = ?, model = ?, shoe_img = ? WHERE id = ?";
//   const values = [
//     req.body.shoe_name,
//     req.body.shoe_brand,
//     req.body.photographer,
//     req.body.model,
//     req.body.shoe_img,
//     id,
//   ];
//   mysql.query(sql, values, (err, result) => {
//     if (err) {
//       res.status(500).send("Error updating data in database");
//     } else {
//       mysql.query("SELECT * FROM pics WHERE id = ?", [id], (err2, rows) => {
//         if (err2 || rows.length === 0) {
//           res.status(200).json({ id });
//         } else {
//           res.status(200).json(rows[0]);
//         }
//       });
//     }
//   });
// });

// router.delete("/:id", (req, res) => {
// 	const { id } = req.params
// 	const sql = `DELETE FROM pics WHERE id = ?`
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