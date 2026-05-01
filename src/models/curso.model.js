const pool = require('../config/db');
const CursoModel = {
  getAll: async () => {
    const query = `SELECT c.id_curso, c.cupo_maximo, c.inscritos_actual, a.clave_asignatura, a.nombre AS nombre_asignatura, p.id_profesor, CONCAT(p.nombre, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS nombre_profesor, g.nombre_grupo, tc.nombre_tipo AS tipo_curso, pa.periodo_nombre AS periodo, ns.nombre_semestre AS semestre FROM curso c INNER JOIN asignatura a ON c.clave_asignatura = a.clave_asignatura INNER JOIN profesor p ON c.id_profesor = p.id_profesor INNER JOIN grupo g ON c.id_grupo = g.id_grupo INNER JOIN tipo_curso tc ON c.id_tipo_curso = tc.id_tipo_curso INNER JOIN oferta_semestral os ON c.id_oferta_semestral = os.id_oferta_semestral INNER JOIN periodo_academico pa ON os.id_periodo = pa.id_periodo INNER JOIN nivel_semestre ns ON os.id_nivel_semestre = ns.id_nivel_semestre ORDER BY c.id_curso;`;
    const result = await pool.query(query);
    return result.rows;
  },
  getById: async (id) => {
    const query = `SELECT c.id_curso, c.cupo_maximo, c.inscritos_actual, a.clave_asignatura, a.nombre AS nombre_asignatura, p.id_profesor, CONCAT(p.nombre, ' ', p.apellido_paterno, ' ', p.apellido_materno) AS nombre_profesor, g.nombre_grupo, tc.nombre_tipo AS tipo_curso, pa.periodo_nombre AS periodo, ns.nombre_semestre AS semestre FROM curso c INNER JOIN asignatura a ON c.clave_asignatura = a.clave_asignatura INNER JOIN profesor p ON c.id_profesor = p.id_profesor INNER JOIN grupo g ON c.id_grupo = g.id_grupo INNER JOIN tipo_curso tc ON c.id_tipo_curso = tc.id_tipo_curso INNER JOIN oferta_semestral os ON c.id_oferta_semestral = os.id_oferta_semestral INNER JOIN periodo_academico pa ON os.id_periodo = pa.id_periodo INNER JOIN nivel_semestre ns ON os.id_nivel_semestre = ns.id_nivel_semestre WHERE c.id_curso = $1;`;
    const result = await pool.query(query, [id]);
    return result.rows[0];
  },
};
module.exports = CursoModel;
