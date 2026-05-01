// ============================================
// JS: Página de Cursos
// ============================================

document.addEventListener('DOMContentLoaded', () => {
  cargarCursos();
});

async function cargarCursos() {
  try {
    const response = await fetch('/api/cursos');
    const result = await response.json();

    if (!result.success) throw new Error(result.message);

    document.getElementById('totalBadge').textContent = `${result.total} cursos`;

    const tbody = document.querySelector('#tablaCursos tbody');
    tbody.innerHTML = '';

    result.data.forEach(curso => {
      // Color del badge según el tipo de curso
      let tipoBadge;
      if (curso.tipo_curso === 'Ordinario') tipoBadge = 'bg-success';
      else if (curso.tipo_curso === 'Extraordinario') tipoBadge = 'bg-warning text-dark';
      else tipoBadge = 'bg-info text-dark';

      const cupoTexto = `${curso.inscritos_actual} / ${curso.cupo_maximo}`;
      const porcentaje = (curso.inscritos_actual / curso.cupo_maximo) * 100;
      let cupoBadge = 'bg-success';
      if (porcentaje > 80) cupoBadge = 'bg-danger';
      else if (porcentaje > 50) cupoBadge = 'bg-warning text-dark';

      const fila = `
        <tr>
          <td><strong>${curso.id_curso}</strong></td>
          <td><span class="badge bg-secondary">${curso.clave_asignatura}</span></td>
          <td>${curso.nombre_asignatura}</td>
          <td>${curso.nombre_profesor}</td>
          <td><span class="badge bg-dark">${curso.nombre_grupo}</span></td>
          <td><span class="badge ${tipoBadge}">${curso.tipo_curso}</span></td>
          <td>${curso.periodo}</td>
          <td class="text-capitalize">${curso.semestre}</td>
          <td><span class="badge ${cupoBadge}">${cupoTexto}</span></td>
        </tr>
      `;
      tbody.insertAdjacentHTML('beforeend', fila);
    });

    document.getElementById('loader').classList.add('d-none');
    document.getElementById('tableContainer').classList.remove('d-none');

    $('#tablaCursos').DataTable({
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
