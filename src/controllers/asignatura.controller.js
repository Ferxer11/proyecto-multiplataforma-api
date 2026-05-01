const AsignaturaModel = require('../models/asignatura.model');
const AsignaturaController = {
  getAll: async (req, res) => {
    try {
      const asignaturas = await AsignaturaModel.getAll();
      res.status(200).json({ success: true, total: asignaturas.length, data: asignaturas });
    } catch (error) { res.status(500).json({ success: false, message: 'Error al obtener las asignaturas', error: error.message }); }
  },
  getById: async (req, res) => {
    try {
      const { clave } = req.params;
      const asignatura = await AsignaturaModel.getById(clave);
      if (!asignatura) return res.status(404).json({ success: false, message: `No se encontró la asignatura con clave ${clave}` });
      res.status(200).json({ success: true, data: asignatura });
    } catch (error) { res.status(500).json({ success: false, message: 'Error al obtener la asignatura', error: error.message }); }
  },
};
module.exports = AsignaturaController;
