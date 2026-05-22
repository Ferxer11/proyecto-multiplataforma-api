// ============================================
// MODELO: Alumno
// Consultas SQL sobre la tabla 'alumno'
// ============================================

const pool = require('../config/db');

const AlumnoModel = {
  // GET ALL — incluye JOIN con entidad_federativa
  getAll: async () => {
    const query = `
      SELECT a.numero_cuenta, a.nombre, a.apellido_paterno, a.apellido_materno,
             a.curp, a.telefono, a.sexo, a.correo_electronico, a.fecha_nacimiento,
             a.id_entidad, e.nombre_entidad, e.abreviatura
      FROM alumno a
      INNER JOIN entidad_federativa e ON a.id_entidad = e.id_entidad
      ORDER BY a.numero_cuenta;
    `;
    const result = await pool.query(query);
    return result.rows;
  },

  // GET BY ID
  getById: async (numero_cuenta) => {
    const query = `
      SELECT a.numero_cuenta, a.nombre, a.apellido_paterno, a.apellido_materno,
             a.curp, a.telefono, a.sexo, a.correo_electronico, a.fecha_nacimiento,
             a.id_entidad, e.nombre_entidad, e.abreviatura
      FROM alumno a
      INNER JOIN entidad_federativa e ON a.id_entidad = e.id_entidad
      WHERE a.numero_cuenta = $1;
    `;
    const result = await pool.query(query, [numero_cuenta]);
    return result.rows[0];
  },

  // CREATE
  create: async (data) => {
    const query = `
      INSERT INTO alumno
        (numero_cuenta, nombre, apellido_paterno, apellido_materno, curp,
         telefono, sexo, correo_electronico, fecha_nacimiento, id_entidad)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
      RETURNING *;
    `;
    const values = [
      data.numero_cuenta, data.nombre, data.apellido_paterno,
      data.apellido_materno || null, data.curp, data.telefono || null,
      data.sexo, data.correo_electronico, data.fecha_nacimiento, data.id_entidad,
    ];
    const result = await pool.query(query, values);
    return result.rows[0];
  },

  // UPDATE
  update: async (numero_cuenta, data) => {
    const query = `
      UPDATE alumno SET
        nombre = $1, apellido_paterno = $2, apellido_materno = $3, curp = $4,
        telefono = $5, sexo = $6, correo_electronico = $7,
        fecha_nacimiento = $8, id_entidad = $9
      WHERE numero_cuenta = $10
      RETURNING *;
    `;
    const values = [
      data.nombre, data.apellido_paterno, data.apellido_materno || null,
      data.curp, data.telefono || null, data.sexo, data.correo_electronico,
      data.fecha_nacimiento, data.id_entidad, numero_cuenta,
    ];
    const result = await pool.query(query, values);
    return result.rows[0];
  },

  // DELETE
  delete: async (numero_cuenta) => {
    const result = await pool.query(
      'DELETE FROM alumno WHERE numero_cuenta = $1 RETURNING *;',
      [numero_cuenta]
    );
    return result.rows[0];
  },
};

module.exports = AlumnoModel;
