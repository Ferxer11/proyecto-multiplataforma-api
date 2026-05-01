// ============================================
// SERVIDOR PRINCIPAL
// Punto de entrada de la aplicación
// ============================================

const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

// Importar rutas
const alumnoRoutes = require('./src/routes/alumno.routes');
const profesorRoutes = require('./src/routes/profesor.routes');
const asignaturaRoutes = require('./src/routes/asignatura.routes');
const cursoRoutes = require('./src/routes/curso.routes');
const alumnoCursoRoutes = require('./src/routes/alumnoCurso.routes');

const app = express();
const PORT = process.env.PORT || 3000;

// ============================================
// MIDDLEWARES
// ============================================
app.use(cors());                              // Permite peticiones desde cualquier origen
app.use(express.json());                      // Parsea JSON en el body de las peticiones
app.use(express.urlencoded({ extended: true })); // Parsea formularios

// Servir archivos estáticos del frontend (HTML, CSS, JS)
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.static(path.join(__dirname, 'src/views')));

// ============================================
// RUTAS DEL API
// ============================================
app.use('/api/alumnos', alumnoRoutes);
app.use('/api/profesores', profesorRoutes);
app.use('/api/asignaturas', asignaturaRoutes);
app.use('/api/cursos', cursoRoutes);
app.use('/api/inscripciones', alumnoCursoRoutes);

// Ruta principal - sirve el index.html
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'src/views/index.html'));
});

// Endpoint de prueba para verificar que el API está vivo
app.get('/api', (req, res) => {
  res.json({
    success: true,
    message: '✅ API Proyecto Multiplataforma funcionando correctamente',
    version: '1.0.0',
    endpoints: {
      alumnos: '/api/alumnos',
      profesores: '/api/profesores',
      asignaturas: '/api/asignaturas',
      cursos: '/api/cursos',
      inscripciones: '/api/inscripciones',
    },
  });
});

// Manejador de rutas no encontradas (404)
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Ruta no encontrada: ${req.method} ${req.originalUrl}`,
  });
});

// ============================================
// INICIAR SERVIDOR
// ============================================
app.listen(PORT, () => {
  console.log('========================================');
  console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
  console.log(`🌐 Frontend: http://localhost:${PORT}`);
  console.log(`📡 API:      http://localhost:${PORT}/api`);
  console.log('========================================');
});
