// ============================================
// RUTAS: Asignatura (Materia)
// ============================================

const express = require('express');
const router = express.Router();
const AsignaturaController = require('../controllers/asignatura.controller');
const {
  asignaturaValidator, asignaturaUpdateValidator, asignaturaIdValidator,
} = require('../middleware/validators');

/**
 * @swagger
 * tags:
 *   name: Materias
 *   description: Gestión de materias / asignaturas
 */

/**
 * @swagger
 * /api/asignaturas:
 *   get:
 *     summary: Lista todas las materias
 *     tags: [Materias]
 *     responses:
 *       200: { description: OK }
 */
router.get('/', AsignaturaController.getAll);

/**
 * @swagger
 * /api/asignaturas/{clave_asignatura}:
 *   get:
 *     summary: Obtiene una materia por su clave
 *     tags: [Materias]
 *     parameters:
 *       - in: path
 *         name: clave_asignatura
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200: { description: OK }
 *       404: { description: No existe }
 */
router.get('/:clave_asignatura', asignaturaIdValidator, AsignaturaController.getById);

/**
 * @swagger
 * /api/asignaturas:
 *   post:
 *     summary: Crea una nueva materia
 *     tags: [Materias]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema: { $ref: '#/components/schemas/Asignatura' }
 *     responses:
 *       201: { description: Creada }
 *       400: { description: Validación fallida }
 *       409: { description: Clave duplicada }
 */
router.post('/', asignaturaValidator, AsignaturaController.create);

/**
 * @swagger
 * /api/asignaturas/{clave_asignatura}:
 *   put:
 *     summary: Actualiza el nombre de una materia
 *     tags: [Materias]
 *     parameters:
 *       - in: path
 *         name: clave_asignatura
 *         required: true
 *         schema: { type: string }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema: { $ref: '#/components/schemas/Asignatura' }
 *     responses:
 *       200: { description: Actualizada }
 *       404: { description: No existe }
 */
router.put('/:clave_asignatura', asignaturaUpdateValidator, AsignaturaController.update);

/**
 * @swagger
 * /api/asignaturas/{clave_asignatura}:
 *   delete:
 *     summary: Elimina una materia
 *     tags: [Materias]
 *     parameters:
 *       - in: path
 *         name: clave_asignatura
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200: { description: Eliminada }
 *       404: { description: No existe }
 */
router.delete('/:clave_asignatura', asignaturaIdValidator, AsignaturaController.delete);

module.exports = router;
