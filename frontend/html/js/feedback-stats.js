// ── STATE ─────────────────────────────────────────────────────
let currentFrom = '', currentTo = '';
let currentProduct = null;   // { id, name }
let allProducts   = [];      // cache từ /api/products
let allFeedbacks  = [];      // cache kết quả tầng 1

// ── INIT ──────────────────────────────────────────────────────
(function init() {
  const today = new Date();
  const first = new Date(today.getFullYear(), today.getMonth(), 1);
  document.getElementById('toDate').value   = fmt(today);
  document.getElementById('fromDate').value = fmt(first);

  fetch('/api/products?page=0&size=500')
    .then(r => r.json())
    .then(d => { allProducts = d.content || []; })
    .catch(() => {});
})();

function fmt(d) { return d.toISOString().slice(0, 10); }

// ── LAYER NAVIGATION ──────────────────────────────────────────
function goLayer(n) {
  document.querySelectorAll('.layer').forEach((el, i) => {
    el.classList.toggle('active', i + 1 === n);
  });
  updateBreadcrumb(n);
  window.scrollTo({ top: 0, behavior: 'smooth' });
}

function updateBreadcrumb(n) {
  const bc = document.getElementById('breadcrumb');
  if (n === 1) {
    bc.innerHTML = `<span class="current">Thống kê</span>`;
  } else if (n === 2) {
    bc.innerHTML = `
      <span onclick="goLayer(1)">Thống kê</span>
      <span class="sep">›</span>
      <span class="current">${esc(currentProduct ? currentProduct.name : 'Sản phẩm')}</span>`;
  } else {
    bc.innerHTML = `
      <span onclick="goLayer(1)">Thống kê</span>
      <span class="sep">›</span>
      <span onclick="goLayer(2)">${esc(currentProduct ? currentProduct.name : 'Sản phẩm')}</span>
      <span class="sep">›</span>
      <span class="current">Chi tiết phản hồi</span>`;
  }
}

// ── TẦNG 1: TÌM KIẾM ──────────────────────────────────────────
function doSearch() {
  const from = document.getElementById('fromDate').value;
  const to   = document.getElementById('toDate').value;
  const q    = document.getElementById('productSearch').value.trim().toLowerCase();

  if (!from || !to) { showToast('Vui lòng chọn khoảng thời gian', 'err'); return; }
  if (from > to)    { showToast('Ngày bắt đầu phải trước ngày kết thúc', 'err'); return; }

  currentFrom = from; currentTo = to;

  document.getElementById('layer1Result').innerHTML =
    '<div class="placeholder"><p>Đang tải dữ liệu...</p></div>';

  fetch(`/api/feedbacks/range?from=${from}&to=${to}`)
    .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
    .then(feedbacks => {
      allFeedbacks = feedbacks;
      renderLayer1(feedbacks, q, from, to);
    })
    .catch(e => {
      document.getElementById('layer1Result').innerHTML =
        `<div class="placeholder"><p style="color:#ea4335">Lỗi: ${esc(e.message)}</p></div>`;
    });
}

function resetFilter() {
  const today = new Date();
  document.getElementById('toDate').value   = fmt(today);
  document.getElementById('fromDate').value = fmt(new Date(today.getFullYear(), today.getMonth(), 1));
  document.getElementById('productSearch').value = '';
  document.getElementById('layer1Result').innerHTML = `
    <div class="placeholder">
      <p>Chọn khoảng thời gian và nhấn <strong>Thống kê</strong><br/>để xem danh sách sản phẩm được đánh giá.</p>
    </div>`;
}

