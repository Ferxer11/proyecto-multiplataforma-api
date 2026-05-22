// ============================================
// RUTAS: Alumno
// ============================================

const express = require('express');
const router = express.Router();
const AlumnoController = require('../controllers/alumno.controller');
const {
  alumnoValidator, alumnoUpdateValidator, alumnoIdValidator,
} = require('../middleware/validators');

/**
 * @swagger
 * tags:
 *   name: Alumnos
 *   description: Gestión de alumnos (tabla obligatoria)
 */

/**
 * @swagger
 * /api/alumnos:
 *   get:
 *     summary: Lista todos los alumnos
 *     tags: [Alumnos]
 *     responses:
 *       200:
 *         description: Lista obtenida correctamente
 */
router.get('/', AlumnoController.getAll);

/**
 * @swagger
 * /api/alumnos/{numero_cuenta}:
 *   get:
 *     summary: Obtiene un alumno por número de cuenta
 *     tags: [Alumnos]
 *     parameters:
 *       - in: path
 *         name: numero_cuenta
 *         required: true
 *         schema: { type: integer }
 *     responses:
 *       200: { description: Alumno encontrado }
 *       404: { description: No existe }
 */
router.get('/:numero_cuenta', alumnoIdValidator, AlumnoController.getById);

/**
 * @swagger
 * /api/alumnos:
 *   post:
 *     summary: Crea un nuevo alumno
 *     tags: [Alumnos]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema: { $ref: '#/components/schemas/Alumno' }
 *     responses:
 *       201: { description: Alumno creado }
 *       400: { description: Validación fallida }
 *       409: { description: Número de cuenta ya existe }
 */
router.post('/', alumnoValidator, AlumnoController.create);

/**
 * @swagger
 * /api/alumnos/{numero_cuenta}:
 *   put:
 *     summary: Actualiza un alumno existente
 *     tags: [Alumnos]
 *     parameters:
 *       - in: path
 *         name: numero_cuenta
 *         required: true
 *         schema: { type: integer }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema: { $ref: '#/components/schemas/Alumno' }
 *     responses:
 *       200: { description: Actualizado }
 *       400: { description: Validación fallida }
 *       404: { description: No existe }
 */
router.put('/:numero_cuenta', alumnoUpdateValidator, AlumnoController.update);

/**
 * @swagger
 * /api/alumnos/{numero_cuenta}:
 *   delete:
 *     summary: Elimina un alumno
 *     tags: [Alumnos]
 *     parameters:
 *       - in: path
 *         name: numero_cuenta
 *         required: true
 *         schema: { type: integer }
 *     responses:
 *       200: { description: Eliminado }
 *       404: { description: No existe }
 */
router.delete('/:numero_cuenta', alumnoIdValidator, AlumnoController.delete);

module.exports = router;
