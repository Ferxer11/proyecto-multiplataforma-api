// ============================================
// MODELO: Asignatura (Materia)
// Consultas SQL sobre la tabla 'asignatura'
// ============================================

const pool = require('../config/db');

const AsignaturaModel = {
  getAll: async () => {
    const result = await pool.query(
      'SELECT clave_asignatura, nombre FROM asignatura ORDER BY clave_asignatura;'
    );
    return result.rows;
  },

  getById: async (clave_asignatura) => {
    const result = await pool.query(
      'SELECT clave_asignatura, nombre FROM asignatura WHERE clave_asignatura = $1;',
      [clave_asignatura]
    );
    return result.rows[0];
  },

  create: async (data) => {
    const result = await pool.query(
      `INSERT INTO asignatura (clave_asignatura, nombre)
       VALUES ($1, $2) RETURNING *;`,
      [data.clave_asignatura, data.nombre]
    );
    return result.rows[0];
  },

  update: async (clave_asignatura, data) => {
    const result = await pool.query(
      `UPDATE asignatura SET nombre = $1
       WHERE clave_asignatura = $2 RETURNING *;`,
      [data.nombre, clave_asignatura]
    );
    return result.rows[0];
  },

  delete: async (clave_asignatura) => {
    const result = await pool.query(
      'DELETE FROM asignatura WHERE clave_asignatura = $1 RETURNING *;',
      [clave_asignatura]
    );
    return result.rows[0];
  },
};

module.exports = AsignaturaModel;
