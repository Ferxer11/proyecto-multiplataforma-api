#!/bin/bash
# ============================================================================
# SETUP AUTOMÁTICO - SEGUNDA ENTREGA
# Equipo Los Flojos - Proyecto Multiplataforma
#
# Este script:
#   1. Instala las nuevas dependencias (express-validator, swagger)
#   2. Crea/sobrescribe los archivos del backend con la lógica CRUD
#   3. Crea los formularios HTML con tabs (Crear/Editar/Eliminar)
#   4. Crea los JS de frontend que llaman a la API
#
# EJECUTAR DESDE LA RAÍZ DEL PROYECTO:
#   cd ~/Documents/ProyectoMultiplataforma
#   bash setup-2da-entrega.sh
# ============================================================================

set -e  # Si algo falla, detener el script

echo ""
echo "🚀 SEGUNDA ENTREGA - Proyecto Multiplataforma"
echo "=============================================="
echo ""

# ---------- 0. Verificar que estamos en el proyecto ----------
if [ ! -f "server.js" ] || [ ! -d "src" ]; then
  echo "❌ No estás en la raíz del proyecto. Asegúrate de ejecutar este script desde la carpeta que contiene server.js y src/"
  exit 1
fi

# ---------- 1. Instalar dependencias ----------
echo "📦 Instalando dependencias nuevas (express-validator, swagger-ui-express, swagger-jsdoc)..."
npm install express-validator swagger-ui-express swagger-jsdoc --silent

echo "✅ Dependencias instaladas"
echo ""

# ---------- 2. Crear estructura nueva ----------
mkdir -p src/middleware src/config src/views public/js public/css

echo "📁 Estructura de carpetas verificada"
echo ""

# ============================================================================
# MIDDLEWARE: errorHandler.js
# ============================================================================
cat > src/middleware/errorHandler.js << 'EOF'
// ============================================
// MIDDLEWARE: Manejo centralizado de errores
// Traduce errores de PostgreSQL a respuestas HTTP claras
// ============================================

const errorHandler = (err, req, res, next) => {
  console.error('❌ Error capturado:', err.message);
  if (err.detail) console.error('   Detalle:', err.detail);

  // 23505 = violación de UNIQUE (registro duplicado)
  if (err.code === '23505') {
    return res.status(409).json({
      success: false,
      error: 'Registro duplicado',
      message: 'Ya existe un registro con esa clave única',
      detalle: err.detail || null,
    });
  }

  // 23503 = violación de FOREIGN KEY
  if (err.code === '23503') {
    return res.status(400).json({
      success: false,
      error: 'Referencia inválida',
      message: 'El valor referencia un registro que no existe en otra tabla',
      detalle: err.detail || null,
    });
  }

  // 23502 = violación de NOT NULL
  if (err.code === '23502') {
    return res.status(400).json({
      success: false,
      error: 'Campo requerido faltante',
      message: err.column
        ? `El campo "${err.column}" no puede ser nulo`
        : 'Hay campos requeridos sin valor',
    });
  }

  // 22P02 = formato inválido (ej. mandar texto donde se espera entero)
  if (err.code === '22P02') {
    return res.status(400).json({
      success: false,
      error: 'Formato inválido',
      message: 'Uno de los valores enviados tiene un tipo de dato incorrecto',
    });
  }

  // Cualquier otro error
  res.status(500).json({
    success: false,
    error: 'Error interno del servidor',
    message: err.message,
  });
};

// Middleware para rutas no encontradas (404)
const notFoundHandler = (req, res) => {
  res.status(404).json({
    success: false,
    error: 'Ruta no encontrada',
    message: `${req.method} ${req.originalUrl} no existe en este API`,
  });
};

module.exports = { errorHandler, notFoundHandler };
EOF

# ============================================================================
# MIDDLEWARE: validators.js
# ============================================================================
cat > src/middleware/validators.js << 'EOF'
// ============================================
// MIDDLEWARE: Validadores con express-validator
// Define las reglas de validación para cada tabla
// ============================================

const { body, param, validationResult } = require('express-validator');

// Helper que ejecuta las validaciones y devuelve los errores en formato uniforme
const handleValidation = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      error: 'Validación fallida',
      errores: errors.array().map((e) => ({
        campo: e.path,
        valor: e.value,
        mensaje: e.msg,
      })),
    });
  }
  next();
};

// ---------- ALUMNO ----------
const alumnoValidator = [
  body('numero_cuenta')
    .isInt({ min: 100000000, max: 999999999 })
    .withMessage('numero_cuenta debe ser un entero de 9 dígitos'),
  body('nombre')
    .isString().trim().notEmpty()
    .withMessage('nombre es requerido')
    .isLength({ max: 50 }).withMessage('nombre no puede pasar de 50 caracteres'),
  body('apellido_paterno')
    .isString().trim().notEmpty()
    .withMessage('apellido_paterno es requerido')
    .isLength({ max: 50 }),
  body('apellido_materno')
    .optional({ checkFalsy: true })
    .isString().trim().isLength({ max: 50 }),
  body('curp')
    .isString().trim()
    .isLength({ min: 18, max: 18 })
    .withMessage('CURP debe tener exactamente 18 caracteres')
    .matches(/^[A-Z0-9]{18}$/)
    .withMessage('CURP debe ser alfanumérico en mayúsculas'),
  body('telefono')
    .optional({ checkFalsy: true })
    .matches(/^[0-9]{10}$/)
    .withMessage('telefono debe tener 10 dígitos'),
  body('sexo')
    .isIn(['M', 'F', 'H'])
    .withMessage('sexo debe ser M, F o H'),
  body('correo_electronico')
    .isEmail().withMessage('correo_electronico no tiene formato válido')
    .normalizeEmail(),
  body('fecha_nacimiento')
    .isISO8601().withMessage('fecha_nacimiento debe estar en formato YYYY-MM-DD'),
  body('id_entidad')
    .isInt({ min: 1, max: 32 })
    .withMessage('id_entidad debe ser un entero entre 1 y 32'),
  handleValidation,
];

const alumnoUpdateValidator = [
  param('numero_cuenta').isInt().withMessage('numero_cuenta inválido en la URL'),
  ...alumnoValidator.slice(0, -1), // todas menos handleValidation
  handleValidation,
];

const alumnoIdValidator = [
  param('numero_cuenta').isInt().withMessage('numero_cuenta inválido'),
  handleValidation,
];

// ---------- PROFESOR ----------
const profesorValidator = [
  body('nombre').isString().trim().notEmpty().isLength({ max: 50 }),
  body('apellido_paterno').isString().trim().notEmpty().isLength({ max: 50 }),
  body('apellido_materno').optional({ checkFalsy: true }).isString().trim().isLength({ max: 50 }),
  body('curp')
    .isString().trim()
    .isLength({ min: 18, max: 18 })
    .withMessage('CURP debe tener 18 caracteres'),
  body('rfc')
    .isString().trim()
    .isLength({ min: 12, max: 13 })
    .withMessage('RFC debe tener 12 o 13 caracteres'),
  body('telefono').optional({ checkFalsy: true }).matches(/^[0-9]{10}$/),
  body('sexo').isIn(['M', 'F', 'H']),
  body('correo_electronico').isEmail().normalizeEmail(),
  body('fecha_nacimiento').isISO8601(),
  body('sueldo')
    .isFloat({ min: 0 })
    .withMessage('sueldo debe ser un número positivo'),
  handleValidation,
];

const profesorIdValidator = [
  param('id_profesor').isInt({ min: 1 }).withMessage('id_profesor inválido'),
  handleValidation,
];

const profesorUpdateValidator = [
  param('id_profesor').isInt({ min: 1 }),
  ...profesorValidator.slice(0, -1),
  handleValidation,
];

// ---------- ASIGNATURA (Materia) ----------
const asignaturaValidator = [
  body('clave_asignatura')
    .isString().trim().notEmpty()
    .withMessage('clave_asignatura es requerida')
    .isLength({ min: 2, max: 10 })
    .withMessage('clave_asignatura debe tener entre 2 y 10 caracteres')
    .matches(/^[A-Z0-9]+$/)
    .withMessage('clave_asignatura debe ser alfanumérico en mayúsculas'),
  body('nombre')
    .isString().trim().notEmpty()
    .withMessage('nombre es requerido')
    .isLength({ max: 100 }),
  handleValidation,
];

const asignaturaIdValidator = [
  param('clave_asignatura').isString().trim().notEmpty(),
  handleValidation,
];

const asignaturaUpdateValidator = [
  param('clave_asignatura').isString().trim().notEmpty(),
  body('nombre').isString().trim().notEmpty().isLength({ max: 100 }),
  handleValidation,
];

module.exports = {
  alumnoValidator,
  alumnoUpdateValidator,
  alumnoIdValidator,
  profesorValidator,
  profesorUpdateValidator,
  profesorIdValidator,
  asignaturaValidator,
  asignaturaUpdateValidator,
  asignaturaIdValidator,
};
EOF

