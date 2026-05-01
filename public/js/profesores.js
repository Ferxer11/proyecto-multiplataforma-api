// ============================================
// JS: Página de Profesores
// ============================================

document.addEventListener('DOMContentLoaded', () => {
  cargarProfesores();
});

async function cargarProfesores() {
  try {
    const response = await fetch('/api/profesores');
    const result = await response.json();

    if (!result.success) throw new Error(result.message);

    document.getElementById('totalBadge').textContent = `${result.total} profesores`;

    const tbody = document.querySelector('#tablaProfesores tbody');
    tbody.innerHTML = '';

    result.data.forEach(prof => {
      const sexoBadge = prof.sexo === 'M'
        ? '<span class="badge bg-primary">M</span>'
        : '<span class="badge" style="background-color:#e83e8c;color:white">F</span>';

      const sueldoFormateado = new Intl.NumberFormat('es-MX', {
        style: 'currency',
        currency: 'MXN'
      }).format(prof.sueldo);

      const fila = `
        <tr>
          <td><strong>${prof.id_profesor}</strong></td>
          <td>${prof.nombre} ${prof.apellido_paterno} ${prof.apellido_materno}</td>
          <td><code>${prof.curp}</code></td>
          <td><code>${prof.rfc}</code></td>
          <td class="text-center">${sexoBadge}</td>
          <td>${prof.telefono}</td>
          <td><a href="mailto:${prof.correo_electronico}">${prof.correo_electronico}</a></td>
          <td class="text-end fw-bold text-success">${sueldoFormateado}</td>
        </tr>
      `;
      tbody.insertAdjacentHTML('beforeend', fila);
    });

    document.getElementById('loader').classList.add('d-none');
    document.getElementById('tableContainer').classList.remove('d-none');

    $('#tablaProfesores').DataTable({
      language: { url: 'https://cdn.datatables.net/plug-ins/2.1.8/i18n/es-MX.json' },
      pageLength: 10,
      lengthMenu: [[5, 10, 25, 50, -1], [5, 10, 25, 50, 'Todos']],
      order: [[0, 'asc']]
    });

  } catch (error) {
    console.error('Error:', error);
    document.getElementById('loader').classList.add('d-none');
    document.getElementById('error').classList.remove('d-none');
    document.getElementById('errorMsg').textContent = `Error al cargar los datos: ${error.message}`;
  }
}
