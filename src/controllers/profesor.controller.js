// ============================================
// CONTROLLER: Profesor
// ============================================

const ProfesorModel = require('../models/profesor.model');

const ProfesorController = {
  getAll: async (req, res, next) => {
    try {
      const data = await ProfesorModel.getAll();
      res.json({ success: true, total: data.length, data });
    } catch (err) { next(err); }
  },

  getById: async (req, res, next) => {
    try {
      const data = await ProfesorModel.getById(req.params.id_profesor);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe profesor con id ${req.params.id_profesor}`,
        });
      }
      res.json({ success: true, data });
    } catch (err) { next(err); }
  },

  create: async (req, res, next) => {
    try {
      const data = await ProfesorModel.create(req.body);
      res.status(201).json({
        success: true, message: 'Profesor creado correctamente', data,
      });
    } catch (err) { next(err); }
  },

  update: async (req, res, next) => {
    try {
      const data = await ProfesorModel.update(req.params.id_profesor, req.body);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe profesor con id ${req.params.id_profesor}`,
        });
      }
      res.json({ success: true, message: 'Profesor actualizado correctamente', data });
    } catch (err) { next(err); }
  },

  delete: async (req, res, next) => {
    try {
      const data = await ProfesorModel.delete(req.params.id_profesor);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe profesor con id ${req.params.id_profesor}`,
        });
      }
      res.json({ success: true, message: 'Profesor eliminado correctamente', data });
    } catch (err) { next(err); }
  },
};

module.exports = ProfesorController;