# ============================================================================
# SWAGGER CONFIG
# ============================================================================
cat > src/config/swagger.js << 'EOF'
// ============================================
// CONFIGURACIÓN DE SWAGGER
// Genera documentación interactiva a partir de los comentarios JSDoc
// en las rutas. Se accede en http://localhost:3000/api-docs
// ============================================

const swaggerJsdoc = require('swagger-jsdoc');
const path = require('path');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'API Proyecto Multiplataforma - Equipo Los Flojos',
      version: '2.0.0',
      description:
        'API REST para gestión escolar. Segunda entrega: operaciones CRUD ' +
        'sobre las tablas Alumno, Profesor y Materia (Asignatura).',
      contact: { name: 'Equipo Los Flojos - FCA UNAM' },
    },
    servers: [
      { url: 'http://localhost:3000', description: 'Servidor local de desarrollo' },
    ],
    components: {
      schemas: {
        Alumno: {
          type: 'object',
          required: [
            'numero_cuenta','nombre','apellido_paterno','curp',
            'sexo','correo_electronico','fecha_nacimiento','id_entidad',
          ],
          properties: {
            numero_cuenta: { type: 'integer', example: 420123456 },
            nombre: { type: 'string', example: 'Juan' },
            apellido_paterno: { type: 'string', example: 'Pérez' },
            apellido_materno: { type: 'string', example: 'López' },
            curp: { type: 'string', example: 'PELJ010203HDFRPN09' },
            telefono: { type: 'string', example: '5512345678' },
            sexo: { type: 'string', enum: ['M', 'F', 'H'], example: 'H' },
            correo_electronico: { type: 'string', format: 'email', example: 'juan@unam.mx' },
            fecha_nacimiento: { type: 'string', format: 'date', example: '2001-02-03' },
            id_entidad: { type: 'integer', example: 9 },
          },
        },
        Profesor: {
          type: 'object',
          required: [
            'nombre','apellido_paterno','curp','rfc','sexo',
            'correo_electronico','fecha_nacimiento','sueldo',
          ],
          properties: {
            id_profesor: { type: 'integer', readOnly: true, example: 1 },
            nombre: { type: 'string', example: 'María' },
            apellido_paterno: { type: 'string', example: 'García' },
            apellido_materno: { type: 'string', example: 'Hernández' },
            curp: { type: 'string', example: 'GAHM800101MDFRRR00' },
            rfc: { type: 'string', example: 'GAHM800101AB1' },
            telefono: { type: 'string', example: '5598765432' },
            sexo: { type: 'string', enum: ['M', 'F', 'H'], example: 'M' },
            correo_electronico: { type: 'string', format: 'email' },
            fecha_nacimiento: { type: 'string', format: 'date' },
            sueldo: { type: 'number', format: 'float', example: 25000.50 },
          },
        },
        Asignatura: {
          type: 'object',
          required: ['clave_asignatura', 'nombre'],
          properties: {
            clave_asignatura: { type: 'string', example: 'MAT101' },
            nombre: { type: 'string', example: 'Cálculo Diferencial' },
          },
        },
        Error: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            error: { type: 'string' },
            message: { type: 'string' },
          },
        },
      },
    },
  },
  apis: [path.join(__dirname, '../routes/*.js')],
};

const swaggerSpec = swaggerJsdoc(options);

module.exports = swaggerSpec;
EOF

# ============================================================================
# MODELS - sobrescritos con CRUD completo
# ============================================================================
cat > src/models/alumno.model.js << 'EOF'
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
EOF

cat > src/models/profesor.model.js << 'EOF'
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
EOF

cat > src/models/asignatura.model.js << 'EOF'
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
EOF

echo "✅ Modelos actualizados (CRUD completo)"

# ============================================================================
# CONTROLLERS - con manejo de errores via next(err)
# ============================================================================
cat > src/controllers/alumno.controller.js << 'EOF'
// ============================================
// CONTROLLER: Alumno
// ============================================

const AlumnoModel = require('../models/alumno.model');

const AlumnoController = {
  getAll: async (req, res, next) => {
    try {
      const data = await AlumnoModel.getAll();
      res.json({ success: true, total: data.length, data });
    } catch (err) { next(err); }
  },

  getById: async (req, res, next) => {
    try {
      const data = await AlumnoModel.getById(req.params.numero_cuenta);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe alumno con numero_cuenta ${req.params.numero_cuenta}`,
        });
      }
      res.json({ success: true, data });
    } catch (err) { next(err); }
  },

  create: async (req, res, next) => {
    try {
      const data = await AlumnoModel.create(req.body);
      res.status(201).json({
        success: true,
        message: 'Alumno creado correctamente',
        data,
      });
    } catch (err) { next(err); }
  },

  update: async (req, res, next) => {
    try {
      const data = await AlumnoModel.update(req.params.numero_cuenta, req.body);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe alumno con numero_cuenta ${req.params.numero_cuenta}`,
        });
      }
      res.json({ success: true, message: 'Alumno actualizado correctamente', data });
    } catch (err) { next(err); }
  },

  delete: async (req, res, next) => {
    try {
      const data = await AlumnoModel.delete(req.params.numero_cuenta);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe alumno con numero_cuenta ${req.params.numero_cuenta}`,
        });
      }
      res.json({ success: true, message: 'Alumno eliminado correctamente', data });
    } catch (err) { next(err); }
  },
};

module.exports = AlumnoController;
EOF

cat > src/controllers/profesor.controller.js << 'EOF'
// ============================================
// CONTROLLER: Profesor
// ============================================

const ProfesorModel = require('../models/profesor.model');

const ProfesorController = {
  getAll: async (req, res, next) => {
    try {
      const data = await ProfesorModel.getAll();
      res.json({ success: true, total: data.length, data });
    } catch (err) { next(err); }
  },

  getById: async (req, res, next) => {
    try {
      const data = await ProfesorModel.getById(req.params.id_profesor);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe profesor con id ${req.params.id_profesor}`,
        });
      }
      res.json({ success: true, data });
    } catch (err) { next(err); }
  },

  create: async (req, res, next) => {
    try {
      const data = await ProfesorModel.create(req.body);
      res.status(201).json({
        success: true, message: 'Profesor creado correctamente', data,
      });
    } catch (err) { next(err); }
  },

  update: async (req, res, next) => {
    try {
      const data = await ProfesorModel.update(req.params.id_profesor, req.body);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe profesor con id ${req.params.id_profesor}`,
        });
      }
      res.json({ success: true, message: 'Profesor actualizado correctamente', data });
    } catch (err) { next(err); }
  },

  delete: async (req, res, next) => {
    try {
      const data = await ProfesorModel.delete(req.params.id_profesor);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe profesor con id ${req.params.id_profesor}`,
        });
      }
      res.json({ success: true, message: 'Profesor eliminado correctamente', data });
    } catch (err) { next(err); }
  },
};

module.exports = ProfesorController;
EOF

cat > src/controllers/asignatura.controller.js << 'EOF'
// ============================================
// CONTROLLER: Asignatura (Materia)
// ============================================

const AsignaturaModel = require('../models/asignatura.model');

const AsignaturaController = {
  getAll: async (req, res, next) => {
    try {
      const data = await AsignaturaModel.getAll();
      res.json({ success: true, total: data.length, data });
    } catch (err) { next(err); }
  },

  getById: async (req, res, next) => {
    try {
      const data = await AsignaturaModel.getById(req.params.clave_asignatura);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe asignatura con clave ${req.params.clave_asignatura}`,
        });
      }
      res.json({ success: true, data });
    } catch (err) { next(err); }
  },

  create: async (req, res, next) => {
    try {
      const data = await AsignaturaModel.create(req.body);
      res.status(201).json({
        success: true, message: 'Materia creada correctamente', data,
      });
    } catch (err) { next(err); }
  },

  update: async (req, res, next) => {
    try {
      const data = await AsignaturaModel.update(req.params.clave_asignatura, req.body);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe asignatura con clave ${req.params.clave_asignatura}`,
        });
      }
      res.json({ success: true, message: 'Materia actualizada correctamente', data });
    } catch (err) { next(err); }
  },

  delete: async (req, res, next) => {
    try {
      const data = await AsignaturaModel.delete(req.params.clave_asignatura);
      if (!data) {
        return res.status(404).json({
          success: false, error: 'No encontrado',
          message: `No existe asignatura con clave ${req.params.clave_asignatura}`,
        });
      }
      res.json({ success: true, message: 'Materia eliminada correctamente', data });
    } catch (err) { next(err); }
  },
};

module.exports = AsignaturaController;
EOF

echo "✅ Controllers actualizados (con manejo de errores)"

