const pool = require('../config/db');
const AlumnoModel = {
  getAll: async () => {
    const query = `SELECT a.numero_cuenta, a.nombre, a.apellido_paterno, a.apellido_materno, a.curp, a.telefono, a.sexo, a.correo_electronico, a.fecha_nacimiento, e.nombre_entidad, e.abreviatura FROM alumno a INNER JOIN entidad_federativa e ON a.id_entidad = e.id_entidad ORDER BY a.numero_cuenta;`;
    const result = await pool.query(query);
    return result.rows;
  },
  getById: async (numeroCuenta) => {
    const query = `SELECT a.numero_cuenta, a.nombre, a.apellido_paterno, a.apellido_materno, a.curp, a.telefono, a.sexo, a.correo_electronico, a.fecha_nacimiento, e.nombre_entidad, e.abreviatura FROM alumno a INNER JOIN entidad_federativa e ON a.id_entidad = e.id_entidad WHERE a.numero_cuenta = $1;`;
    const result = await pool.query(query, [numeroCuenta]);
    return result.rows[0];
  },
};
module.exports = AlumnoModel;
