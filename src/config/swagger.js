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