# ============================================================================
# ROUTES - con anotaciones Swagger JSDoc
# ============================================================================
cat > src/routes/alumno.routes.js << 'EOF'
// ============================================
// RUTAS: Alumno
// ============================================

const express = require('express');
const router = express.Router();
const AlumnoController = require('../controllers/alumno.controller');
const {
  alumnoValidator, alumnoUpdateValidator, alumnoIdValidator,
} = require('../middleware/validators');

/**
 * @swagger
 * tags:
 *   name: Alumnos
 *   description: Gestión de alumnos (tabla obligatoria)
 */

/**
 * @swagger
 * /api/alumnos:
 *   get:
 *     summary: Lista todos los alumnos
 *     tags: [Alumnos]
 *     responses:
 *       200:
 *         description: Lista obtenida correctamente
 */
router.get('/', AlumnoController.getAll);

/**
 * @swagger
 * /api/alumnos/{numero_cuenta}:
 *   get:
 *     summary: Obtiene un alumno por número de cuenta
 *     tags: [Alumnos]
 *     parameters:
 *       - in: path
 *         name: numero_cuenta
 *         required: true
 *         schema: { type: integer }
 *     responses:
 *       200: { description: Alumno encontrado }
 *       404: { description: No existe }
 */
router.get('/:numero_cuenta', alumnoIdValidator, AlumnoController.getById);

/**
 * @swagger
 * /api/alumnos:
 *   post:
 *     summary: Crea un nuevo alumno
 *     tags: [Alumnos]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema: { $ref: '#/components/schemas/Alumno' }
 *     responses:
 *       201: { description: Alumno creado }
 *       400: { description: Validación fallida }
 *       409: { description: Número de cuenta ya existe }
 */
router.post('/', alumnoValidator, AlumnoController.create);

/**
 * @swagger
 * /api/alumnos/{numero_cuenta}:
 *   put:
 *     summary: Actualiza un alumno existente
 *     tags: [Alumnos]
 *     parameters:
 *       - in: path
 *         name: numero_cuenta
 *         required: true
 *         schema: { type: integer }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema: { $ref: '#/components/schemas/Alumno' }
 *     responses:
 *       200: { description: Actualizado }
 *       400: { description: Validación fallida }
 *       404: { description: No existe }
 */
router.put('/:numero_cuenta', alumnoUpdateValidator, AlumnoController.update);

/**
 * @swagger
 * /api/alumnos/{numero_cuenta}:
 *   delete:
 *     summary: Elimina un alumno
 *     tags: [Alumnos]
 *     parameters:
 *       - in: path
 *         name: numero_cuenta
 *         required: true
 *         schema: { type: integer }
 *     responses:
 *       200: { description: Eliminado }
 *       404: { description: No existe }
 */
router.delete('/:numero_cuenta', alumnoIdValidator, AlumnoController.delete);

module.exports = router;
EOF

cat > src/routes/profesor.routes.js << 'EOF'
// ============================================
// RUTAS: Profesor
// ============================================

const express = require('express');
const router = express.Router();
const ProfesorController = require('../controllers/profesor.controller');
const {
  profesorValidator, profesorUpdateValidator, profesorIdValidator,
} = require('../middleware/validators');

/**
 * @swagger
 * tags:
 *   name: Profesores
 *   description: Gestión de profesores (tabla obligatoria)
 */

/**
 * @swagger
 * /api/profesores:
 *   get:
 *     summary: Lista todos los profesores
 *     tags: [Profesores]
 *     responses:
 *       200: { description: OK }
 */
router.get('/', ProfesorController.getAll);

/**
 * @swagger
 * /api/profesores/{id_profesor}:
 *   get:
 *     summary: Obtiene un profesor por ID
 *     tags: [Profesores]
 *     parameters:
 *       - in: path
 *         name: id_profesor
 *         required: true
 *         schema: { type: integer }
 *     responses:
 *       200: { description: OK }
 *       404: { description: No existe }
 */
router.get('/:id_profesor', profesorIdValidator, ProfesorController.getById);

/**
 * @swagger
 * /api/profesores:
 *   post:
 *     summary: Crea un nuevo profesor
 *     tags: [Profesores]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema: { $ref: '#/components/schemas/Profesor' }
 *     responses:
 *       201: { description: Creado }
 *       400: { description: Validación fallida }
 */
router.post('/', profesorValidator, ProfesorController.create);

/**
 * @swagger
 * /api/profesores/{id_profesor}:
 *   put:
 *     summary: Actualiza un profesor existente
 *     tags: [Profesores]
 *     parameters:
 *       - in: path
 *         name: id_profesor
 *         required: true
 *         schema: { type: integer }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema: { $ref: '#/components/schemas/Profesor' }
 *     responses:
 *       200: { description: Actualizado }
 *       400: { description: Validación fallida }
 *       404: { description: No existe }
 */
router.put('/:id_profesor', profesorUpdateValidator, ProfesorController.update);

/**
 * @swagger
 * /api/profesores/{id_profesor}:
 *   delete:
 *     summary: Elimina un profesor
 *     tags: [Profesores]
 *     parameters:
 *       - in: path
 *         name: id_profesor
 *         required: true
 *         schema: { type: integer }
 *     responses:
 *       200: { description: Eliminado }
 *       404: { description: No existe }
 */
router.delete('/:id_profesor', profesorIdValidator, ProfesorController.delete);

module.exports = router;
EOF

cat > src/routes/asignatura.routes.js << 'EOF'
// ============================================
// RUTAS: Asignatura (Materia)
// ============================================

const express = require('express');
const router = express.Router();
const AsignaturaController = require('../controllers/asignatura.controller');
const {
  asignaturaValidator, asignaturaUpdateValidator, asignaturaIdValidator,
} = require('../middleware/validators');

/**
 * @swagger
 * tags:
 *   name: Materias
 *   description: Gestión de materias / asignaturas
 */

/**
 * @swagger
 * /api/asignaturas:
 *   get:
 *     summary: Lista todas las materias
 *     tags: [Materias]
 *     responses:
 *       200: { description: OK }
 */
router.get('/', AsignaturaController.getAll);

/**
 * @swagger
 * /api/asignaturas/{clave_asignatura}:
 *   get:
 *     summary: Obtiene una materia por su clave
 *     tags: [Materias]
 *     parameters:
 *       - in: path
 *         name: clave_asignatura
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200: { description: OK }
 *       404: { description: No existe }
 */
router.get('/:clave_asignatura', asignaturaIdValidator, AsignaturaController.getById);

/**
 * @swagger
 * /api/asignaturas:
 *   post:
 *     summary: Crea una nueva materia
 *     tags: [Materias]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema: { $ref: '#/components/schemas/Asignatura' }
 *     responses:
 *       201: { description: Creada }
 *       400: { description: Validación fallida }
 *       409: { description: Clave duplicada }
 */
router.post('/', asignaturaValidator, AsignaturaController.create);

/**
 * @swagger
 * /api/asignaturas/{clave_asignatura}:
 *   put:
 *     summary: Actualiza el nombre de una materia
 *     tags: [Materias]
 *     parameters:
 *       - in: path
 *         name: clave_asignatura
 *         required: true
 *         schema: { type: string }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema: { $ref: '#/components/schemas/Asignatura' }
 *     responses:
 *       200: { description: Actualizada }
 *       404: { description: No existe }
 */
router.put('/:clave_asignatura', asignaturaUpdateValidator, AsignaturaController.update);

/**
 * @swagger
 * /api/asignaturas/{clave_asignatura}:
 *   delete:
 *     summary: Elimina una materia
 *     tags: [Materias]
 *     parameters:
 *       - in: path
 *         name: clave_asignatura
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200: { description: Eliminada }
 *       404: { description: No existe }
 */
router.delete('/:clave_asignatura', asignaturaIdValidator, AsignaturaController.delete);

module.exports = router;
EOF

echo "✅ Rutas actualizadas (con Swagger)"

# ============================================================================
# SERVER.JS - actualizado con Swagger + manejo de errores
# ============================================================================
cat > server.js << 'EOF'
// ============================================
// SERVIDOR EXPRESS - Proyecto Multiplataforma
// Segunda entrega: CRUD + Swagger + Validaciones
// ============================================

const express = require('express');
const cors = require('cors');
const path = require('path');
const swaggerUi = require('swagger-ui-express');
require('dotenv').config();

// Routes
const alumnoRoutes = require('./src/routes/alumno.routes');
const profesorRoutes = require('./src/routes/profesor.routes');
const asignaturaRoutes = require('./src/routes/asignatura.routes');
const cursoRoutes = require('./src/routes/curso.routes');
const alumnoCursoRoutes = require('./src/routes/alumnoCurso.routes');

// Middleware
const { errorHandler, notFoundHandler } = require('./src/middleware/errorHandler');
const swaggerSpec = require('./src/config/swagger');

const app = express();
const PORT = process.env.PORT || 3000;

