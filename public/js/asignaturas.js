// ============================================
// JS: Página de Asignaturas
// ============================================

document.addEventListener('DOMContentLoaded', () => {
  cargarAsignaturas();
});

async function cargarAsignaturas() {
  try {
    const response = await fetch('/api/asignaturas');
    const result = await response.json();

    if (!result.success) throw new Error(result.message);

    document.getElementById('totalBadge').textContent = `${result.total} asignaturas`;

    const tbody = document.querySelector('#tablaAsignaturas tbody');
    tbody.innerHTML = '';

    result.data.forEach(asig => {
      const fila = `
        <tr>
          <td><span class="badge bg-info text-dark fs-6">${asig.clave_asignatura}</span></td>
          <td>${asig.nombre}</td>
        </tr>
      `;
      tbody.insertAdjacentHTML('beforeend', fila);
    });

    document.getElementById('loader').classList.add('d-none');
    document.getElementById('tableContainer').classList.remove('d-none');

    $('#tablaAsignaturas').DataTable({
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
