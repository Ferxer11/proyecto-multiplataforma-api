const AlumnoModel = require('../models/alumno.model');
const AlumnoController = {
  getAll: async (req, res) => {
    try {
      const alumnos = await AlumnoModel.getAll();
      res.status(200).json({ success: true, total: alumnos.length, data: alumnos });
    } catch (error) {
      console.error('Error en getAll alumnos:', error);
      res.status(500).json({ success: false, message: 'Error al obtener los alumnos', error: error.message });
    }
  },
  getById: async (req, res) => {
    try {
      const { numero_cuenta } = req.params;
      const alumno = await AlumnoModel.getById(numero_cuenta);
      if (!alumno) return res.status(404).json({ success: false, message: `No se encontró el alumno con número de cuenta ${numero_cuenta}` });
      res.status(200).json({ success: true, data: alumno });
    } catch (error) {
      res.status(500).json({ success: false, message: 'Error al obtener el alumno', error: error.message });
    }
  },
};
module.exports = AlumnoController;
