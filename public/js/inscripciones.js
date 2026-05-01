// ============================================
// JS: Página de Inscripciones (Alumno-Curso)
// ============================================

document.addEventListener('DOMContentLoaded', () => {
  cargarInscripciones();
});

async function cargarInscripciones() {
  try {
    const response = await fetch('/api/inscripciones');
    const result = await response.json();

    if (!result.success) throw new Error(result.message);

    document.getElementById('totalBadge').textContent = `${result.total} inscripciones`;

    const tbody = document.querySelector('#tablaInscripciones tbody');
    tbody.innerHTML = '';

    result.data.forEach(insc => {
      // Función para mostrar calificaciones (o guion si es null)
      const formatCal = (cal) => {
        if (cal === null) return '<span class="text-muted">-</span>';
        const num = parseFloat(cal);
        let color = 'text-success';
        if (num < 6) color = 'text-danger';
        else if (num < 8) color = 'text-warning';
        return `<strong class="${color}">${num.toFixed(1)}</strong>`;
      };

      // Promedio
      const promedio = insc.promedio !== null
        ? `<strong class="badge bg-primary fs-6">${parseFloat(insc.promedio).toFixed(2)}</strong>`
        : '<span class="text-muted">-</span>';

      // Estatus
      const estatusBadge = insc.estatus_evaluacion === 'REG'
        ? '<span class="badge bg-success">REGULAR</span>'
        : '<span class="badge bg-danger">NO PRESENTÓ</span>';

      const fila = `
        <tr>
          <td><strong>${insc.id_alumno_curso}</strong></td>
          <td>${insc.numero_cuenta}</td>
          <td>${insc.nombre_alumno}</td>
          <td>${insc.nombre_asignatura}</td>
          <td><span class="badge bg-dark">${insc.nombre_grupo}</span></td>
          <td class="text-center">${formatCal(insc.primer_parcial)}</td>
          <td class="text-center">${formatCal(insc.segundo_parcial)}</td>
          <td class="text-center">${formatCal(insc.tercer_parcial)}</td>
          <td class="text-center">${promedio}</td>
          <td class="text-center">${estatusBadge}</td>
        </tr>
      `;
      tbody.insertAdjacentHTML('beforeend', fila);
    });

    document.getElementById('loader').classList.add('d-none');
    document.getElementById('tableContainer').classList.remove('d-none');

    $('#tablaInscripciones').DataTable({
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