// ---------- Middleware base ----------
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.static(path.join(__dirname, 'src/views')));

// ---------- Swagger UI ----------
app.use(
  '/api-docs',
  swaggerUi.serve,
  swaggerUi.setup(swaggerSpec, {
    customSiteTitle: 'API Los Flojos - Documentación',
  })
);

// ---------- Rutas del API ----------
app.use('/api/alumnos', alumnoRoutes);
app.use('/api/profesores', profesorRoutes);
app.use('/api/asignaturas', asignaturaRoutes);
app.use('/api/cursos', cursoRoutes);
app.use('/api/inscripciones', alumnoCursoRoutes);

// ---------- Páginas de inicio ----------
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'src/views/index.html'));
});

app.get('/api', (req, res) => {
  res.json({
    success: true,
    message: '✅ API Proyecto Multiplataforma - Equipo Los Flojos (v2.0)',
    version: '2.0.0',
    endpoints: {
      alumnos: '/api/alumnos',
      profesores: '/api/profesores',
      asignaturas: '/api/asignaturas',
      cursos: '/api/cursos',
      inscripciones: '/api/inscripciones',
    },
    documentacion: '/api-docs',
    crud_frontend: {
      alumnos: '/alumno-crud.html',
      profesores: '/profesor-crud.html',
      materias: '/materia-crud.html',
    },
  });
});

// ---------- 404 + Error handler (al final) ----------
app.use(notFoundHandler);
app.use(errorHandler);

app.listen(PORT, () => {
  console.log('========================================');
  console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
  console.log(`🌐 Frontend:      http://localhost:${PORT}`);
  console.log(`📡 API:           http://localhost:${PORT}/api`);
  console.log(`📚 Swagger Docs:  http://localhost:${PORT}/api-docs`);
  console.log('========================================');
});
EOF

echo "✅ server.js actualizado"
echo ""

# ============================================================================
# VIEWS HTML - CRUD pages con tabs
# ============================================================================
echo "📄 Creando páginas CRUD..."

