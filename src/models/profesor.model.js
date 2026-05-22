// ============================================
// MODELO: Profesor
// Consultas SQL sobre la tabla 'profesor'
// ============================================

const pool = require('../config/db');

const ProfesorModel = {
  getAll: async () => {
    const result = await pool.query(`
      SELECT id_profesor, nombre, apellido_paterno, apellido_materno, curp, rfc,
             telefono, sexo, correo_electronico, fecha_nacimiento, sueldo
      FROM profesor
      ORDER BY id_profesor;
    `);
    return result.rows;
  },

  getById: async (id_profesor) => {
    const result = await pool.query(
      `SELECT id_profesor, nombre, apellido_paterno, apellido_materno, curp, rfc,
              telefono, sexo, correo_electronico, fecha_nacimiento, sueldo
       FROM profesor WHERE id_profesor = $1;`,
      [id_profesor]
    );
    return result.rows[0];
  },

  // id_profesor es IDENTITY → no se manda en el INSERT
  create: async (data) => {
    const query = `
      INSERT INTO profesor
        (nombre, apellido_paterno, apellido_materno, curp, rfc, telefono,
         sexo, correo_electronico, fecha_nacimiento, sueldo)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
      RETURNING *;
    `;
    const values = [
      data.nombre, data.apellido_paterno, data.apellido_materno || null,
      data.curp, data.rfc, data.telefono || null, data.sexo,
      data.correo_electronico, data.fecha_nacimiento, data.sueldo,
    ];
    const result = await pool.query(query, values);
    return result.rows[0];
  },

  update: async (id_profesor, data) => {
    const query = `
      UPDATE profesor SET
        nombre = $1, apellido_paterno = $2, apellido_materno = $3, curp = $4,
        rfc = $5, telefono = $6, sexo = $7, correo_electronico = $8,
        fecha_nacimiento = $9, sueldo = $10
      WHERE id_profesor = $11
      RETURNING *;
    `;
    const values = [
      data.nombre, data.apellido_paterno, data.apellido_materno || null,
      data.curp, data.rfc, data.telefono || null, data.sexo,
      data.correo_electronico, data.fecha_nacimiento, data.sueldo,
      id_profesor,
    ];
    const result = await pool.query(query, values);
    return result.rows[0];
  },

  delete: async (id_profesor) => {
    const result = await pool.query(
      'DELETE FROM profesor WHERE id_profesor = $1 RETURNING *;',
      [id_profesor]
    );
    return result.rows[0];
  },
};

module.exports = ProfesorModel;
