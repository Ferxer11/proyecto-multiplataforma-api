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