function renderLayer1(feedbacks, searchQ, from, to) {
  const area = document.getElementById('layer1Result');

  if (!feedbacks.length) {
    area.innerHTML = `<div class="placeholder"><p>Không có phản hồi nào từ <strong>${from}</strong> đến <strong>${to}</strong>.</p></div>`;
    return;
  }

  const map = {};
  feedbacks.forEach(f => {
    if (!map[f.productId]) map[f.productId] = { productId: f.productId, feedbacks: [] };
    map[f.productId].feedbacks.push(f);
  });

  let rows = Object.values(map).map(g => {
    const total = g.feedbacks.length;
    const avg   = g.feedbacks.reduce((s, f) => s + (f.overallRating || 0), 0) / total;
    const name  = getProductName(g.productId);
    return { productId: g.productId, name, total, avg };
  });

  if (searchQ) {
    rows = rows.filter(r => r.name.toLowerCase().includes(searchQ));
  }

  rows.sort((a, b) => b.total - a.total);

  if (!rows.length) {
    area.innerHTML = `<div class="placeholder"><p>Không tìm thấy sản phẩm khớp với "<strong>${esc(searchQ)}</strong>".</p></div>`;
    return;
  }

  const totalFeedbacks = feedbacks.length;
  const overallAvg     = (feedbacks.reduce((s, f) => s + (f.overallRating || 0), 0) / totalFeedbacks).toFixed(1);

  area.innerHTML = `
    <div class="stats-row">
      <div class="stat-box">
        <div class="label">Tổng phản hồi</div>
        <div class="value">${totalFeedbacks}</div>
        <div class="sub">${from} → ${to}</div>
      </div>
      <div class="stat-box">
        <div class="label">Điểm TB toàn hệ thống</div>
        <div class="value">${overallAvg}</div>
        <div class="sub">Trên thang điểm 5</div>
      </div>
      <div class="stat-box">
        <div class="label">Sản phẩm được đánh giá</div>
        <div class="value">${rows.length}</div>
        <div class="sub">sản phẩm khác nhau</div>
      </div>
    </div>

    <div class="card-box">
      <div class="card-header">
        <h3>Danh sách sản phẩm (${rows.length})</h3>
        <span class="card-header-hint">Sắp xếp theo số phản hồi giảm dần · Nhấn vào hàng để xem chi tiết</span>
      </div>
      <table>
        <thead>
          <tr>
            <th>#</th>
            <th>Tên sản phẩm</th>
            <th>Điểm trung bình</th>
            <th>Số sao</th>
            <th>Số phản hồi</th>
          </tr>
        </thead>
        <tbody>
          ${rows.map((r, i) => `
            <tr class="clickable" onclick="openProduct(${r.productId}, '${esc(r.name)}')">
              <td style="color:#aaa;font-size:12px">${i + 1}</td>
              <td style="font-weight:600">${esc(r.name)}</td>
              <td><span class="${scoreClass(r.avg)}">${r.avg.toFixed(1)} / 5</span></td>
              <td>${starsHtml(r.avg)}</td>
              <td><span class="badge badge-blue">${r.total} phản hồi</span></td>
            </tr>`).join('')}
        </tbody>
      </table>
    </div>`;
}

// ── TẦNG 2: PHẢN HỒI THEO SẢN PHẨM ──────────────────────────
function openProduct(productId, productName) {
  currentProduct = { id: productId, name: productName };
  document.getElementById('layer2Title').textContent = `Phản hồi: ${productName}`;

  const list = allFeedbacks
    .filter(f => f.productId === productId)
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

  renderLayer2(list);
  goLayer(2);
}

function renderLayer2(list) {
  const body = document.getElementById('layer2Body');
  if (!list.length) {
    body.innerHTML = '<div class="placeholder"><p>Không có phản hồi nào.</p></div>';
    return;
  }

  body.innerHTML = list.map(f => `
    <div class="fb-card" onclick="openFeedback(${f.id})">
      <div class="fb-card-top">
        <div>
          <span class="fb-card-user">${esc(f.customerName || 'Khách hàng #' + f.customerId)}</span>
        </div>
        <span class="fb-card-time">${fmtDt(f.createdAt)}</span>
      </div>
      <div class="fb-card-meta">
        <span>${starsHtml(f.overallRating)}</span>
        <span class="${scoreClass(f.overallRating)}">${f.overallRating}/5</span>
        <span class="badge badge-blue">${(f.attributeRatings || []).length} thuộc tính được đánh giá</span>
      </div>
      <div class="fb-card-comment">${esc(f.comment || '—')}</div>
      <div class="fb-card-detail-link">
        <button type="button" class="btn-link" onclick="event.stopPropagation(); openFeedback(${f.id})">Xem chi tiết →</button>
      </div>
    </div>`).join('');
}

