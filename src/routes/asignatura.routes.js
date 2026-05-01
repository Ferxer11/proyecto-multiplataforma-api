const express = require('express');
const router = express.Router();
const AsignaturaController = require('../controllers/asignatura.controller');
router.get('/', AsignaturaController.getAll);
router.get('/:clave', AsignaturaController.getById);
module.exports = router;
