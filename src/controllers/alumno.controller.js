// ============================================
// CONTROLLER: Alumno
// ============================================

const AlumnoModel = require('../models/alumno.model');

const AlumnoController = {
  getAll: async (req, res, next) => {
    try {
      const data = await AlumnoModel.getAll();
      res.json({ success: true, total: data.length, data });
    } catch (err) { next(err); }
  },

  getById: async (req, res, next) => {
    try {
      const data = await AlumnoModel.getById(req.params.numero_cuenta);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe alumno con numero_cuenta ${req.params.numero_cuenta}`,
        });
      }
      res.json({ success: true, data });
    } catch (err) { next(err); }
  },

  create: async (req, res, next) => {
    try {
      const data = await AlumnoModel.create(req.body);
      res.status(201).json({
        success: true,
        message: 'Alumno creado correctamente',
        data,
      });
    } catch (err) { next(err); }
  },

  update: async (req, res, next) => {
    try {
      const data = await AlumnoModel.update(req.params.numero_cuenta, req.body);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe alumno con numero_cuenta ${req.params.numero_cuenta}`,
        });
      }
      res.json({ success: true, message: 'Alumno actualizado correctamente', data });
    } catch (err) { next(err); }
  },

  delete: async (req, res, next) => {
    try {
      const data = await AlumnoModel.delete(req.params.numero_cuenta);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe alumno con numero_cuenta ${req.params.numero_cuenta}`,
        });
      }
      res.json({ success: true, message: 'Alumno eliminado correctamente', data });
    } catch (err) { next(err); }
  },
};

module.exports = AlumnoController;
