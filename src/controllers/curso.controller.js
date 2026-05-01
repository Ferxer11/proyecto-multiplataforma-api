const CursoModel = require('../models/curso.model');
const CursoController = {
  getAll: async (req, res) => {
    try {
      const cursos = await CursoModel.getAll();
      res.status(200).json({ success: true, total: cursos.length, data: cursos });
    } catch (error) { res.status(500).json({ success: false, message: 'Error al obtener los cursos', error: error.message }); }
  },
  getById: async (req, res) => {
    try {
      const { id } = req.params;
      const curso = await CursoModel.getById(id);
      if (!curso) return res.status(404).json({ success: false, message: `No se encontró el curso con ID ${id}` });
      res.status(200).json({ success: true, data: curso });
    } catch (error) { res.status(500).json({ success: false, message: 'Error al obtener el curso', error: error.message }); }
  },
};
module.exports = CursoController;
