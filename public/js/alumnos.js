// ============================================
// JS: Página de Alumnos
// Consume GET /api/alumnos y carga DataTable
// ============================================

document.addEventListener('DOMContentLoaded', () => {
  cargarAlumnos();
});

async function cargarAlumnos() {
  try {
    const response = await fetch('/api/alumnos');
    const result = await response.json();

    if (!result.success) {
      throw new Error(result.message);
    }

    // Actualizar contador
    document.getElementById('totalBadge').textContent = `${result.total} alumnos`;

    // Llenar tbody
    const tbody = document.querySelector('#tablaAlumnos tbody');
    tbody.innerHTML = '';

    result.data.forEach(alumno => {
      const fechaFormateada = new Date(alumno.fecha_nacimiento).toLocaleDateString('es-MX');
      const sexoBadge = alumno.sexo === 'M'
        ? '<span class="badge bg-primary">M</span>'
        : '<span class="badge bg-pink" style="background-color:#e83e8c">F</span>';

      const fila = `
        <tr>
          <td><strong>${alumno.numero_cuenta}</strong></td>
          <td>${alumno.nombre} ${alumno.apellido_paterno} ${alumno.apellido_materno}</td>
          <td><code>${alumno.curp}</code></td>
          <td class="text-center">${sexoBadge}</td>
          <td>${alumno.telefono}</td>
          <td><a href="mailto:${alumno.correo_electronico}">${alumno.correo_electronico}</a></td>
          <td>${fechaFormateada}</td>
          <td><span class="badge bg-secondary">${alumno.abreviatura}</span> ${alumno.nombre_entidad}</td>
        </tr>
      `;
      tbody.insertAdjacentHTML('beforeend', fila);
    });

    // Ocultar loader, mostrar tabla
    document.getElementById('loader').classList.add('d-none');
    document.getElementById('tableContainer').classList.remove('d-none');

    // Inicializar DataTable
    $('#tablaAlumnos').DataTable({
      language: {
        url: 'https://cdn.datatables.net/plug-ins/2.1.8/i18n/es-MX.json'
      },
      pageLength: 10,
      lengthMenu: [[5, 10, 25, 50, -1], [5, 10, 25, 50, 'Todos']],
      order: [[0, 'asc']]
    });

  } catch (error) {
    console.error('Error al cargar alumnos:', error);
    document.getElementById('loader').classList.add('d-none');
    document.getElementById('error').classList.remove('d-none');
    document.getElementById('errorMsg').textContent = `Error al cargar los datos: ${error.message}`;
  }
}
