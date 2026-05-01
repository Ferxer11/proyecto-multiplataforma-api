const pool = require('../config/db');
const AsignaturaModel = {
  getAll: async () => {
    const result = await pool.query('SELECT clave_asignatura, nombre FROM asignatura ORDER BY clave_asignatura;');
    return result.rows;
  },
  getById: async (clave) => {
    const result = await pool.query('SELECT clave_asignatura, nombre FROM asignatura WHERE clave_asignatura = $1;', [clave]);
    return result.rows[0];
  },
};
module.exports = AsignaturaModel;