cat > src/views/alumno-crud.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>CRUD Alumnos - Los Flojos</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.datatables.net/1.13.7/css/dataTables.bootstrap5.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/css/styles.css">
  <style>
    body { background: #f4f6f8; }
    .navbar { background-color: #003f7d !important; }
    .nav-tabs .nav-link.active { background-color: #c69214; color: white; border-color: #c69214; }
    .nav-tabs .nav-link { color: #003f7d; }
    .btn-unam { background-color: #c69214; color: white; border: none; }
    .btn-unam:hover { background-color: #a87a10; color: white; }
    .card-header { background-color: #003f7d; color: white; }
  </style>
</head>
<body>
  <nav class="navbar navbar-dark">
    <div class="container">
      <a class="navbar-brand" href="/">🎓 Proyecto Multiplataforma - Los Flojos</a>
      <div>
        <a href="/alumno-crud.html" class="btn btn-warning btn-sm">Alumnos</a>
        <a href="/profesor-crud.html" class="btn btn-light btn-sm">Profesores</a>
        <a href="/materia-crud.html" class="btn btn-light btn-sm">Materias</a>
        <a href="/api-docs" class="btn btn-info btn-sm" target="_blank">📚 Swagger</a>
      </div>
    </div>
  </nav>

  <div class="container my-4">
    <h2>👨‍🎓 CRUD de Alumnos</h2>
    <p class="text-muted">Operaciones POST, PUT y DELETE sobre la tabla <code>alumno</code></p>

    <!-- Tabs -->
    <ul class="nav nav-tabs" role="tablist">
      <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab-listar">📋 Listar</button></li>
      <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-crear">➕ Crear</button></li>
      <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-editar">✏️ Editar</button></li>
      <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-eliminar">🗑️ Eliminar</button></li>
    </ul>

    <div class="tab-content border border-top-0 p-4 bg-white">
      <!-- LISTAR -->
      <div class="tab-pane fade show active" id="tab-listar">
        <table id="tabla-alumnos" class="table table-striped table-hover" style="width:100%">
          <thead>
            <tr>
              <th>Núm. Cuenta</th><th>Nombre</th><th>Ap. Paterno</th><th>Ap. Materno</th>
              <th>CURP</th><th>Correo</th><th>Entidad</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      </div>

      <!-- CREAR -->
      <div class="tab-pane fade" id="tab-crear">
        <form id="form-crear" novalidate>
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label">Número de Cuenta *</label>
              <input type="number" name="numero_cuenta" class="form-control" required min="100000000" max="999999999">
              <div class="form-text">9 dígitos</div>
            </div>
            <div class="col-md-4">
              <label class="form-label">Nombre *</label>
              <input type="text" name="nombre" class="form-control" required maxlength="50">
            </div>
            <div class="col-md-4">
              <label class="form-label">Apellido Paterno *</label>
              <input type="text" name="apellido_paterno" class="form-control" required maxlength="50">
            </div>
            <div class="col-md-4">
              <label class="form-label">Apellido Materno</label>
              <input type="text" name="apellido_materno" class="form-control" maxlength="50">
            </div>
            <div class="col-md-4">
              <label class="form-label">CURP *</label>
              <input type="text" name="curp" class="form-control" required minlength="18" maxlength="18" pattern="[A-Z0-9]{18}" style="text-transform:uppercase">
            </div>
            <div class="col-md-4">
              <label class="form-label">Teléfono</label>
              <input type="tel" name="telefono" class="form-control" pattern="[0-9]{10}">
            </div>
            <div class="col-md-3">
              <label class="form-label">Sexo *</label>
              <select name="sexo" class="form-select" required>
                <option value="">-- elegir --</option>
                <option value="H">Hombre</option>
                <option value="M">Mujer</option>
                <option value="F">F</option>
              </select>
            </div>
            <div class="col-md-5">
              <label class="form-label">Correo Electrónico *</label>
              <input type="email" name="correo_electronico" class="form-control" required>
            </div>
            <div class="col-md-4">
              <label class="form-label">Fecha Nacimiento *</label>
              <input type="date" name="fecha_nacimiento" class="form-control" required>
            </div>
            <div class="col-md-4">
              <label class="form-label">ID Entidad *</label>
              <input type="number" name="id_entidad" class="form-control" required min="1" max="32">
              <div class="form-text">1-32 (entidad federativa)</div>
            </div>
          </div>
          <button type="submit" class="btn btn-unam mt-3">➕ Crear Alumno</button>
          <div id="msg-crear" class="mt-3"></div>
        </form>
      </div>

      <!-- EDITAR -->
      <div class="tab-pane fade" id="tab-editar">
        <div class="row g-2 mb-3">
          <div class="col-md-4">
            <label class="form-label">Número de Cuenta a editar</label>
            <input type="number" id="buscar-editar-id" class="form-control" placeholder="Ej. 420123456">
          </div>
          <div class="col-md-2 d-flex align-items-end">
            <button id="btn-cargar-editar" class="btn btn-primary w-100">Cargar</button>
          </div>
        </div>
        <form id="form-editar" novalidate style="display:none;">
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label">Núm. Cuenta (no editable)</label>
              <input type="number" name="numero_cuenta" class="form-control" readonly>
            </div>
            <div class="col-md-4">
              <label class="form-label">Nombre *</label>
              <input type="text" name="nombre" class="form-control" required maxlength="50">
            </div>
            <div class="col-md-4">
              <label class="form-label">Apellido Paterno *</label>
              <input type="text" name="apellido_paterno" class="form-control" required maxlength="50">
            </div>
            <div class="col-md-4">
              <label class="form-label">Apellido Materno</label>
              <input type="text" name="apellido_materno" class="form-control" maxlength="50">
            </div>
            <div class="col-md-4">
              <label class="form-label">CURP *</label>
              <input type="text" name="curp" class="form-control" required minlength="18" maxlength="18">
            </div>
            <div class="col-md-4">
              <label class="form-label">Teléfono</label>
              <input type="tel" name="telefono" class="form-control" pattern="[0-9]{10}">
            </div>
            <div class="col-md-3">
              <label class="form-label">Sexo *</label>
              <select name="sexo" class="form-select" required>
                <option value="H">Hombre</option><option value="M">Mujer</option><option value="F">F</option>
              </select>
            </div>
            <div class="col-md-5">
              <label class="form-label">Correo *</label>
              <input type="email" name="correo_electronico" class="form-control" required>
            </div>
            <div class="col-md-4">
              <label class="form-label">Fecha Nac. *</label>
              <input type="date" name="fecha_nacimiento" class="form-control" required>
            </div>
            <div class="col-md-4">
              <label class="form-label">ID Entidad *</label>
              <input type="number" name="id_entidad" class="form-control" required min="1" max="32">
            </div>
          </div>
          <button type="submit" class="btn btn-unam mt-3">💾 Guardar Cambios</button>
          <div id="msg-editar" class="mt-3"></div>
        </form>
      </div>

      <!-- ELIMINAR -->
      <div class="tab-pane fade" id="tab-eliminar">
        <div class="row g-2 mb-3">
          <div class="col-md-4">
            <label class="form-label">Número de Cuenta a eliminar</label>
            <input type="number" id="buscar-eliminar-id" class="form-control">
          </div>
          <div class="col-md-2 d-flex align-items-end">
            <button id="btn-buscar-eliminar" class="btn btn-primary w-100">Buscar</button>
          </div>
        </div>
        <div id="info-eliminar" class="alert alert-info" style="display:none;"></div>
        <button id="btn-confirmar-eliminar" class="btn btn-danger" style="display:none;">🗑️ Confirmar Eliminación</button>
        <div id="msg-eliminar" class="mt-3"></div>
      </div>
    </div>
  </div>

  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
  <script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>
  <script src="/js/alumno-crud.js"></script>
</body>
</html>
EOF

cat > src/views/profesor-crud.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>CRUD Profesores - Los Flojos</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.datatables.net/1.13.7/css/dataTables.bootstrap5.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/css/styles.css">
  <style>
    body { background: #f4f6f8; }
    .navbar { background-color: #003f7d !important; }
    .nav-tabs .nav-link.active { background-color: #c69214; color: white; border-color: #c69214; }
    .nav-tabs .nav-link { color: #003f7d; }
    .btn-unam { background-color: #c69214; color: white; border: none; }
    .btn-unam:hover { background-color: #a87a10; color: white; }
  </style>
</head>
<body>
  <nav class="navbar navbar-dark">
    <div class="container">
      <a class="navbar-brand" href="/">🎓 Proyecto Multiplataforma - Los Flojos</a>
      <div>
        <a href="/alumno-crud.html" class="btn btn-light btn-sm">Alumnos</a>
        <a href="/profesor-crud.html" class="btn btn-warning btn-sm">Profesores</a>
        <a href="/materia-crud.html" class="btn btn-light btn-sm">Materias</a>
        <a href="/api-docs" class="btn btn-info btn-sm" target="_blank">📚 Swagger</a>
      </div>
    </div>
  </nav>

  <div class="container my-4">
    <h2>👨‍🏫 CRUD de Profesores</h2>
    <p class="text-muted">Operaciones POST, PUT y DELETE sobre la tabla <code>profesor</code></p>

    <ul class="nav nav-tabs" role="tablist">
      <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab-listar">📋 Listar</button></li>
      <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-crear">➕ Crear</button></li>
      <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-editar">✏️ Editar</button></li>
      <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-eliminar">🗑️ Eliminar</button></li>
    </ul>

    <div class="tab-content border border-top-0 p-4 bg-white">
      <div class="tab-pane fade show active" id="tab-listar">
        <table id="tabla-profesores" class="table table-striped table-hover" style="width:100%">
          <thead><tr><th>ID</th><th>Nombre</th><th>Ap. Paterno</th><th>Ap. Materno</th><th>RFC</th><th>Correo</th><th>Sueldo</th></tr></thead>
          <tbody></tbody>
        </table>
      </div>

      <div class="tab-pane fade" id="tab-crear">
        <form id="form-crear" novalidate>
          <div class="row g-3">
            <div class="col-md-4"><label class="form-label">Nombre *</label><input type="text" name="nombre" class="form-control" required maxlength="50"></div>
            <div class="col-md-4"><label class="form-label">Apellido Paterno *</label><input type="text" name="apellido_paterno" class="form-control" required maxlength="50"></div>
            <div class="col-md-4"><label class="form-label">Apellido Materno</label><input type="text" name="apellido_materno" class="form-control" maxlength="50"></div>
            <div class="col-md-4"><label class="form-label">CURP *</label><input type="text" name="curp" class="form-control" required minlength="18" maxlength="18" pattern="[A-Z0-9]{18}" style="text-transform:uppercase"></div>
            <div class="col-md-4"><label class="form-label">RFC *</label><input type="text" name="rfc" class="form-control" required minlength="12" maxlength="13" style="text-transform:uppercase"></div>
            <div class="col-md-4"><label class="form-label">Teléfono</label><input type="tel" name="telefono" class="form-control" pattern="[0-9]{10}"></div>
            <div class="col-md-3"><label class="form-label">Sexo *</label><select name="sexo" class="form-select" required><option value="">-- elegir --</option><option value="H">Hombre</option><option value="M">Mujer</option><option value="F">F</option></select></div>
            <div class="col-md-5"><label class="form-label">Correo Electrónico *</label><input type="email" name="correo_electronico" class="form-control" required></div>
            <div class="col-md-4"><label class="form-label">Fecha Nacimiento *</label><input type="date" name="fecha_nacimiento" class="form-control" required></div>
            <div class="col-md-4"><label class="form-label">Sueldo *</label><input type="number" step="0.01" min="0" name="sueldo" class="form-control" required></div>
          </div>
          <button type="submit" class="btn btn-unam mt-3">➕ Crear Profesor</button>
          <div id="msg-crear" class="mt-3"></div>
        </form>
      </div>

      <div class="tab-pane fade" id="tab-editar">
        <div class="row g-2 mb-3">
          <div class="col-md-4"><label class="form-label">ID de Profesor a editar</label><input type="number" id="buscar-editar-id" class="form-control"></div>
          <div class="col-md-2 d-flex align-items-end"><button id="btn-cargar-editar" class="btn btn-primary w-100">Cargar</button></div>
        </div>
        <form id="form-editar" novalidate style="display:none;">
          <div class="row g-3">
            <div class="col-md-4"><label class="form-label">ID (no editable)</label><input type="number" name="id_profesor" class="form-control" readonly></div>
            <div class="col-md-4"><label class="form-label">Nombre *</label><input type="text" name="nombre" class="form-control" required maxlength="50"></div>
            <div class="col-md-4"><label class="form-label">Apellido Paterno *</label><input type="text" name="apellido_paterno" class="form-control" required maxlength="50"></div>
            <div class="col-md-4"><label class="form-label">Apellido Materno</label><input type="text" name="apellido_materno" class="form-control" maxlength="50"></div>
            <div class="col-md-4"><label class="form-label">CURP *</label><input type="text" name="curp" class="form-control" required minlength="18" maxlength="18"></div>
            <div class="col-md-4"><label class="form-label">RFC *</label><input type="text" name="rfc" class="form-control" required minlength="12" maxlength="13"></div>
            <div class="col-md-4"><label class="form-label">Teléfono</label><input type="tel" name="telefono" class="form-control" pattern="[0-9]{10}"></div>
            <div class="col-md-3"><label class="form-label">Sexo *</label><select name="sexo" class="form-select" required><option value="H">Hombre</option><option value="M">Mujer</option><option value="F">F</option></select></div>
            <div class="col-md-5"><label class="form-label">Correo *</label><input type="email" name="correo_electronico" class="form-control" required></div>
            <div class="col-md-4"><label class="form-label">Fecha Nac. *</label><input type="date" name="fecha_nacimiento" class="form-control" required></div>
            <div class="col-md-4"><label class="form-label">Sueldo *</label><input type="number" step="0.01" min="0" name="sueldo" class="form-control" required></div>
          </div>
          <button type="submit" class="btn btn-unam mt-3">💾 Guardar Cambios</button>
          <div id="msg-editar" class="mt-3"></div>
        </form>
      </div>

      <div class="tab-pane fade" id="tab-eliminar">
        <div class="row g-2 mb-3">
          <div class="col-md-4"><label class="form-label">ID de Profesor a eliminar</label><input type="number" id="buscar-eliminar-id" class="form-control"></div>
          <div class="col-md-2 d-flex align-items-end"><button id="btn-buscar-eliminar" class="btn btn-primary w-100">Buscar</button></div>
        </div>
        <div id="info-eliminar" class="alert alert-info" style="display:none;"></div>
        <button id="btn-confirmar-eliminar" class="btn btn-danger" style="display:none;">🗑️ Confirmar Eliminación</button>
        <div id="msg-eliminar" class="mt-3"></div>
      </div>
    </div>
  </div>

  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
  <script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>
  <script src="/js/profesor-crud.js"></script>
</body>
</html>
EOF

cat > src/views/materia-crud.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>CRUD Materias - Los Flojos</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.datatables.net/1.13.7/css/dataTables.bootstrap5.min.css" rel="stylesheet">
  <link rel="stylesheet" href="/css/styles.css">
  <style>
    body { background: #f4f6f8; }
    .navbar { background-color: #003f7d !important; }
    .nav-tabs .nav-link.active { background-color: #c69214; color: white; border-color: #c69214; }
    .nav-tabs .nav-link { color: #003f7d; }
    .btn-unam { background-color: #c69214; color: white; border: none; }
    .btn-unam:hover { background-color: #a87a10; color: white; }
  </style>
</head>
<body>
  <nav class="navbar navbar-dark">
    <div class="container">
      <a class="navbar-brand" href="/">🎓 Proyecto Multiplataforma - Los Flojos</a>
      <div>
        <a href="/alumno-crud.html" class="btn btn-light btn-sm">Alumnos</a>
        <a href="/profesor-crud.html" class="btn btn-light btn-sm">Profesores</a>
        <a href="/materia-crud.html" class="btn btn-warning btn-sm">Materias</a>
        <a href="/api-docs" class="btn btn-info btn-sm" target="_blank">📚 Swagger</a>
      </div>
    </div>
  </nav>

  <div class="container my-4">
    <h2>📚 CRUD de Materias</h2>
    <p class="text-muted">Operaciones POST, PUT y DELETE sobre la tabla <code>asignatura</code></p>

    <ul class="nav nav-tabs" role="tablist">
      <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab-listar">📋 Listar</button></li>
      <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-crear">➕ Crear</button></li>
      <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-editar">✏️ Editar</button></li>
      <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-eliminar">🗑️ Eliminar</button></li>
    </ul>

    <div class="tab-content border border-top-0 p-4 bg-white">
      <div class="tab-pane fade show active" id="tab-listar">
        <table id="tabla-materias" class="table table-striped table-hover" style="width:100%">
          <thead><tr><th>Clave</th><th>Nombre</th></tr></thead>
          <tbody></tbody>
        </table>
      </div>

      <div class="tab-pane fade" id="tab-crear">
        <form id="form-crear" novalidate>
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label">Clave de Asignatura *</label>
              <input type="text" name="clave_asignatura" class="form-control" required minlength="2" maxlength="10" pattern="[A-Z0-9]+" style="text-transform:uppercase">
              <div class="form-text">Mayúsculas y números, 2-10 caracteres (ej. MAT101)</div>
            </div>
            <div class="col-md-8">
              <label class="form-label">Nombre de la Materia *</label>
              <input type="text" name="nombre" class="form-control" required maxlength="100">
            </div>
          </div>
          <button type="submit" class="btn btn-unam mt-3">➕ Crear Materia</button>
          <div id="msg-crear" class="mt-3"></div>
        </form>
      </div>

      <div class="tab-pane fade" id="tab-editar">
        <div class="row g-2 mb-3">
          <div class="col-md-4"><label class="form-label">Clave de la materia a editar</label><input type="text" id="buscar-editar-id" class="form-control" style="text-transform:uppercase"></div>
          <div class="col-md-2 d-flex align-items-end"><button id="btn-cargar-editar" class="btn btn-primary w-100">Cargar</button></div>
        </div>
        <form id="form-editar" novalidate style="display:none;">
          <div class="row g-3">
            <div class="col-md-4"><label class="form-label">Clave (no editable)</label><input type="text" name="clave_asignatura" class="form-control" readonly></div>
            <div class="col-md-8"><label class="form-label">Nombre *</label><input type="text" name="nombre" class="form-control" required maxlength="100"></div>
          </div>
          <button type="submit" class="btn btn-unam mt-3">💾 Guardar Cambios</button>
          <div id="msg-editar" class="mt-3"></div>
        </form>
      </div>

      <div class="tab-pane fade" id="tab-eliminar">
        <div class="row g-2 mb-3">
          <div class="col-md-4"><label class="form-label">Clave de la materia a eliminar</label><input type="text" id="buscar-eliminar-id" class="form-control" style="text-transform:uppercase"></div>
          <div class="col-md-2 d-flex align-items-end"><button id="btn-buscar-eliminar" class="btn btn-primary w-100">Buscar</button></div>
        </div>
        <div id="info-eliminar" class="alert alert-info" style="display:none;"></div>
        <button id="btn-confirmar-eliminar" class="btn btn-danger" style="display:none;">🗑️ Confirmar Eliminación</button>
        <div id="msg-eliminar" class="mt-3"></div>
      </div>
    </div>
  </div>

  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
  <script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
  <script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>
  <script src="/js/materia-crud.js"></script>
</body>
</html>
EOF

echo "✅ Páginas CRUD creadas"

# ============================================================================
# FRONTEND JS - Lógica de cada CRUD
# ============================================================================
echo "📜 Creando lógica JS frontend..."

cat > public/js/alumno-crud.js << 'EOF'
// ============================================
// FRONTEND: CRUD de Alumnos
// ============================================

const API = '/api/alumnos';
let dataTable;

// Helper para mostrar mensajes
function mostrarMsg(elemId, tipo, titulo, mensaje, extra) {
  const colores = { success: 'success', error: 'danger', info: 'info' };
  let html = `<div class="alert alert-${colores[tipo]}"><strong>${titulo}</strong> ${mensaje || ''}`;
  if (extra) html += `<pre class="mb-0 mt-2 small">${JSON.stringify(extra, null, 2)}</pre>`;
  html += '</div>';
  document.getElementById(elemId).innerHTML = html;
}

// Cargar lista
async function cargarLista() {
  try {
    const res = await fetch(API);
    const json = await res.json();
    if (dataTable) dataTable.destroy();
    const tbody = document.querySelector('#tabla-alumnos tbody');
    tbody.innerHTML = '';
    json.data.forEach(a => {
      const tr = document.createElement('tr');
      tr.innerHTML = `<td>${a.numero_cuenta}</td><td>${a.nombre}</td><td>${a.apellido_paterno}</td><td>${a.apellido_materno || ''}</td><td>${a.curp}</td><td>${a.correo_electronico}</td><td>${a.nombre_entidad}</td>`;
      tbody.appendChild(tr);
    });
    dataTable = $('#tabla-alumnos').DataTable({
      language: { url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/es-MX.json' },
      pageLength: 10,
    });
  } catch (e) {
    console.error(e);
  }
}

// CREAR
document.getElementById('form-crear').addEventListener('submit', async (e) => {
  e.preventDefault();
  const form = e.target;
  if (!form.checkValidity()) {
    form.classList.add('was-validated');
    mostrarMsg('msg-crear', 'error', '⚠️ Validación HTML5:', 'Revisa los campos marcados en rojo');
    return;
  }
  const data = Object.fromEntries(new FormData(form));
  data.numero_cuenta = parseInt(data.numero_cuenta);
  data.id_entidad = parseInt(data.id_entidad);
  data.curp = data.curp.toUpperCase();
  if (!data.telefono) delete data.telefono;
  if (!data.apellido_materno) delete data.apellido_materno;

  try {
    const res = await fetch(API, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    const json = await res.json();
    if (res.ok) {
      mostrarMsg('msg-crear', 'success', '✅ Éxito:', json.message, json.data);
      form.reset();
      form.classList.remove('was-validated');
      cargarLista();
    } else {
      mostrarMsg('msg-crear', 'error', '❌ Error:', json.message || json.error, json.errores || json.detalle);
    }
  } catch (e) {
    mostrarMsg('msg-crear', 'error', '❌ Error de red:', e.message);
  }
});

// EDITAR - Cargar
document.getElementById('btn-cargar-editar').addEventListener('click', async () => {
  const id = document.getElementById('buscar-editar-id').value;
  if (!id) return mostrarMsg('msg-editar', 'error', '⚠️', 'Captura un número de cuenta');
  try {
    const res = await fetch(`${API}/${id}`);
    const json = await res.json();
    if (!res.ok) return mostrarMsg('msg-editar', 'error', '❌', json.message);
    const form = document.getElementById('form-editar');
    form.style.display = 'block';
    Object.keys(json.data).forEach(k => {
      const input = form.elements[k];
      if (input) {
        if (k === 'fecha_nacimiento' && json.data[k]) {
          input.value = json.data[k].split('T')[0];
        } else {
          input.value = json.data[k] || '';
        }
      }
    });
    mostrarMsg('msg-editar', 'info', '📝', 'Datos cargados. Modifica y guarda.');
  } catch (e) {
    mostrarMsg('msg-editar', 'error', '❌ Error:', e.message);
  }
});

// EDITAR - Guardar
document.getElementById('form-editar').addEventListener('submit', async (e) => {
  e.preventDefault();
  const form = e.target;
  if (!form.checkValidity()) {
    form.classList.add('was-validated');
    return mostrarMsg('msg-editar', 'error', '⚠️ Validación HTML5:', 'Revisa los campos');
  }
  const data = Object.fromEntries(new FormData(form));
  const id = data.numero_cuenta;
  data.numero_cuenta = parseInt(data.numero_cuenta);
  data.id_entidad = parseInt(data.id_entidad);
  data.curp = data.curp.toUpperCase();
  if (!data.telefono) delete data.telefono;
  if (!data.apellido_materno) delete data.apellido_materno;

  try {
    const res = await fetch(`${API}/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    const json = await res.json();
    if (res.ok) {
      mostrarMsg('msg-editar', 'success', '✅ Éxito:', json.message, json.data);
      cargarLista();
    } else {
      mostrarMsg('msg-editar', 'error', '❌ Error:', json.message || json.error, json.errores || json.detalle);
    }
  } catch (e) {
    mostrarMsg('msg-editar', 'error', '❌ Error de red:', e.message);
  }
});

// ELIMINAR - Buscar
document.getElementById('btn-buscar-eliminar').addEventListener('click', async () => {
  const id = document.getElementById('buscar-eliminar-id').value;
  if (!id) return mostrarMsg('msg-eliminar', 'error', '⚠️', 'Captura un número de cuenta');
  try {
    const res = await fetch(`${API}/${id}`);
    const json = await res.json();
    if (!res.ok) {
      document.getElementById('info-eliminar').style.display = 'none';
      document.getElementById('btn-confirmar-eliminar').style.display = 'none';
      return mostrarMsg('msg-eliminar', 'error', '❌', json.message);
    }
    const a = json.data;
    document.getElementById('info-eliminar').innerHTML = `
      <strong>¿Eliminar este alumno?</strong><br>
      <strong>Núm. Cuenta:</strong> ${a.numero_cuenta}<br>
      <strong>Nombre:</strong> ${a.nombre} ${a.apellido_paterno} ${a.apellido_materno || ''}<br>
      <strong>Correo:</strong> ${a.correo_electronico}
    `;
    document.getElementById('info-eliminar').style.display = 'block';
    document.getElementById('btn-confirmar-eliminar').style.display = 'inline-block';
    document.getElementById('btn-confirmar-eliminar').dataset.id = id;
    document.getElementById('msg-eliminar').innerHTML = '';
  } catch (e) {
    mostrarMsg('msg-eliminar', 'error', '❌ Error:', e.message);
  }
});

// ELIMINAR - Confirmar
document.getElementById('btn-confirmar-eliminar').addEventListener('click', async (e) => {
  if (!confirm('¿Confirmas que deseas eliminar este alumno?')) return;
  const id = e.target.dataset.id;
  try {
    const res = await fetch(`${API}/${id}`, { method: 'DELETE' });
    const json = await res.json();
    if (res.ok) {
      mostrarMsg('msg-eliminar', 'success', '✅ Éxito:', json.message, json.data);
      document.getElementById('info-eliminar').style.display = 'none';
      document.getElementById('btn-confirmar-eliminar').style.display = 'none';
      document.getElementById('buscar-eliminar-id').value = '';
      cargarLista();
    } else {
      mostrarMsg('msg-eliminar', 'error', '❌ Error:', json.message || json.error, json.detalle);
    }
  } catch (e) {
    mostrarMsg('msg-eliminar', 'error', '❌ Error de red:', e.message);
  }
});

// Inicial
cargarLista();
EOF

cat > public/js/profesor-crud.js << 'EOF'
// ============================================
// FRONTEND: CRUD de Profesores
// ============================================

const API = '/api/profesores';
let dataTable;

function mostrarMsg(elemId, tipo, titulo, mensaje, extra) {
  const colores = { success: 'success', error: 'danger', info: 'info' };
  let html = `<div class="alert alert-${colores[tipo]}"><strong>${titulo}</strong> ${mensaje || ''}`;
  if (extra) html += `<pre class="mb-0 mt-2 small">${JSON.stringify(extra, null, 2)}</pre>`;
  html += '</div>';
  document.getElementById(elemId).innerHTML = html;
}

async function cargarLista() {
  try {
    const res = await fetch(API);
    const json = await res.json();
    if (dataTable) dataTable.destroy();
    const tbody = document.querySelector('#tabla-profesores tbody');
    tbody.innerHTML = '';
    json.data.forEach(p => {
      const tr = document.createElement('tr');
      tr.innerHTML = `<td>${p.id_profesor}</td><td>${p.nombre}</td><td>${p.apellido_paterno}</td><td>${p.apellido_materno || ''}</td><td>${p.rfc}</td><td>${p.correo_electronico}</td><td>$${parseFloat(p.sueldo).toFixed(2)}</td>`;
      tbody.appendChild(tr);
    });
    dataTable = $('#tabla-profesores').DataTable({
      language: { url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/es-MX.json' },
      pageLength: 10,
    });
  } catch (e) { console.error(e); }
}

document.getElementById('form-crear').addEventListener('submit', async (e) => {
  e.preventDefault();
  const form = e.target;
  if (!form.checkValidity()) {
    form.classList.add('was-validated');
    return mostrarMsg('msg-crear', 'error', '⚠️ Validación HTML5:', 'Revisa los campos');
  }
  const data = Object.fromEntries(new FormData(form));
  data.sueldo = parseFloat(data.sueldo);
  data.curp = data.curp.toUpperCase();
  data.rfc = data.rfc.toUpperCase();
  if (!data.telefono) delete data.telefono;
  if (!data.apellido_materno) delete data.apellido_materno;

  try {
    const res = await fetch(API, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    const json = await res.json();
    if (res.ok) {
      mostrarMsg('msg-crear', 'success', '✅ Éxito:', json.message, json.data);
      form.reset();
      form.classList.remove('was-validated');
      cargarLista();
    } else {
      mostrarMsg('msg-crear', 'error', '❌ Error:', json.message || json.error, json.errores || json.detalle);
    }
  } catch (e) {
    mostrarMsg('msg-crear', 'error', '❌ Error de red:', e.message);
  }
});

document.getElementById('btn-cargar-editar').addEventListener('click', async () => {
  const id = document.getElementById('buscar-editar-id').value;
  if (!id) return mostrarMsg('msg-editar', 'error', '⚠️', 'Captura un ID');
  try {
    const res = await fetch(`${API}/${id}`);
    const json = await res.json();
    if (!res.ok) return mostrarMsg('msg-editar', 'error', '❌', json.message);
    const form = document.getElementById('form-editar');
    form.style.display = 'block';
    Object.keys(json.data).forEach(k => {
      const input = form.elements[k];
      if (input) {
        if (k === 'fecha_nacimiento' && json.data[k]) input.value = json.data[k].split('T')[0];
        else input.value = json.data[k] != null ? json.data[k] : '';
      }
    });
    mostrarMsg('msg-editar', 'info', '📝', 'Datos cargados. Modifica y guarda.');
  } catch (e) {
    mostrarMsg('msg-editar', 'error', '❌ Error:', e.message);
  }
});

document.getElementById('form-editar').addEventListener('submit', async (e) => {
  e.preventDefault();
  const form = e.target;
  if (!form.checkValidity()) {
    form.classList.add('was-validated');
    return mostrarMsg('msg-editar', 'error', '⚠️ Validación HTML5:', 'Revisa los campos');
  }
  const data = Object.fromEntries(new FormData(form));
  const id = data.id_profesor;
  delete data.id_profesor;
  data.sueldo = parseFloat(data.sueldo);
  data.curp = data.curp.toUpperCase();
  data.rfc = data.rfc.toUpperCase();
  if (!data.telefono) delete data.telefono;
  if (!data.apellido_materno) delete data.apellido_materno;

  try {
    const res = await fetch(`${API}/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    const json = await res.json();
    if (res.ok) {
      mostrarMsg('msg-editar', 'success', '✅ Éxito:', json.message, json.data);
      cargarLista();
    } else {
      mostrarMsg('msg-editar', 'error', '❌ Error:', json.message || json.error, json.errores || json.detalle);
    }
  } catch (e) {
    mostrarMsg('msg-editar', 'error', '❌ Error de red:', e.message);
  }
});

document.getElementById('btn-buscar-eliminar').addEventListener('click', async () => {
  const id = document.getElementById('buscar-eliminar-id').value;
  if (!id) return mostrarMsg('msg-eliminar', 'error', '⚠️', 'Captura un ID');
  try {
    const res = await fetch(`${API}/${id}`);
    const json = await res.json();
    if (!res.ok) {
      document.getElementById('info-eliminar').style.display = 'none';
      document.getElementById('btn-confirmar-eliminar').style.display = 'none';
      return mostrarMsg('msg-eliminar', 'error', '❌', json.message);
    }
    const p = json.data;
    document.getElementById('info-eliminar').innerHTML = `
      <strong>¿Eliminar este profesor?</strong><br>
      <strong>ID:</strong> ${p.id_profesor}<br>
      <strong>Nombre:</strong> ${p.nombre} ${p.apellido_paterno} ${p.apellido_materno || ''}<br>
      <strong>RFC:</strong> ${p.rfc}
    `;
    document.getElementById('info-eliminar').style.display = 'block';
    document.getElementById('btn-confirmar-eliminar').style.display = 'inline-block';
    document.getElementById('btn-confirmar-eliminar').dataset.id = id;
    document.getElementById('msg-eliminar').innerHTML = '';
  } catch (e) {
    mostrarMsg('msg-eliminar', 'error', '❌ Error:', e.message);
  }
});

document.getElementById('btn-confirmar-eliminar').addEventListener('click', async (e) => {
  if (!confirm('¿Confirmas que deseas eliminar este profesor?')) return;
  const id = e.target.dataset.id;
  try {
    const res = await fetch(`${API}/${id}`, { method: 'DELETE' });
    const json = await res.json();
    if (res.ok) {
      mostrarMsg('msg-eliminar', 'success', '✅ Éxito:', json.message, json.data);
      document.getElementById('info-eliminar').style.display = 'none';
      document.getElementById('btn-confirmar-eliminar').style.display = 'none';
      document.getElementById('buscar-eliminar-id').value = '';
      cargarLista();
    } else {
      mostrarMsg('msg-eliminar', 'error', '❌ Error:', json.message || json.error, json.detalle);
    }
  } catch (e) {
    mostrarMsg('msg-eliminar', 'error', '❌ Error de red:', e.message);
  }
});

cargarLista();
EOF

cat > public/js/materia-crud.js << 'EOF'
// ============================================
// FRONTEND: CRUD de Materias
// ============================================

const API = '/api/asignaturas';
let dataTable;

function mostrarMsg(elemId, tipo, titulo, mensaje, extra) {
  const colores = { success: 'success', error: 'danger', info: 'info' };
  let html = `<div class="alert alert-${colores[tipo]}"><strong>${titulo}</strong> ${mensaje || ''}`;
  if (extra) html += `<pre class="mb-0 mt-2 small">${JSON.stringify(extra, null, 2)}</pre>`;
  html += '</div>';
  document.getElementById(elemId).innerHTML = html;
}

async function cargarLista() {
  try {
    const res = await fetch(API);
    const json = await res.json();
    if (dataTable) dataTable.destroy();
    const tbody = document.querySelector('#tabla-materias tbody');
    tbody.innerHTML = '';
    json.data.forEach(m => {
      const tr = document.createElement('tr');
      tr.innerHTML = `<td>${m.clave_asignatura}</td><td>${m.nombre}</td>`;
      tbody.appendChild(tr);
    });
    dataTable = $('#tabla-materias').DataTable({
      language: { url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/es-MX.json' },
      pageLength: 10,
    });
  } catch (e) { console.error(e); }
}

document.getElementById('form-crear').addEventListener('submit', async (e) => {
  e.preventDefault();
  const form = e.target;
  if (!form.checkValidity()) {
    form.classList.add('was-validated');
    return mostrarMsg('msg-crear', 'error', '⚠️ Validación HTML5:', 'Revisa los campos');
  }
  const data = Object.fromEntries(new FormData(form));
  data.clave_asignatura = data.clave_asignatura.toUpperCase();

  try {
    const res = await fetch(API, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    const json = await res.json();
    if (res.ok) {
      mostrarMsg('msg-crear', 'success', '✅ Éxito:', json.message, json.data);
      form.reset();
      form.classList.remove('was-validated');
      cargarLista();
    } else {
      mostrarMsg('msg-crear', 'error', '❌ Error:', json.message || json.error, json.errores || json.detalle);
    }
  } catch (e) {
    mostrarMsg('msg-crear', 'error', '❌ Error de red:', e.message);
  }
});

document.getElementById('btn-cargar-editar').addEventListener('click', async () => {
  const id = document.getElementById('buscar-editar-id').value.toUpperCase();
  if (!id) return mostrarMsg('msg-editar', 'error', '⚠️', 'Captura una clave');
  try {
    const res = await fetch(`${API}/${id}`);
    const json = await res.json();
    if (!res.ok) return mostrarMsg('msg-editar', 'error', '❌', json.message);
    const form = document.getElementById('form-editar');
    form.style.display = 'block';
    form.elements.clave_asignatura.value = json.data.clave_asignatura;
    form.elements.nombre.value = json.data.nombre;
    mostrarMsg('msg-editar', 'info', '📝', 'Datos cargados. Modifica el nombre y guarda.');
  } catch (e) {
    mostrarMsg('msg-editar', 'error', '❌ Error:', e.message);
  }
});

document.getElementById('form-editar').addEventListener('submit', async (e) => {
  e.preventDefault();
  const form = e.target;
  if (!form.checkValidity()) {
    form.classList.add('was-validated');
    return mostrarMsg('msg-editar', 'error', '⚠️ Validación HTML5:', 'Revisa los campos');
  }
  const data = Object.fromEntries(new FormData(form));
  const id = data.clave_asignatura;

  try {
    const res = await fetch(`${API}/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: data.nombre }),
    });
    const json = await res.json();
    if (res.ok) {
      mostrarMsg('msg-editar', 'success', '✅ Éxito:', json.message, json.data);
      cargarLista();
    } else {
      mostrarMsg('msg-editar', 'error', '❌ Error:', json.message || json.error, json.errores || json.detalle);
    }
  } catch (e) {
    mostrarMsg('msg-editar', 'error', '❌ Error de red:', e.message);
  }
});

document.getElementById('btn-buscar-eliminar').addEventListener('click', async () => {
  const id = document.getElementById('buscar-eliminar-id').value.toUpperCase();
  if (!id) return mostrarMsg('msg-eliminar', 'error', '⚠️', 'Captura una clave');
  try {
    const res = await fetch(`${API}/${id}`);
    const json = await res.json();
    if (!res.ok) {
      document.getElementById('info-eliminar').style.display = 'none';
      document.getElementById('btn-confirmar-eliminar').style.display = 'none';
      return mostrarMsg('msg-eliminar', 'error', '❌', json.message);
    }
    const m = json.data;
    document.getElementById('info-eliminar').innerHTML = `
      <strong>¿Eliminar esta materia?</strong><br>
      <strong>Clave:</strong> ${m.clave_asignatura}<br>
      <strong>Nombre:</strong> ${m.nombre}
    `;
    document.getElementById('info-eliminar').style.display = 'block';
    document.getElementById('btn-confirmar-eliminar').style.display = 'inline-block';
    document.getElementById('btn-confirmar-eliminar').dataset.id = id;
    document.getElementById('msg-eliminar').innerHTML = '';
  } catch (e) {
    mostrarMsg('msg-eliminar', 'error', '❌ Error:', e.message);
  }
});

document.getElementById('btn-confirmar-eliminar').addEventListener('click', async (e) => {
  if (!confirm('¿Confirmas eliminar esta materia? Si tiene cursos asociados fallará.')) return;
  const id = e.target.dataset.id;
  try {
    const res = await fetch(`${API}/${id}`, { method: 'DELETE' });
    const json = await res.json();
    if (res.ok) {
      mostrarMsg('msg-eliminar', 'success', '✅ Éxito:', json.message, json.data);
      document.getElementById('info-eliminar').style.display = 'none';
      document.getElementById('btn-confirmar-eliminar').style.display = 'none';
      document.getElementById('buscar-eliminar-id').value = '';
      cargarLista();
    } else {
      mostrarMsg('msg-eliminar', 'error', '❌ Error:', json.message || json.error, json.detalle);
    }
  } catch (e) {
    mostrarMsg('msg-eliminar', 'error', '❌ Error de red:', e.message);
  }
});

cargarLista();
EOF

echo "✅ Frontend JS creado"
echo ""

# ============================================================================
# RESUMEN FINAL
# ============================================================================
echo "========================================="
echo "🎉 SEGUNDA ENTREGA LISTA"
echo "========================================="
echo ""
echo "📂 Archivos modificados/creados:"
echo "   • src/middleware/errorHandler.js  (NUEVO)"
echo "   • src/middleware/validators.js    (NUEVO)"
echo "   • src/config/swagger.js           (NUEVO)"
echo "   • src/models/alumno.model.js      (CRUD)"
echo "   • src/models/profesor.model.js    (CRUD)"
echo "   • src/models/asignatura.model.js  (CRUD)"
echo "   • src/controllers/*.controller.js (CRUD)"
echo "   • src/routes/*.routes.js          (POST/PUT/DELETE + Swagger)"
echo "   • src/views/alumno-crud.html      (NUEVO)"
echo "   • src/views/profesor-crud.html    (NUEVO)"
echo "   • src/views/materia-crud.html     (NUEVO)"
echo "   • public/js/alumno-crud.js        (NUEVO)"
echo "   • public/js/profesor-crud.js      (NUEVO)"
echo "   • public/js/materia-crud.js       (NUEVO)"
echo "   • server.js                       (Swagger + errorHandler)"
echo ""
echo "🚀 Siguiente paso: arrancar el servidor"
echo "   node server.js"
echo ""
echo "📍 URLs a probar:"
echo "   • http://localhost:3000/alumno-crud.html"
echo "   • http://localhost:3000/profesor-crud.html"
echo "   • http://localhost:3000/materia-crud.html"
echo "   • http://localhost:3000/api-docs   (Swagger UI)"
echo ""
