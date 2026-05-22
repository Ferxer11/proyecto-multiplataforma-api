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
