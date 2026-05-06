const PAGE_SIZE = 20;
let currentPage = 0;
let currentKeyword = '';
let totalPages = 0;

// ── FETCH HELPERS ──────────────────────────────────
function api(url, opts) {
  return fetch(url, opts || {}).then(async r => {
    if (!r.ok) { const t = await r.text(); throw new Error(t || 'HTTP ' + r.status); }
    const ct = r.headers.get('content-type') || '';
    if (r.status === 204) return null;
    if (ct.includes('application/json')) return r.json();
    throw new Error('Phản hồi không phải JSON');
  });
}

// ── LOAD PRODUCTS ──────────────────────────────────
function loadProducts(keyword, page) {
  currentKeyword = keyword != null ? keyword : currentKeyword;
  currentPage    = page    != null ? page    : currentPage;
  const body = document.getElementById('productTableBody');
  body.innerHTML = '<tr><td colspan="7" class="empty-state">Đang tải...</td></tr>';
  document.getElementById('paginationBar').innerHTML = '';

  let url = `/api/products?page=${currentPage}&size=${PAGE_SIZE}`;
  if (currentKeyword) url += '&keyword=' + encodeURIComponent(currentKeyword);

  api(url)
    .then(data => {
      totalPages = data.totalPages;
      renderProducts(data.content);
      renderPagination(data.number, data.totalPages, data.totalElements);
    })
    .catch(() => {
      body.innerHTML = '<tr><td colspan="7" class="empty-state">Lỗi khi tải dữ liệu</td></tr>';
    });
}

function renderProducts(products) {
  const body = document.getElementById('productTableBody');
  if (!products.length) {
    body.innerHTML = '<tr><td colspan="7" class="empty-state">Không tìm thấy sản phẩm nào</td></tr>';
    return;
  }
  body.innerHTML = products.map(p => {
    const attrs = (p.productAttributes || []).map(pa =>
      `<span class="tag">${esc(pa.attribute.name)}: ${esc(pa.value)}</span>`
    ).join('');
    return `<tr>
      <td style="color:#888;font-size:12px">#${p.id}</td>
      <td style="font-weight:600">${esc(p.name)}</td>
      <td>${fmtMoney(p.price)}</td>
      <td>${p.stockQuantity ?? '—'}</td>
      <td><span class="badge badge-blue">${esc(p.category?.name || '')}</span></td>
      <td>${attrs || '<span style="color:#bbb">—</span>'}</td>
      <td><button class="btn btn-danger btn-sm" onclick="deleteProduct(${p.id})">Xóa</button></td>
    </tr>`;
  }).join('');
}

function renderPagination(current, total, totalElements) {
  const bar = document.getElementById('paginationBar');
  if (total <= 1) { bar.innerHTML = `<span class="page-info">Tổng: ${totalElements} sản phẩm</span>`; return; }

  let html = `<button ${current === 0 ? 'disabled' : ''} onclick="loadProducts(null,${current-1})">‹</button>`;

  const start = Math.max(0, current - 3);
  const end   = Math.min(total - 1, current + 3);
  if (start > 0) html += `<button onclick="loadProducts(null,0)">1</button>${start > 1 ? '<span>…</span>' : ''}`;
  for (let i = start; i <= end; i++) {
    html += `<button class="${i === current ? 'active' : ''}" onclick="loadProducts(null,${i})">${i+1}</button>`;
  }
  if (end < total - 1) html += `${end < total - 2 ? '<span>…</span>' : ''}<button onclick="loadProducts(null,${total-1})">${total}</button>`;
  html += `<button ${current === total-1 ? 'disabled' : ''} onclick="loadProducts(null,${current+1})">›</button>`;
  html += `<span class="page-info" style="margin-left:8px">Tổng: ${totalElements} sản phẩm</span>`;
  bar.innerHTML = html;
}

function doSearch() {
  loadProducts(document.getElementById('searchInput').value.trim(), 0);
}
document.getElementById('searchInput').addEventListener('keydown', e => { if (e.key === 'Enter') doSearch(); });

// ── DELETE ─────────────────────────────────────────
function deleteProduct(id) {
  if (!confirm(`Xác nhận xóa sản phẩm #${id}?`)) return;
  api(`/api/products/${id}`, { method: 'DELETE' })
    .then(() => { showToast('Đã xóa sản phẩm', 'ok'); loadProducts(null, currentPage); })
    .catch(e => showToast(e.message || 'Xóa thất bại', 'err'));
}

// ── ADD FORM ───────────────────────────────────────
let categoriesLoaded = false;

