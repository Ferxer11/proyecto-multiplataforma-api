// ============================================
// RUTAS: Profesor
// ============================================

const express = require('express');
const router = express.Router();
const ProfesorController = require('../controllers/profesor.controller');
const {
  profesorValidator, profesorUpdateValidator, profesorIdValidator,
} = require('../middleware/validators');

/**
 * @swagger
 * tags:
 *   name: Profesores
 *   description: Gestión de profesores (tabla obligatoria)
 */

/**
 * @swagger
 * /api/profesores:
 *   get:
 *     summary: Lista todos los profesores
 *     tags: [Profesores]
 *     responses:
 *       200: { description: OK }
 */
router.get('/', ProfesorController.getAll);

/**
 * @swagger
 * /api/profesores/{id_profesor}:
 *   get:
 *     summary: Obtiene un profesor por ID
 *     tags: [Profesores]
 *     parameters:
 *       - in: path
 *         name: id_profesor
 *         required: true
 *         schema: { type: integer }
 *     responses:
 *       200: { description: OK }
 *       404: { description: No existe }
 */
router.get('/:id_profesor', profesorIdValidator, ProfesorController.getById);

/**
 * @swagger
 * /api/profesores:
 *   post:
 *     summary: Crea un nuevo profesor
 *     tags: [Profesores]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema: { $ref: '#/components/schemas/Profesor' }
 *     responses:
 *       201: { description: Creado }
 *       400: { description: Validación fallida }
 */
router.post('/', profesorValidator, ProfesorController.create);

/**
 * @swagger
 * /api/profesores/{id_profesor}:
 *   put:
 *     summary: Actualiza un profesor existente
 *     tags: [Profesores]
 *     parameters:
 *       - in: path
 *         name: id_profesor
 *         required: true
 *         schema: { type: integer }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema: { $ref: '#/components/schemas/Profesor' }
 *     responses:
 *       200: { description: Actualizado }
 *       400: { description: Validación fallida }
 *       404: { description: No existe }
 */
router.put('/:id_profesor', profesorUpdateValidator, ProfesorController.update);

/**
 * @swagger
 * /api/profesores/{id_profesor}:
 *   delete:
 *     summary: Elimina un profesor
 *     tags: [Profesores]
 *     parameters:
 *       - in: path
 *         name: id_profesor
 *         required: true
 *         schema: { type: integer }
 *     responses:
 *       200: { description: Eliminado }
 *       404: { description: No existe }
 */
router.delete('/:id_profesor', profesorIdValidator, ProfesorController.delete);

module.exports = router;
