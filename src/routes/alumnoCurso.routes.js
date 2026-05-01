const express = require('express');
const router = express.Router();
const AlumnoCursoController = require('../controllers/alumnoCurso.controller');
router.get('/', AlumnoCursoController.getAll);
router.get('/:id', AlumnoCursoController.getById);
module.exports = router;
