// ============================================
// FRONTEND: CRUD de Materias
// ============================================

const API = '/api/asignaturas';
let dataTable;

function mostrarMsg(elemId, tipo, titulo, mensaje, extra) {
  const colores = { success: 'success', error: 'danger', info: 'info' };
  let html = `<div class="alert alert-${colores[tipo]}"><strong>${titulo}</strong> ${mensaje || ''}`;
  if (extra) html += `<pre class="mb-0 mt-2 small">${JSON.stringify(extra, null, 2)}</pre>`;
  html += '</div>';
  document.getElementById(elemId).innerHTML = html;
}

async function cargarLista() {
  try {
    const res = await fetch(API);
    const json = await res.json();
    if (dataTable) dataTable.destroy();
    const tbody = document.querySelector('#tabla-materias tbody');
    tbody.innerHTML = '';
    json.data.forEach(m => {
      const tr = document.createElement('tr');
      tr.innerHTML = `<td>${m.clave_asignatura}</td><td>${m.nombre}</td>`;
      tbody.appendChild(tr);
    });
    dataTable = $('#tabla-materias').DataTable({
      language: { url: '//cdn.datatables.net/plug-ins/1.13.7/i18n/es-MX.json' },
      pageLength: 10,
    });
  } catch (e) { console.error(e); }
}

document.getElementById('form-crear').addEventListener('submit', async (e) => {
  e.preventDefault();
  const form = e.target;
  if (!form.checkValidity()) {
    form.classList.add('was-validated');
    return mostrarMsg('msg-crear', 'error', '⚠️ Validación HTML5:', 'Revisa los campos');
  }
  const data = Object.fromEntries(new FormData(form));
  data.clave_asignatura = data.clave_asignatura.toUpperCase();

  try {
    const res = await fetch(API, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    const json = await res.json();
    if (res.ok) {
      mostrarMsg('msg-crear', 'success', '✅ Éxito:', json.message, json.data);
      form.reset();
      form.classList.remove('was-validated');
      cargarLista();
    } else {
      mostrarMsg('msg-crear', 'error', '❌ Error:', json.message || json.error, json.errores || json.detalle);
    }
  } catch (e) {
    mostrarMsg('msg-crear', 'error', '❌ Error de red:', e.message);
  }
});

document.getElementById('btn-cargar-editar').addEventListener('click', async () => {
  const id = document.getElementById('buscar-editar-id').value.toUpperCase();
  if (!id) return mostrarMsg('msg-editar', 'error', '⚠️', 'Captura una clave');
  try {
    const res = await fetch(`${API}/${id}`);
    const json = await res.json();
    if (!res.ok) return mostrarMsg('msg-editar', 'error', '❌', json.message);
    const form = document.getElementById('form-editar');
    form.style.display = 'block';
    form.elements.clave_asignatura.value = json.data.clave_asignatura;
    form.elements.nombre.value = json.data.nombre;
    mostrarMsg('msg-editar', 'info', '📝', 'Datos cargados. Modifica el nombre y guarda.');
  } catch (e) {
    mostrarMsg('msg-editar', 'error', '❌ Error:', e.message);
  }
});

document.getElementById('form-editar').addEventListener('submit', async (e) => {
  e.preventDefault();
  const form = e.target;
  if (!form.checkValidity()) {
    form.classList.add('was-validated');
    return mostrarMsg('msg-editar', 'error', '⚠️ Validación HTML5:', 'Revisa los campos');
  }
  const data = Object.fromEntries(new FormData(form));
  const id = data.clave_asignatura;

  try {
    const res = await fetch(`${API}/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: data.nombre }),
    });
    const json = await res.json();
    if (res.ok) {
      mostrarMsg('msg-editar', 'success', '✅ Éxito:', json.message, json.data);
      cargarLista();
    } else {
      mostrarMsg('msg-editar', 'error', '❌ Error:', json.message || json.error, json.errores || json.detalle);
    }
  } catch (e) {
    mostrarMsg('msg-editar', 'error', '❌ Error de red:', e.message);
  }
});

document.getElementById('btn-buscar-eliminar').addEventListener('click', async () => {
  const id = document.getElementById('buscar-eliminar-id').value.toUpperCase();
  if (!id) return mostrarMsg('msg-eliminar', 'error', '⚠️', 'Captura una clave');
  try {
    const res = await fetch(`${API}/${id}`);
    const json = await res.json();
    if (!res.ok) {
      document.getElementById('info-eliminar').style.display = 'none';
      document.getElementById('btn-confirmar-eliminar').style.display = 'none';
      return mostrarMsg('msg-eliminar', 'error', '❌', json.message);
    }
    const m = json.data;
    document.getElementById('info-eliminar').innerHTML = `
      <strong>¿Eliminar esta materia?</strong><br>
      <strong>Clave:</strong> ${m.clave_asignatura}<br>
      <strong>Nombre:</strong> ${m.nombre}
    `;
    document.getElementById('info-eliminar').style.display = 'block';
    document.getElementById('btn-confirmar-eliminar').style.display = 'inline-block';
    document.getElementById('btn-confirmar-eliminar').dataset.id = id;
    document.getElementById('msg-eliminar').innerHTML = '';
  } catch (e) {
    mostrarMsg('msg-eliminar', 'error', '❌ Error:', e.message);
  }
});

document.getElementById('btn-confirmar-eliminar').addEventListener('click', async (e) => {
  if (!confirm('¿Confirmas eliminar esta materia? Si tiene cursos asociados fallará.')) return;
  const id = e.target.dataset.id;
  try {
    const res = await fetch(`${API}/${id}`, { method: 'DELETE' });
    const json = await res.json();
    if (res.ok) {
      mostrarMsg('msg-eliminar', 'success', '✅ Éxito:', json.message, json.data);
      document.getElementById('info-eliminar').style.display = 'none';
      document.getElementById('btn-confirmar-eliminar').style.display = 'none';
      document.getElementById('buscar-eliminar-id').value = '';
      cargarLista();
    } else {
      mostrarMsg('msg-eliminar', 'error', '❌ Error:', json.message || json.error, json.detalle);
    }
  } catch (e) {
    mostrarMsg('msg-eliminar', 'error', '❌ Error de red:', e.message);
  }
});

cargarLista();
