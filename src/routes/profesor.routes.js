const express = require('express');
const router = express.Router();
const ProfesorController = require('../controllers/profesor.controller');
router.get('/', ProfesorController.getAll);
router.get('/:id', ProfesorController.getById);
module.exports = router;
