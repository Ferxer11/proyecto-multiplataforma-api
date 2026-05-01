const express = require('express');
const router = express.Router();
const CursoController = require('../controllers/curso.controller');
router.get('/', CursoController.getAll);
router.get('/:id', CursoController.getById);
module.exports = router;
