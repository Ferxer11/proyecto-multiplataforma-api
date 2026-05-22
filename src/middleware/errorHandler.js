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
