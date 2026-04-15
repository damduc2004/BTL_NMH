<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản lý sản phẩm – Product Manager</title>
        <style>
            *,
            *::before,
            *::after {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }
            
            body {
                font-family: 'Segoe UI', Arial, sans-serif;
                background: #f0f2f5;
                color: #222;
                min-height: 100vh;
            }
            /* ── TOPBAR ── */
            
            .topbar {
                background: linear-gradient(135deg, #1a73e8, #0d47a1);
                color: #fff;
                padding: 0 32px;
                height: 56px;
                display: flex;
                align-items: center;
                justify-content: space-between;
                box-shadow: 0 2px 8px rgba(0, 0, 0, .25);
            }
            
            .topbar .brand {
                font-size: 18px;
                font-weight: 700;
                text-decoration: none;
                color: #fff;
            }
            
            .topbar .user-info {
                display: flex;
                align-items: center;
                gap: 16px;
                font-size: 14px;
            }
            
            .topbar .user-info .name {
                opacity: .9;
            }
            
            .topbar .btn-logout {
                padding: 6px 16px;
                background: rgba(255, 255, 255, .15);
                border: 1px solid rgba(255, 255, 255, .35);
                border-radius: 6px;
                color: #fff;
                font-size: 13px;
                font-weight: 600;
                text-decoration: none;
                transition: background .2s;
            }
            
            .topbar .btn-logout:hover {
                background: rgba(255, 255, 255, .25);
            }
            
            .topbar .home-link {
                color: rgba(255, 255, 255, .85);
                text-decoration: none;
                font-size: 13px;
                margin-right: 8px;
            }
            
            .topbar .home-link:hover {
                color: #fff;
            }
            /* ── LAYOUT ── */
            
            .page {
                max-width: 1100px;
                margin: 32px auto;
                padding: 0 24px;
            }
            
            .page-header {
                display: flex;
                align-items: center;
                gap: 12px;
                margin-bottom: 24px;
            }
            
            .page-header h2 {
                font-size: 20px;
                font-weight: 700;
                color: #1a1a2e;
            }
            /* ── TOOLBAR ── */
            
            .toolbar {
                display: flex;
                align-items: center;
                gap: 10px;
                background: #fff;
                padding: 14px 16px;
                border-radius: 10px;
                box-shadow: 0 1px 6px rgba(0, 0, 0, .08);
                margin-bottom: 20px;
            }
            
            .toolbar input[type=text] {
                flex: 1;
                padding: 8px 14px;
                border: 1px solid #ddd;
                border-radius: 6px;
                font-size: 14px;
                outline: none;
                transition: border-color .2s;
            }
            
            .toolbar input[type=text]:focus {
                border-color: #1a73e8;
            }
            
            .btn {
                padding: 8px 18px;
                border-radius: 6px;
                border: none;
                font-size: 13px;
                font-weight: 600;
                cursor: pointer;
                transition: background .2s, opacity .2s;
            }
            
            .btn-primary {
                background: #1a73e8;
                color: #fff;
            }
            
            .btn-primary:hover {
                background: #1558b0;
            }
            
            .btn-success {
                background: #34a853;
                color: #fff;
            }
            
            .btn-success:hover {
                background: #2a8a44;
            }
            
            .btn-danger {
                background: #ea4335;
                color: #fff;
            }
            
            .btn-danger:hover {
                background: #c62828;
            }
            
            .btn-secondary {
                background: #eee;
                color: #444;
            }
            
            .btn-secondary:hover {
                background: #ddd;
            }
            
            .btn-sm {
                padding: 5px 12px;
                font-size: 12px;
            }
            /* ── PRODUCT TABLE ── */
            
            .card-box {
                background: #fff;
                border-radius: 10px;
                box-shadow: 0 1px 6px rgba(0, 0, 0, .08);
                overflow: hidden;
            }
            
            table {
                width: 100%;
                border-collapse: collapse;
            }
            
            thead {
                background: #f8f9fa;
            }
            
            th {
                padding: 11px 14px;
                text-align: left;
                font-size: 12px;
                font-weight: 700;
                color: #555;
                text-transform: uppercase;
                letter-spacing: .5px;
                border-bottom: 1px solid #e8e8e8;
            }
            
            td {
                padding: 11px 14px;
                font-size: 13px;
                border-bottom: 1px solid #f0f0f0;
                vertical-align: middle;
            }
            
            tr:last-child td {
                border-bottom: none;
            }
            
            tr:hover td {
                background: #fafafa;
            }
            
            .badge {
                display: inline-block;
                padding: 2px 8px;
                border-radius: 4px;
                font-size: 11px;
                font-weight: 600;
            }
            
            .badge-blue {
                background: #e8f0fe;
                color: #1a73e8;
            }
            
            .tag {
                display: inline-block;
                padding: 2px 7px;
                background: #f0f2f5;
                border-radius: 4px;
                font-size: 11px;
                margin: 1px;
            }
            
            .empty-state {
                text-align: center;
                padding: 48px;
                color: #999;
                font-size: 14px;
            }
            
            #loadingRow td {
                text-align: center;
                padding: 32px;
                color: #aaa;
                font-size: 13px;
            }
            /* ── TOAST ── */
            
            .toast {
                position: fixed;
                bottom: 28px;
                right: 28px;
                padding: 12px 22px;
                border-radius: 8px;
                font-size: 13px;
                font-weight: 600;
                color: #fff;
                box-shadow: 0 4px 16px rgba(0, 0, 0, .2);
                opacity: 0;
                pointer-events: none;
                transition: opacity .3s;
                z-index: 9999;
            }
            
            .toast.show {
                opacity: 1;
                pointer-events: auto;
            }
            
            .toast.ok {
                background: #34a853;
            }
            
            .toast.err {
                background: #ea4335;
            }
            /* ── ADD FORM PANEL ── */
            
            #addPanel {
                display: none;
                background: #fff;
                border-radius: 10px;
                box-shadow: 0 1px 6px rgba(0, 0, 0, .08);
                padding: 28px 32px;
                margin-bottom: 24px;
            }
            
            #addPanel.open {
                display: block;
            }
            
            #addPanel h3 {
                font-size: 16px;
                font-weight: 700;
                color: #1a1a2e;
                margin-bottom: 20px;
            }
            
            .form-grid {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 16px;
                margin-bottom: 16px;
            }
            
            .form-group label {
                display: block;
                font-size: 12px;
                font-weight: 600;
                color: #555;
                margin-bottom: 5px;
            }
            
            .form-group input,
            .form-group select {
                width: 100%;
                padding: 8px 12px;
                border: 1px solid #ddd;
                border-radius: 6px;
                font-size: 13px;
                outline: none;
                transition: border-color .2s;
            }
            
            .form-group input:focus,
            .form-group select:focus {
                border-color: #1a73e8;
            }
            
            .section-title {
                font-size: 13px;
                font-weight: 700;
                color: #444;
                margin: 18px 0 10px;
                padding-bottom: 6px;
                border-bottom: 1px solid #eee;
            }
            
            .attr-row {
                display: flex;
                align-items: center;
                gap: 8px;
                margin-bottom: 8px;
            }
            
            .attr-row label {
                display: flex;
                align-items: center;
                gap: 6px;
                font-size: 13px;
                flex: 1;
                min-width: 0;
            }
            
            .attr-row input[type=checkbox] {
                width: 15px;
                height: 15px;
                flex-shrink: 0;
            }
            
            .attr-row .attr-name {
                flex: 1;
                color: #333;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }
            
            .attr-row input[type=text] {
                flex: 1.2;
                padding: 6px 10px;
                border: 1px solid #ddd;
                border-radius: 5px;
                font-size: 13px;
            }
            
            .extra-row {
                display: flex;
                gap: 8px;
                margin-bottom: 8px;
            }
            
            .extra-row input {
                flex: 1;
                padding: 6px 10px;
                border: 1px solid #ddd;
                border-radius: 5px;
                font-size: 13px;
            }
            
            .btn-remove {
                width: 28px;
                height: 28px;
                border-radius: 50%;
                border: none;
                background: #fce8e6;
                color: #ea4335;
                font-size: 16px;
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                flex-shrink: 0;
            }
            
            .form-actions {
                display: flex;
                gap: 10px;
                margin-top: 22px;
            }
            
            #fixedAttrsSection {
                display: none;
            }
        </style>
    </head>

    <body>

        <div class="topbar">
            <div style="display:flex;align-items:center;gap:12px;">
                <a href="/" class="home-link">← Trang chủ</a>
                <span class="brand">📦 Quản lý sản phẩm</span>
            </div>
            <div class="user-info">
                <span class="name">👤 Admin</span>
                <a href="/logout" class="btn-logout">Đăng xuất</a>
            </div>
        </div>

        <div class="page">
            <div class="page-header">
                <h2>Danh sách sản phẩm</h2>
            </div>

            <!-- TOOLBAR -->
            <div class="toolbar">
                <input type="text" id="searchInput" placeholder="Tìm kiếm sản phẩm hoặc danh mục..." />
                <button class="btn btn-primary" onclick="doSearch()">🔍 Tìm kiếm</button>
                <button class="btn btn-success" onclick="openAddForm()">+ Thêm mới sản phẩm</button>
            </div>

            <!-- ADD FORM PANEL -->
            <div id="addPanel">
                <h3>Thêm sản phẩm mới</h3>
                <div class="form-grid">
                    <div class="form-group">
                        <label>Tên sản phẩm <span style="color:red">*</span></label>
                        <input type="text" id="fName" placeholder="VD: iPhone 15 Pro" />
                    </div>
                    <div class="form-group">
                        <label>Giá (VNĐ) <span style="color:red">*</span></label>
                        <input type="number" id="fPrice" placeholder="VD: 25000000" min="0" />
                    </div>
                    <div class="form-group">
                        <label>Số lượng tồn kho</label>
                        <input type="number" id="fStock" placeholder="VD: 100" min="0" value="0" />
                    </div>
                </div>
                <div class="form-group" style="max-width:340px">
                    <label>Danh mục <span style="color:red">*</span></label>
                    <select id="fCategory" onchange="loadFixedAttrs(this.value)">
                <option value="">-- Chọn danh mục --</option>
            </select>
                </div>

                <!-- Fixed attributes from category -->
                <div id="fixedAttrsSection">
                    <div class="section-title">Thuộc tính danh mục (chọn và nhập giá trị)</div>
                    <div id="fixedAttrsList"></div>
                </div>

                <!-- Extra attributes -->
                <div class="section-title">Thuộc tính tùy chỉnh</div>
                <div id="extraAttrsList"></div>
                <button class="btn btn-secondary btn-sm" onclick="addExtraRow()" style="margin-top:4px">+ Thêm thuộc tính</button>

                <div class="form-actions">
                    <button class="btn btn-success" onclick="saveProduct()">💾 Lưu sản phẩm</button>
                    <button class="btn btn-secondary" onclick="closeAddForm()">✕ Hủy</button>
                </div>
                <div id="formError" style="display:none;color:#ea4335;font-size:13px;margin-top:10px;"></div>
            </div>

            <!-- PRODUCT TABLE -->
            <div class="card-box">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên sản phẩm</th>
                            <th>Giá</th>
                            <th>Tồn kho</th>
                            <th>Danh mục</th>
                            <th>Thuộc tính</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody id="productTableBody">
                        <tr id="loadingRow">
                            <td colspan="7">Đang tải...</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- TOAST -->
        <div class="toast" id="toast"></div>

        <script>
            // ── LOAD PRODUCTS ──────────────────────────────────────────
            let currentKeyword = '';

            function forceLogin() {
                window.location.href = '/login';
            }

            function fetchJson(url, options) {
                if (!options) options = {};
                if (!options.headers) options.headers = {};
                options.credentials = 'include'; // Send cookies
                return fetch(url, options).then(async r => {
                    if (r.redirected && r.url && r.url.includes('/login')) {
                        forceLogin();
                        throw new Error('Phiên đăng nhập đã hết hạn');
                    }
                    if (r.status === 401 || r.status === 403) {
                        forceLogin();
                        throw new Error('Bạn không có quyền truy cập');
                    }
                    const contentType = (r.headers.get('content-type') || '').toLowerCase();
                    if (!r.ok) {
                        const text = await r.text();
                        throw new Error(text || ('HTTP ' + r.status));
                    }
                    if (!contentType.includes('application/json')) {
                        throw new Error('Phản hồi không phải JSON hợp lệ');
                    }
                    return r.json();
                });
            }

            function fetchText(url, options) {
                if (!options) options = {};
                if (!options.headers) options.headers = {};
                options.credentials = 'include'; // Send cookies
                return fetch(url, options).then(async r => {
                    if (r.redirected && r.url && r.url.includes('/login')) {
                        forceLogin();
                        throw new Error('Phiên đăng nhập đã hết hạn');
                    }
                    if (r.status === 401 || r.status === 403) {
                        forceLogin();
                        throw new Error('Bạn không có quyền truy cập');
                    }
                    if (!r.ok) {
                        const text = await r.text();
                        throw new Error(text || ('HTTP ' + r.status));
                    }
                    return r.text();
                });
            }

            function loadProducts(keyword) {
                currentKeyword = keyword || '';
                const body = document.getElementById('productTableBody');
                body.innerHTML = '<tr id="loadingRow"><td colspan="7">Đang tải...</td></tr>';
                const baseUrl = window.location.origin;
                const url = currentKeyword ?
                    baseUrl + '/api/products?keyword=' + encodeURIComponent(currentKeyword) :
                    baseUrl + '/api/products';
                fetchJson(url)
                    .then(products => renderProducts(products))
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
                    const attrs = (p.attributes || []).map(a =>
                        '<span class="tag">' + esc(a.attributeName) + ': ' + esc(a.value) + '</span>'
                    ).join('');
                    return '<tr>' +
                        '<td style="color:#888;font-size:12px">#' + p.id + '</td>' +
                        '<td style="font-weight:600">' + esc(p.name) + '</td>' +
                        '<td>' + formatMoney(p.price) + '</td>' +
                        '<td>' + (p.stockQuantity != null ? p.stockQuantity : '—') + '</td>' +
                        '<td><span class="badge badge-blue">' + esc(p.categoryName || '') + '</span></td>' +
                        '<td>' + (attrs || '<span style="color:#bbb">—</span>') + '</td>' +
                        '<td><button class="btn btn-danger btn-sm" onclick="deleteProduct(' + p.id + ')">Xóa</button></td>' +
                        '</tr>';
                }).join('');
            }

            function doSearch() {
                const kw = document.getElementById('searchInput').value.trim();
                loadProducts(kw);
            }

            document.getElementById('searchInput').addEventListener('keydown', function(e) {
                if (e.key === 'Enter') doSearch();
            });

            function deleteProduct(id) {
                if (!confirm('Xác nhận xóa sản phẩm #' + id + '?')) return;
                const baseUrl = window.location.origin;
                fetchJson(baseUrl + '/api/products/' + id, {
                        method: 'DELETE'
                    })
                    .then(() => {
                        showToast('Đã xóa sản phẩm', 'ok');
                        loadProducts(currentKeyword);
                    })
                    .catch(e => showToast(e.message || 'Xóa thất bại', 'err'));
            }

            // ── ADD FORM ───────────────────────────────────────────────
            function openAddForm() {
                document.getElementById('addPanel').classList.add('open');
                document.getElementById('fName').focus();
                loadCategories();
                window.scrollTo({
                    top: 0,
                    behavior: 'smooth'
                });
            }

            function closeAddForm() {
                document.getElementById('addPanel').classList.remove('open');
                resetForm();
            }

            function resetForm() {
                document.getElementById('fName').value = '';
                document.getElementById('fPrice').value = '';
                document.getElementById('fStock').value = '0';
                document.getElementById('fCategory').value = '';
                document.getElementById('fixedAttrsList').innerHTML = '';
                document.getElementById('fixedAttrsSection').style.display = 'none';
                document.getElementById('extraAttrsList').innerHTML = '';
                document.getElementById('formError').style.display = 'none';
            }

            // ── CATEGORIES ─────────────────────────────────────────────
            let categoriesLoaded = false;

            function loadCategories() {
                if (categoriesLoaded) return;
                const baseUrl = window.location.origin;
                fetchJson(baseUrl + '/api/categories')
                    .then(cats => {
                        const sel = document.getElementById('fCategory');
                        cats.forEach(c => {
                            const opt = document.createElement('option');
                            opt.value = c.id;
                            opt.text = c.name;
                            sel.appendChild(opt);
                        });
                        categoriesLoaded = true;
                    })
                    .catch(() => {});
            }

            // ── FIXED ATTRS (per category) ─────────────────────────────
            function loadFixedAttrs(categoryId) {
                const section = document.getElementById('fixedAttrsSection');
                const list = document.getElementById('fixedAttrsList');
                list.innerHTML = '';
                if (!categoryId) {
                    section.style.display = 'none';
                    return;
                }
                const baseUrl = window.location.origin;
                fetchJson(baseUrl + '/api/categories/' + categoryId + '/attributes')
                    .then(attrs => {
                        if (!attrs.length) {
                            section.style.display = 'none';
                            return;
                        }
                        section.style.display = 'block';
                        list.innerHTML = attrs.map(a =>
                            '<div class="attr-row">' +
                            '<label><input type="checkbox" class="fixed-attr-cb" data-id="' + a.id + '" data-name="' + esc(a.name) + '" onchange="toggleAttrInput(this)"/>' +
                            '<span class="attr-name">' + esc(a.name) + '</span></label>' +
                            '<input type="text" class="fixed-attr-val" data-id="' + a.id + '" placeholder="Nhập giá trị..." disabled style="opacity:.4" />' +
                            '</div>'
                        ).join('');
                    })
                    .catch(() => {
                        section.style.display = 'none';
                    });
            }

            function toggleAttrInput(cb) {
                const row = cb.closest('.attr-row');
                const inp = row.querySelector('.fixed-attr-val');
                inp.disabled = !cb.checked;
                inp.style.opacity = cb.checked ? '1' : '.4';
                if (cb.checked) inp.focus();
            }

            // ── EXTRA ATTRS ────────────────────────────────────────────
            function addExtraRow() {
                const list = document.getElementById('extraAttrsList');
                const div = document.createElement('div');
                div.className = 'extra-row';
                div.innerHTML = '<input type="text" placeholder="Tên thuộc tính" class="extra-attr-name" />' +
                    '<input type="text" placeholder="Giá trị" class="extra-attr-val" />' +
                    '<button class="btn-remove" onclick="this.parentElement.remove()" title="Xóa">×</button>';
                list.appendChild(div);
                div.querySelector('input').focus();
            }

            // ── SAVE ───────────────────────────────────────────────────
            function saveProduct() {
                const errEl = document.getElementById('formError');
                errEl.style.display = 'none';

                const name = document.getElementById('fName').value.trim();
                const price = parseFloat(document.getElementById('fPrice').value);
                const stock = parseInt(document.getElementById('fStock').value) || 0;
                const categoryId = document.getElementById('fCategory').value;

                if (!name) {
                    showFormErr('Vui lòng nhập tên sản phẩm');
                    return;
                }
                if (isNaN(price) || price < 0) {
                    showFormErr('Vui lòng nhập giá hợp lệ');
                    return;
                }
                if (!categoryId) {
                    showFormErr('Vui lòng chọn danh mục');
                    return;
                }

                // Fixed attributes (checked ones)
                const fixedAttrs = [];
                document.querySelectorAll('.fixed-attr-cb:checked').forEach(cb => {
                    const row = cb.closest('.attr-row');
                    const val = row.querySelector('.fixed-attr-val').value.trim();
                    fixedAttrs.push({
                        attributeId: parseInt(cb.dataset.id),
                        value: val
                    });
                });

                // Extra attributes
                const extraAttrs = [];
                document.querySelectorAll('.extra-row').forEach(row => {
                    const n = row.querySelector('.extra-attr-name').value.trim();
                    const v = row.querySelector('.extra-attr-val').value.trim();
                    if (n) extraAttrs.push({
                        name: n,
                        value: v
                    });
                });

                const payload = {
                    name: name,
                    price: price,
                    stockQuantity: stock,
                    categoryId: parseInt(categoryId),
                    fixedAttributes: fixedAttrs,
                    extraAttributes: extraAttrs
                };

                const baseUrl = window.location.origin;
                fetchJson(baseUrl + '/api/products', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify(payload)
                    })
                    .then(() => {
                        showToast('Thêm sản phẩm thành công!', 'ok');
                        closeAddForm();
                        loadProducts(currentKeyword);
                    })
                    .catch(e => showFormErr('Lỗi: ' + (e.message || 'Không thể lưu')));
            }

            // ── HELPERS ────────────────────────────────────────────────
            function formatMoney(n) {
                if (n == null) return '—';
                return Number(n).toLocaleString('vi-VN') + ' ₫';
            }

            function esc(s) {
                if (!s) return '';
                return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
            }

            function showToast(msg, type) {
                const t = document.getElementById('toast');
                t.textContent = msg;
                t.className = 'toast ' + type + ' show';
                setTimeout(() => t.classList.remove('show'), 3000);
            }

            function showFormErr(msg) {
                const el = document.getElementById('formError');
                el.textContent = msg;
                el.style.display = 'block';
            }

            // ── INIT ───────────────────────────────────────────────────
            loadProducts('');
        </script>
    </body>

    </html>