const AlumnoCursoModel = require('../models/alumnoCurso.model');
const AlumnoCursoController = {
  getAll: async (req, res) => {
    try {
      const inscripciones = await AlumnoCursoModel.getAll();
      res.status(200).json({ success: true, total: inscripciones.length, data: inscripciones });
    } catch (error) { res.status(500).json({ success: false, message: 'Error al obtener las inscripciones', error: error.message }); }
  },
  getById: async (req, res) => {
    try {
      const { id } = req.params;
      const inscripcion = await AlumnoCursoModel.getById(id);
      if (!inscripcion) return res.status(404).json({ success: false, message: `No se encontró la inscripción con ID ${id}` });
      res.status(200).json({ success: true, data: inscripcion });
    } catch (error) { res.status(500).json({ success: false, message: 'Error al obtener la inscripción', error: error.message }); }
  },
};
module.exports = AlumnoCursoController;
