const ProfesorModel = require('../models/profesor.model');
const ProfesorController = {
  getAll: async (req, res) => {
    try {
      const profesores = await ProfesorModel.getAll();
      res.status(200).json({ success: true, total: profesores.length, data: profesores });
    } catch (error) { res.status(500).json({ success: false, message: 'Error al obtener los profesores', error: error.message }); }
  },
  getById: async (req, res) => {
    try {
      const { id } = req.params;
      const profesor = await ProfesorModel.getById(id);
      if (!profesor) return res.status(404).json({ success: false, message: `No se encontró el profesor con ID ${id}` });
      res.status(200).json({ success: true, data: profesor });
    } catch (error) { res.status(500).json({ success: false, message: 'Error al obtener el profesor', error: error.message }); }
  },
};
module.exports = ProfesorController;
