// ============================================
// FRONTEND: CRUD de Profesores
// ============================================

const API = '/api/profesores';
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
    const tbody = document.querySelector('#tabla-profesores tbody');
    tbody.innerHTML = '';
    json.data.forEach(p => {
      const tr = document.createElement('tr');
      tr.innerHTML = `<td>${p.id_profesor}</td><td>${p.nombre}</td><td>${p.apellido_paterno}</td><td>${p.apellido_materno || ''}</td><td>${p.rfc}</td><td>${p.correo_electronico}</td><td>$${parseFloat(p.sueldo).toFixed(2)}</td>`;
      tbody.appendChild(tr);
    });
    dataTable = $('#tabla-profesores').DataTable({
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
  data.sueldo = parseFloat(data.sueldo);
  data.curp = data.curp.toUpperCase();
  data.rfc = data.rfc.toUpperCase();
  if (!data.telefono) delete data.telefono;
  if (!data.apellido_materno) delete data.apellido_materno;

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
  const id = document.getElementById('buscar-editar-id').value;
  if (!id) return mostrarMsg('msg-editar', 'error', '⚠️', 'Captura un ID');
  try {
    const res = await fetch(`${API}/${id}`);
    const json = await res.json();
    if (!res.ok) return mostrarMsg('msg-editar', 'error', '❌', json.message);
    const form = document.getElementById('form-editar');
    form.style.display = 'block';
    Object.keys(json.data).forEach(k => {
      const input = form.elements[k];
      if (input) {
        if (k === 'fecha_nacimiento' && json.data[k]) input.value = json.data[k].split('T')[0];
        else input.value = json.data[k] != null ? json.data[k] : '';
      }
    });
    mostrarMsg('msg-editar', 'info', '📝', 'Datos cargados. Modifica y guarda.');
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
  const id = data.id_profesor;
  delete data.id_profesor;
  data.sueldo = parseFloat(data.sueldo);
  data.curp = data.curp.toUpperCase();
  data.rfc = data.rfc.toUpperCase();
  if (!data.telefono) delete data.telefono;
  if (!data.apellido_materno) delete data.apellido_materno;

  try {
    const res = await fetch(`${API}/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
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
  const id = document.getElementById('buscar-eliminar-id').value;
  if (!id) return mostrarMsg('msg-eliminar', 'error', '⚠️', 'Captura un ID');
  try {
    const res = await fetch(`${API}/${id}`);
    const json = await res.json();
    if (!res.ok) {
      document.getElementById('info-eliminar').style.display = 'none';
      document.getElementById('btn-confirmar-eliminar').style.display = 'none';
      return mostrarMsg('msg-eliminar', 'error', '❌', json.message);
    }
    const p = json.data;
    document.getElementById('info-eliminar').innerHTML = `
      <strong>¿Eliminar este profesor?</strong><br>
      <strong>ID:</strong> ${p.id_profesor}<br>
      <strong>Nombre:</strong> ${p.nombre} ${p.apellido_paterno} ${p.apellido_materno || ''}<br>
      <strong>RFC:</strong> ${p.rfc}
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
  if (!confirm('¿Confirmas que deseas eliminar este profesor?')) return;
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
