const pool = require('../config/db');
const AlumnoCursoModel = {
  getAll: async () => {
    const query = `SELECT ac.id_alumno_curso, ac.numero_cuenta, CONCAT(al.nombre, ' ', al.apellido_paterno, ' ', al.apellido_materno) AS nombre_alumno, ac.id_curso, asig.nombre AS nombre_asignatura, g.nombre_grupo, ac.primer_parcial, ac.segundo_parcial, ac.tercer_parcial, ac.estatus_evaluacion, CASE WHEN ac.estatus_evaluacion = 'NP' THEN NULL WHEN ac.primer_parcial IS NOT NULL AND ac.segundo_parcial IS NOT NULL AND ac.tercer_parcial IS NOT NULL THEN ROUND((ac.primer_parcial + ac.segundo_parcial + ac.tercer_parcial) / 3, 2) ELSE NULL END AS promedio FROM alumno_curso ac INNER JOIN alumno al ON ac.numero_cuenta = al.numero_cuenta INNER JOIN curso c ON ac.id_curso = c.id_curso INNER JOIN asignatura asig ON c.clave_asignatura = asig.clave_asignatura INNER JOIN grupo g ON c.id_grupo = g.id_grupo ORDER BY ac.numero_cuenta, ac.id_curso;`;
    const result = await pool.query(query);
    return result.rows;
  },
  getById: async (id) => {
    const query = `SELECT ac.id_alumno_curso, ac.numero_cuenta, CONCAT(al.nombre, ' ', al.apellido_paterno, ' ', al.apellido_materno) AS nombre_alumno, ac.id_curso, asig.nombre AS nombre_asignatura, g.nombre_grupo, ac.primer_parcial, ac.segundo_parcial, ac.tercer_parcial, ac.estatus_evaluacion FROM alumno_curso ac INNER JOIN alumno al ON ac.numero_cuenta = al.numero_cuenta INNER JOIN curso c ON ac.id_curso = c.id_curso INNER JOIN asignatura asig ON c.clave_asignatura = asig.clave_asignatura INNER JOIN grupo g ON c.id_grupo = g.id_grupo WHERE ac.id_alumno_curso = $1;`;
    const result = await pool.query(query, [id]);
    return result.rows[0];
  },
};
module.exports = AlumnoCursoModel;