function openAddForm() {
  document.getElementById('addPanel').classList.add('open');
  loadCategories();
  window.scrollTo({ top: 0, behavior: 'smooth' });
}
function closeAddForm() {
  document.getElementById('addPanel').classList.remove('open');
  resetForm();
}
function resetForm() {
  ['fName','fPrice'].forEach(id => document.getElementById(id).value = '');
  document.getElementById('fStock').value = '0';
  document.getElementById('fCategory').value = '';
  document.getElementById('fixedAttrsList').innerHTML = '';
  document.getElementById('fixedAttrsSection').style.display = 'none';
  document.getElementById('extraAttrsList').innerHTML = '';
  document.getElementById('formError').style.display = 'none';
}

function loadCategories() {
  if (categoriesLoaded) return;
  api('/api/categories').then(cats => {
    const sel = document.getElementById('fCategory');
    cats.forEach(c => { const o = document.createElement('option'); o.value = c.id; o.text = c.name; sel.appendChild(o); });
    categoriesLoaded = true;
  }).catch(() => {});
}

function loadFixedAttrs(categoryId) {
  const section = document.getElementById('fixedAttrsSection');
  const list = document.getElementById('fixedAttrsList');
  list.innerHTML = '';
  if (!categoryId) { section.style.display = 'none'; return; }
  api(`/api/categories/${categoryId}/attributes`).then(attrs => {
    if (!attrs.length) { section.style.display = 'none'; return; }
    section.style.display = 'block';
    list.innerHTML = attrs.map(a => `
      <div class="attr-row">
        <label>
          <input type="checkbox" class="fixed-attr-cb" data-id="${a.id}" onchange="toggleAttrInput(this)" />
          <span class="attr-name">${esc(a.name)}</span>
        </label>
        <input type="text" class="fixed-attr-val" data-id="${a.id}" placeholder="Nhập giá trị..." disabled style="opacity:.4" />
      </div>`).join('');
  }).catch(() => { section.style.display = 'none'; });
}

function toggleAttrInput(cb) {
  const inp = cb.closest('.attr-row').querySelector('.fixed-attr-val');
  inp.disabled = !cb.checked;
  inp.style.opacity = cb.checked ? '1' : '.4';
  if (cb.checked) inp.focus();
}

function addExtraRow() {
  const div = document.createElement('div');
  div.className = 'extra-row';
  div.innerHTML = `<input type="text" placeholder="Tên thuộc tính" class="extra-attr-name" />
    <input type="text" placeholder="Giá trị" class="extra-attr-val" />
    <button class="btn-remove" onclick="this.parentElement.remove()">×</button>`;
  document.getElementById('extraAttrsList').appendChild(div);
  div.querySelector('input').focus();
}

function saveProduct() {
  const errEl = document.getElementById('formError');
  errEl.style.display = 'none';

  const name = document.getElementById('fName').value.trim();
  const price = parseFloat(document.getElementById('fPrice').value);
  const stock = parseInt(document.getElementById('fStock').value) || 0;
  const categoryId = document.getElementById('fCategory').value;

  if (!name)                      { showFormErr('Vui lòng nhập tên sản phẩm'); return; }
  if (isNaN(price) || price < 0)  { showFormErr('Vui lòng nhập giá hợp lệ'); return; }
  if (!categoryId)                { showFormErr('Vui lòng chọn danh mục'); return; }

  const fixedAttributes = [];
  document.querySelectorAll('.fixed-attr-cb:checked').forEach(cb => {
    const val = cb.closest('.attr-row').querySelector('.fixed-attr-val').value.trim();
    fixedAttributes.push({ attributeId: parseInt(cb.dataset.id), value: val });
  });

  const extraAttributes = [];
  document.querySelectorAll('.extra-row').forEach(row => {
    const n = row.querySelector('.extra-attr-name').value.trim();
    const v = row.querySelector('.extra-attr-val').value.trim();
    if (n) extraAttributes.push({ name: n, value: v });
  });

  api('/api/products', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ name, price, stockQuantity: stock, categoryId: parseInt(categoryId), fixedAttributes, extraAttributes })
  })
  .then(() => { showToast('Thêm sản phẩm thành công!', 'ok'); closeAddForm(); loadProducts(currentKeyword, currentPage); })
  .catch(e => showFormErr('Lỗi: ' + (e.message || 'Không thể lưu')));
}

// ── HELPERS ────────────────────────────────────────
function fmtMoney(n) { return n == null ? '—' : Number(n).toLocaleString('vi-VN') + ' ₫'; }
function esc(s) { return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
function showToast(msg, type) {
  const t = document.getElementById('toast');
  t.textContent = msg; t.className = 'toast ' + type + ' show';
  setTimeout(() => t.classList.remove('show'), 3000);
}
function showFormErr(msg) {
  const el = document.getElementById('formError');
  el.textContent = msg; el.style.display = 'block';
}

loadProducts('', 0);