// ── TẦNG 3: CHI TIẾT PHẢN HỒI ────────────────────────────────
function openFeedback(feedbackId) {
  const f = allFeedbacks.find(x => x.id === feedbackId);
  if (!f) { showToast('Không tìm thấy phản hồi', 'err'); return; }

  const productName = currentProduct ? currentProduct.name : `Sản phẩm #${f.productId}`;

  const attrRows = (f.attributeRatings || []).length
    ? (f.attributeRatings || []).map(ar => `
        <tr>
          <td style="font-weight:600">${esc(ar.attributeName || 'Thuộc tính #' + ar.attributeId)}</td>
          <td>${starsHtml(ar.rating)} <span class="${scoreClass(ar.rating)}">${ar.rating}/5</span></td>
          <td>${esc(ar.comment || '—')}</td>
        </tr>`).join('')
    : `<tr><td colspan="3" style="text-align:center;color:#aaa;padding:24px">Không có đánh giá thuộc tính</td></tr>`;

  document.getElementById('layer3Body').innerHTML = `
    <div class="detail-header">
      <div class="detail-field">
        <div class="df-label">Sản phẩm</div>
        <div class="df-value">${esc(productName)}</div>
      </div>
      <div class="detail-field">
        <div class="df-label">Người đánh giá</div>
        <div class="df-value">${esc(f.customerName || 'Khách hàng #' + f.customerId)}</div>
      </div>
      <div class="detail-field">
        <div class="df-label">Điểm tổng</div>
        <div class="df-value ${scoreClass(f.overallRating)}">${starsHtml(f.overallRating)} ${f.overallRating}/5</div>
      </div>
      <div class="detail-field">
        <div class="df-label">Thời gian</div>
        <div class="df-value">${fmtDt(f.createdAt)}</div>
      </div>
    </div>

    ${f.comment ? `
    <div class="comment-block">
      <div class="comment-block-label">Nhận xét chung</div>
      ${esc(f.comment)}
    </div>` : ''}

    <div class="detail-section-title">Đánh giá chi tiết theo thuộc tính</div>
    <div class="card-box" style="margin-bottom:0">
      <table>
        <thead>
          <tr>
            <th>Thuộc tính</th>
            <th>Điểm số</th>
            <th>Nhận xét</th>
          </tr>
        </thead>
        <tbody>${attrRows}</tbody>
      </table>
    </div>`;

  goLayer(3);
}

// ── HELPERS ───────────────────────────────────────────────────
function getProductName(productId) {
  const p = allProducts.find(x => x.id === productId);
  return p ? p.name : `Sản phẩm #${productId}`;
}

function starsHtml(n) {
  const filled = Math.round(n || 0);
  return `<span class="stars">${'★'.repeat(filled)}<span class="stars-empty">${'★'.repeat(5 - filled)}</span></span>`;
}

function scoreClass(n) {
  if (n >= 4) return 'score-hi';
  if (n >= 3) return 'score-mid';
  return 'score-lo';
}

function fmtDt(iso) {
  if (!iso) return '—';
  const d = new Date(iso);
  return d.toLocaleDateString('vi-VN') + ' ' + d.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
}

function esc(s) {
  return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function showToast(msg, type) {
  const t = document.getElementById('toast');
  t.textContent = msg; t.className = 'toast ' + type + ' show';
  setTimeout(() => t.classList.remove('show'), 3000);
}

document.getElementById('productSearch').addEventListener('input', function() {
  if (allFeedbacks.length) {
    renderLayer1(allFeedbacks, this.value.trim().toLowerCase(), currentFrom, currentTo);
  }
});
