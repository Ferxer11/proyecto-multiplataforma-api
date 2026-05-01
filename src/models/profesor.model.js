const pool = require('../config/db');
const ProfesorModel = {
  getAll: async () => {
    const result = await pool.query(`SELECT id_profesor, nombre, apellido_paterno, apellido_materno, curp, rfc, telefono, sexo, correo_electronico, fecha_nacimiento, sueldo FROM profesor ORDER BY id_profesor;`);
    return result.rows;
  },
  getById: async (id) => {
    const result = await pool.query(`SELECT id_profesor, nombre, apellido_paterno, apellido_materno, curp, rfc, telefono, sexo, correo_electronico, fecha_nacimiento, sueldo FROM profesor WHERE id_profesor = $1;`, [id]);
    return result.rows[0];
  },
};
module.exports = ProfesorModel;
