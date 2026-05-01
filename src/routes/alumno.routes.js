const express = require('express');
const router = express.Router();
const AlumnoController = require('../controllers/alumno.controller');
router.get('/', AlumnoController.getAll);
router.get('/:numero_cuenta', AlumnoController.getById);
module.exports = router;
