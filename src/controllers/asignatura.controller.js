// ============================================
// CONTROLLER: Asignatura (Materia)
// ============================================

const AsignaturaModel = require('../models/asignatura.model');

const AsignaturaController = {
  getAll: async (req, res, next) => {
    try {
      const data = await AsignaturaModel.getAll();
      res.json({ success: true, total: data.length, data });
    } catch (err) { next(err); }
  },

  getById: async (req, res, next) => {
    try {
      const data = await AsignaturaModel.getById(req.params.clave_asignatura);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe asignatura con clave ${req.params.clave_asignatura}`,
        });
      }
      res.json({ success: true, data });
    } catch (err) { next(err); }
  },

  create: async (req, res, next) => {
    try {
      const data = await AsignaturaModel.create(req.body);
      res.status(201).json({
        success: true, message: 'Materia creada correctamente', data,
      });
    } catch (err) { next(err); }
  },

  update: async (req, res, next) => {
    try {
      const data = await AsignaturaModel.update(req.params.clave_asignatura, req.body);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe asignatura con clave ${req.params.clave_asignatura}`,
        });
      }
      res.json({ success: true, message: 'Materia actualizada correctamente', data });
    } catch (err) { next(err); }
  },

  delete: async (req, res, next) => {
    try {
      const data = await AsignaturaModel.delete(req.params.clave_asignatura);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe asignatura con clave ${req.params.clave_asignatura}`,
        });
      }
      res.json({ success: true, message: 'Materia eliminada correctamente', data });
    } catch (err) { next(err); }
  },
};

module.exports = AsignaturaController;
