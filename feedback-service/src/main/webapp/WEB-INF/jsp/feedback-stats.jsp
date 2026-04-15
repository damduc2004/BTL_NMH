<%@ page contentType="text/html;charset=UTF-8" language="java" session="false" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Th&#7889;ng k&#234; ph&#7843;n h&#7891;i – Product Manager</title>
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
                color: #1a1a2e;
                min-height: 100vh;
            }
            /* ── Topbar ── */
            
            .topbar {
                background: linear-gradient(135deg, #1a73e8, #0d47a1);
                color: #fff;
                padding: 0 32px;
                height: 56px;
                display: flex;
                align-items: center;
                justify-content: space-between;
                box-shadow: 0 2px 8px rgba(0, 0, 0, .25);
                position: sticky;
                top: 0;
                z-index: 100;
            }
            
            .topbar .brand {
                font-size: 18px;
                font-weight: 700;
            }
            
            .topbar nav a {
                color: rgba(255, 255, 255, .85);
                text-decoration: none;
                margin-left: 28px;
                font-size: 14px;
                font-weight: 500;
                padding: 6px 0;
                border-bottom: 2px solid transparent;
                transition: color .2s, border-color .2s;
            }
            
            .topbar nav a:hover,
            .topbar nav a.active {
                color: #fff;
                border-bottom-color: #fff;
            }
            /* ── Layout ── */
            
            .container {
                max-width: 1200px;
                margin: 28px auto;
                padding: 0 24px;
            }
            
            .layout {
                display: flex;
                gap: 24px;
                align-items: flex-start;
            }
            
            .panel-form {
                flex: 0 0 340px;
                position: sticky;
                top: 72px;
            }
            
            .panel-stats {
                flex: 1;
                min-width: 0;
            }
            /* ── Card ── */
            
            .card {
                background: #fff;
                border-radius: 14px;
                box-shadow: 0 2px 12px rgba(0, 0, 0, .07);
                padding: 22px 24px;
                margin-bottom: 20px;
            }
            
            .card-title {
                font-size: 14px;
                font-weight: 700;
                color: #1a1a2e;
                margin-bottom: 18px;
                padding-bottom: 12px;
                border-bottom: 2px solid #e8f0fe;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            /* ── Form controls ── */
            
            label {
                display: block;
                margin: 14px 0 5px;
                font-size: 12px;
                font-weight: 600;
                color: #555;
                text-transform: uppercase;
                letter-spacing: .4px;
            }
            
            label:first-child {
                margin-top: 0;
            }
            
            input[type=text],
            input[type=number],
            select,
            textarea {
                width: 100%;
                padding: 9px 12px;
                font-size: 13px;
                border: 1px solid #d0d7de;
                border-radius: 8px;
                background: #fafbfc;
                transition: border-color .2s, box-shadow .2s;
                outline: none;
            }
            
            input:focus,
            select:focus,
            textarea:focus {
                border-color: #1a73e8;
                box-shadow: 0 0 0 3px rgba(26, 115, 232, .12);
                background: #fff;
            }
            
            textarea {
                resize: vertical;
            }
            
            .row2 {
                display: flex;
                gap: 10px;
            }
            
            .row2>div {
                flex: 1;
            }
            
            .attr-rating-row {
                display: flex;
                align-items: center;
                gap: 8px;
                margin-bottom: 6px;
                padding: 7px 10px;
                background: #f8f9fa;
                border-radius: 8px;
                border: 1px solid #e8eaed;
            }
            
            .attr-rating-row .lbl {
                flex: 1;
                font-size: 12px;
                color: #444;
                font-weight: 500;
            }
            
            .attr-rating-row select {
                width: 62px;
                flex: none;
                padding: 4px 6px;
                font-size: 12px;
            }
            
            .attr-rating-row input {
                flex: 1.5;
                font-size: 12px;
            }
            /* ── Buttons ── */
            
            button {
                padding: 8px 16px;
                font-size: 13px;
                font-weight: 600;
                cursor: pointer;
                border-radius: 8px;
                border: none;
                transition: background .18s, transform .1s, box-shadow .18s;
            }
            
            button:active {
                transform: scale(.97);
            }
            
            .btn-primary {
                background: #1a73e8;
                color: #fff;
            }
            
            .btn-primary:hover {
                background: #1557b0;
                box-shadow: 0 2px 8px rgba(26, 115, 232, .4);
            }
            
            .btn-primary:disabled {
                background: #9fc3f8;
                cursor: not-allowed;
            }
            
            .btn-secondary {
                background: #f1f3f4;
                color: #333;
                border: 1px solid #d0d7de;
            }
            
            .btn-secondary:hover {
                background: #e8eaed;
            }
            
            .btn-danger {
                background: #ea4335;
                color: #fff;
            }
            
            .btn-danger:hover {
                background: #c5221f;
            }
            
            .btn-sm {
                padding: 5px 11px;
                font-size: 12px;
            }
            
            .btn-link {
                background: none;
                border: none;
                color: #1a73e8;
                font-size: 13px;
                font-weight: 600;
                padding: 0;
                cursor: pointer;
            }
            
            .btn-link:hover {
                text-decoration: underline;
            }
            /* ── Message ── */
            
            #msg {
                margin-top: 12px;
                padding: 10px 14px;
                font-size: 13px;
                display: none;
                border-radius: 8px;
                font-weight: 500;
            }
            
            .msg-ok {
                background: #e6f4ea;
                border-left: 4px solid #34a853;
                color: #1e6b31;
            }
            
            .msg-err {
                background: #fce8e6;
                border-left: 4px solid #ea4335;
                color: #a50e0e;
            }
            /* ── Stars ── */
            
            .star {
                color: #f9ab00;
                letter-spacing: 1px;
            }
            
            .star-empty {
                color: #ddd;
                letter-spacing: 1px;
            }
            /* ── Breadcrumb ── */
            
            .breadcrumb {
                display: flex;
                align-items: center;
                gap: 6px;
                font-size: 13px;
                margin-bottom: 18px;
                flex-wrap: wrap;
            }
            
            .breadcrumb-item {
                color: #1a73e8;
                cursor: pointer;
                font-weight: 600;
            }
            
            .breadcrumb-item:hover {
                text-decoration: underline;
            }
            
            .breadcrumb-item.current {
                color: #555;
                cursor: default;
                font-weight: 400;
            }
            
            .breadcrumb-item.current:hover {
                text-decoration: none;
            }
            
            .breadcrumb-sep {
                color: #bbb;
                font-size: 11px;
            }
            /* ── View transitions ── */
            
            .view {
                animation: fadeIn .22s ease;
            }
            
            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(6px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            /* ── Product summary cards ── */
            
            .product-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                gap: 16px;
            }
            
            .product-card {
                background: #fff;
                border-radius: 12px;
                border: 1px solid #e8eaed;
                padding: 18px 20px;
                transition: box-shadow .2s, transform .15s;
                cursor: pointer;
            }
            
            .product-card:hover {
                box-shadow: 0 6px 20px rgba(26, 115, 232, .14);
                transform: translateY(-2px);
                border-color: #1a73e8;
            }
            
            .pc-name {
                font-size: 14px;
                font-weight: 700;
                color: #1a1a2e;
                margin-bottom: 10px;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }
            
            .pc-meta {
                display: flex;
                align-items: center;
                gap: 12px;
                margin-bottom: 12px;
            }
            
            .pc-avg {
                font-size: 28px;
                font-weight: 800;
                color: #1a73e8;
                line-height: 1;
            }
            
            .pc-avg-right {
                display: flex;
                flex-direction: column;
                gap: 2px;
            }
            
            .pc-count {
                font-size: 12px;
                color: #888;
            }
            /* Rating bars */
            
            .rating-bars {
                display: flex;
                flex-direction: column;
                gap: 3px;
                margin-bottom: 14px;
            }
            
            .rbar-row {
                display: flex;
                align-items: center;
                gap: 6px;
                font-size: 11px;
                color: #666;
            }
            
            .rbar-label {
                width: 14px;
                text-align: right;
                font-weight: 700;
            }
            
            .rbar-track {
                flex: 1;
                height: 6px;
                background: #f0f0f0;
                border-radius: 3px;
                overflow: hidden;
            }
            
            .rbar-fill {
                height: 100%;
                background: linear-gradient(90deg, #f9ab00, #e37400);
                border-radius: 3px;
                transition: width .4s ease;
            }
            
            .rbar-count {
                width: 20px;
                text-align: right;
            }
            
            .pc-action {
                margin-top: 4px;
                display: flex;
                justify-content: flex-end;
            }
            /* ── Review list ── */
            
            .section-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 14px;
                flex-wrap: wrap;
                gap: 10px;
            }
            
            .section-title {
                font-size: 16px;
                font-weight: 700;
                color: #1a1a2e;
            }
            
            .review-list {
                display: flex;
                flex-direction: column;
                gap: 12px;
            }
            
            .review-card {
                border: 1px solid #e8eaed;
                border-radius: 10px;
                padding: 16px 18px;
                background: #fff;
                transition: box-shadow .18s;
            }
            
            .review-card:hover {
                box-shadow: 0 4px 14px rgba(0, 0, 0, .08);
            }
            
            .rc-header {
                display: flex;
                align-items: flex-start;
                gap: 12px;
                margin-bottom: 10px;
            }
            
            .avatar {
                width: 38px;
                height: 38px;
                border-radius: 50%;
                background: linear-gradient(135deg, #1a73e8, #0d47a1);
                color: #fff;
                font-size: 15px;
                font-weight: 700;
                display: flex;
                align-items: center;
                justify-content: center;
                flex-shrink: 0;
            }
            
            .rc-info {
                flex: 1;
            }
            
            .rc-reviewer {
                font-size: 14px;
                font-weight: 700;
                color: #1a1a2e;
            }
            
            .rc-date {
                font-size: 11px;
                color: #999;
                margin-top: 2px;
            }
            
            .rc-rating {
                display: flex;
                align-items: center;
                gap: 8px;
                margin-bottom: 6px;
            }
            
            .rc-body {
                font-size: 13px;
                color: #555;
                line-height: 1.5;
                margin-bottom: 10px;
                padding: 8px 12px;
                background: #f8f9fa;
                border-radius: 6px;
                border-left: 3px solid #e8eaed;
            }
            
            .rc-body.no-comment {
                color: #aaa;
                font-style: italic;
            }
            
            .rc-attr-count {
                font-size: 12px;
                color: #888;
                margin-bottom: 10px;
            }
            
            .rc-actions {
                display: flex;
                align-items: center;
                gap: 8px;
            }
            
            .badge {
                display: inline-flex;
                align-items: center;
                gap: 4px;
                background: #e8f0fe;
                color: #1a73e8;
                padding: 3px 10px;
                border-radius: 20px;
                font-size: 11px;
                font-weight: 700;
            }
            
            .badge-green {
                background: #e6f4ea;
                color: #34a853;
            }
            
            .badge-warn {
                background: #fef7e0;
                color: #b06000;
            }
            
            .badge-red {
                background: #fce8e6;
                color: #ea4335;
            }
            /* ── Review detail ── */
            
            .detail-hero {
                background: linear-gradient(135deg, #1a73e8 0%, #0d47a1 100%);
                border-radius: 12px;
                padding: 22px 24px;
                color: #fff;
                margin-bottom: 20px;
            }
            
            .dh-product {
                font-size: 12px;
                opacity: .8;
                margin-bottom: 4px;
                text-transform: uppercase;
                letter-spacing: .5px;
            }
            
            .dh-reviewer {
                font-size: 20px;
                font-weight: 800;
                margin-bottom: 6px;
            }
            
            .dh-meta {
                display: flex;
                align-items: center;
                gap: 14px;
                flex-wrap: wrap;
                font-size: 13px;
                opacity: .9;
            }
            
            .dh-comment {
                background: rgba(255, 255, 255, .15);
                border-radius: 8px;
                padding: 10px 14px;
                margin-top: 12px;
                font-size: 13px;
                line-height: 1.5;
            }
            
            .attr-detail-table {
                width: 100%;
                border-collapse: separate;
                border-spacing: 0 6px;
                font-size: 13px;
            }
            
            .attr-detail-table thead th {
                font-size: 11px;
                font-weight: 700;
                color: #888;
                text-transform: uppercase;
                letter-spacing: .5px;
                padding: 4px 14px;
                text-align: left;
            }
            
            .attr-detail-row td {
                padding: 10px 14px;
                background: #fff;
                border: 1px solid #e8eaed;
            }
            
            .attr-detail-row td:first-child {
                border-radius: 8px 0 0 8px;
                font-weight: 600;
                color: #1a1a2e;
            }
            
            .attr-detail-row td:last-child {
                border-radius: 0 8px 8px 0;
                color: #666;
            }
            
            .attr-detail-row:hover td {
                background: #f8f9fd;
            }
            /* ── Empty state ── */
            
            .empty-state {
                text-align: center;
                padding: 48px 24px;
                color: #aaa;
            }
            
            .empty-state .icon {
                font-size: 40px;
                margin-bottom: 10px;
            }
            
            .empty-state p {
                font-size: 14px;
            }
            /* ── Hint / section label ── */
            
            .hint {
                font-size: 12px;
                color: #888;
                font-style: italic;
                padding: 4px 0;
            }
            
            .section-label {
                font-size: 11px;
                font-weight: 700;
                color: #888;
                text-transform: uppercase;
                letter-spacing: .5px;
                margin: 14px 0 8px;
            }
            /* ── Loading spinner ── */
            
            .spinner {
                text-align: center;
                padding: 32px;
                color: #aaa;
                font-size: 13px;
            }
            /* ── Responsive ── */
            
            @media (max-width: 768px) {
                .layout {
                    flex-direction: column;
                }
                .panel-form {
                    position: static;
                    flex: none;
                    width: 100%;
                }
                .product-grid {
                    grid-template-columns: 1fr;
                }
            }
        </style>
    </head>

    <body>
        <div class="topbar">
            <span class="brand">&#128230; Product Manager</span>
            <nav>
                <a href="/">Trang ch&#7911;</a>
                <a href="/products/add">S&#7843;n ph&#7849;m</a>
                <a href="/feedback/stats" class="active">Ph&#7843;n h&#7891;i</a>
            </nav>
        </div>

        <div class="container">
            <div class="layout">

                <!-- ══ ONLY: 3 cấp thống kê (admin read-only) ══ -->
                <div class="panel-stats">

                    <!-- Breadcrumb -->
                    <div class="breadcrumb" id="breadcrumb"></div>

                    <!-- C&#7845;p 1: Danh s&#225;ch s&#7843;n ph&#7849;m + t&#7893;ng quan ph&#7843;n h&#7891;i -->
                    <div id="view-products" class="view"></div>

                    <!-- C&#7845;p 2: Danh s&#225;ch &#273;&#225;nh gi&#225; c&#7911;a m&#7897;t s&#7843;n ph&#7849;m -->
                    <div id="view-reviews" class="view" style="display:none;"></div>

                    <!-- C&#7845;p 3: Chi ti&#7871;t m&#7897;t &#273;&#225;nh gi&#225; theo t&#7915;ng thu&#7897;c t&#237;nh -->
                    <div id="view-detail" class="view" style="display:none;"></div>

                </div>
            </div>
        </div>

        <script>
            // ── Config ──────────────────────────────────────────────────────────
            // Khi vào trực tiếp feedback-service (:8082), phải dùng URL tuyệt đối
            // để gọi product-service (:8081). Khi qua gateway thì dùng URL tương đối.
            var _directFeedback = (location.port === '8083');
            var _productBase = _directFeedback ?
                (location.protocol + '//' + location.hostname + ':8081') :
                '';
            var PRODUCT_API = _productBase + '/api/products';
            var CATEGORY_API = _productBase + '/api/categories';
            var FEEDBACK_API = (location.origin || (location.protocol + '//' + location.host)) + '/api/feedbacks';

            // ── State ────────────────────────────────────────────────────────────
            var productsCache = []; // all products from product-service
            var categoriesCache = []; // all categories for dropdown filter
            var allFeedbacks = []; // all feedbacks loaded once
            var currentView = 'products'; // 'products' | 'reviews' | 'detail'
            var currentProduct = null; // { id, name, feedbacks[] }
            var currentFeedback = null; // full feedback object with attributeRatings
            var productSearchKeyword = ''; // keyword for level-1 product search
            var currentCategoryId = ''; // '' = tất cả danh mục
            var currentProductPage = 0; // current page index for product list (0-based)
            var PRODUCTS_PER_PAGE = 12; // number of product cards per page

            // ── Auth/data fetch helpers ──────────────────────────────────────────
            function forceLogin() {
                window.location.href = '/login';
            }

            function fetchJson(url, options) {
                if (!options) options = {};
                options.credentials = 'include';
                return fetch(url, options).then(function(r) {
                    if (r.redirected && r.url && r.url.indexOf('/login') !== -1) {
                        forceLogin();
                        throw new Error('Phiên đăng nhập đã hết hạn');
                    }
                    if (r.status === 401 || r.status === 403) {
                        forceLogin();
                        throw new Error('Bạn không có quyền truy cập');
                    }
                    var contentType = (r.headers.get('content-type') || '').toLowerCase();
                    if (!r.ok) {
                        return r.text().then(function(t) {
                            throw new Error(t || ('HTTP ' + r.status));
                        });
                    }
                    if (contentType.indexOf('application/json') === -1) {
                        throw new Error('Phản hồi không phải JSON hợp lệ');
                    }
                    return r.json();
                });
            }

            function fetchText(url, options) {
                if (!options) options = {};
                options.credentials = 'include';
                return fetch(url, options).then(function(r) {
                    if (r.redirected && r.url && r.url.indexOf('/login') !== -1) {
                        forceLogin();
                        throw new Error('Phiên đăng nhập đã hết hạn');
                    }
                    if (r.status === 401 || r.status === 403) {
                        forceLogin();
                        throw new Error('Bạn không có quyền truy cập');
                    }
                    if (!r.ok) {
                        return r.text().then(function(t) {
                            throw new Error(t || ('HTTP ' + r.status));
                        });
                    }
                    return r.text();
                });
            }

            // ── Utils ────────────────────────────────────────────────────────────
            function esc(s) {
                if (!s) return '';
                var d = document.createElement('div');
                d.appendChild(document.createTextNode(s));
                return d.innerHTML;
            }

            function starsHtml(n, total) {
                total = total || 5;
                var s = '';
                for (var i = 1; i <= total; i++) {
                    s += i <= n ?
                        '<span class="star">&#9733;</span>' :
                        '<span class="star-empty">&#9734;</span>';
                }
                return s;
            }

            function ratingBadge(n) {
                var cls = n >= 4 ? 'badge-green' : (n >= 3 ? 'badge-warn' : 'badge-red');
                return '<span class="badge ' + cls + '">' + starsHtml(n) + ' ' + n + '</span>';
            }

            function avatarInitial(name) {
                if (!name) return '?';
                return name.trim().charAt(0).toUpperCase();
            }

            function formatDate(str) {
                if (!str) return '';
                return str.substring(0, 16).replace('T', ' ');
            }

            function avg(arr) {
                if (!arr.length) return 0;
                return arr.reduce(function(s, x) {
                    return s + x.overallRating;
                }, 0) / arr.length;
            }

            // ── Load initial data ─────────────────────────────────────────────────
            Promise.all([
                fetchJson(PRODUCT_API),
                fetchJson(FEEDBACK_API),
                fetchJson(CATEGORY_API)
            ]).then(function(results) {
                productsCache = results[0];
                allFeedbacks = results[1];
                categoriesCache = results[2];

                renderProductsView();

            }).catch(function(e) {
                document.getElementById('view-products').innerHTML =
                    '<div class="card"><p style="color:#ea4335;font-size:13px;">&#9888; Không thể tải dữ liệu: ' + esc(e.message) + '</p></div>';
            });

            // ── View 1: Product summary cards ────────────────────────────────────
            function renderProductsView() {
                currentView = 'products';
                showView('products');

                // Build lookup: productId → categoryId từ productsCache
                var productCategoryMap = {};
                productsCache.forEach(function(p) {
                    productCategoryMap[p.id] = p.categoryId;
                });

                // Group feedbacks by productId
                var groups = {};
                allFeedbacks.forEach(function(f) {
                    var key = f.productId;
                    if (!groups[key]) {
                        groups[key] = {
                            id: f.productId,
                            name: f.productName,
                            categoryId: productCategoryMap[f.productId] || '',
                            feedbacks: []
                        };
                    }
                    groups[key].feedbacks.push(f);
                });

                // Products with no feedbacks too (và đảm bảo categoryId luôn có)
                productsCache.forEach(function(p) {
                    if (!groups[p.id]) {
                        groups[p.id] = {
                            id: p.id,
                            name: p.name,
                            categoryId: p.categoryId,
                            feedbacks: []
                        };
                    } else if (!groups[p.id].categoryId) {
                        groups[p.id].categoryId = p.categoryId;
                    }
                });

                var allProducts = Object.values(groups).sort(function(a, b) {
                    return b.feedbacks.length - a.feedbacks.length;
                });

                var keyword = (productSearchKeyword || '').trim().toLowerCase();
                var products = allProducts.filter(function(p) {
                    var nameMatch = !keyword || (p.name || '').toLowerCase().indexOf(keyword) !== -1;
                    var catMatch = !currentCategoryId || String(p.categoryId) === String(currentCategoryId);
                    return nameMatch && catMatch;
                });

                var el = document.getElementById('view-products');

                if (!allProducts.length) {
                    el.innerHTML = '<div class="card"><div class="empty-state"><div class="icon">&#128203;</div><p>Chưa có sản phẩm nào.</p></div></div>';
                    return;
                }

                var html = '<div class="card">';
                html += '<div class="card-title">&#128202; Tổng quan phản hồi <span style="margin-left:auto;font-weight:400;font-size:12px;color:#888;">' + products.length + '/' + allProducts.length + ' sản phẩm &bull; ' + allFeedbacks.length + ' đánh giá</span></div>';

                // ── Thanh tìm kiếm + lọc danh mục ──
                html += '<div style="display:flex;gap:10px;align-items:center;margin-bottom:10px;flex-wrap:wrap;">';
                html += '<input type="text" id="productSearchInput" placeholder="Tìm theo tên sản phẩm..." value="' + esc(productSearchKeyword) + '" style="flex:1;min-width:180px;padding:9px 12px;font-size:13px;border:1px solid #d0d7de;border-radius:8px;background:#fafbfc;" />';

                // Dropdown danh mục
                html += '<select id="categoryFilter" onchange="filterByCategory(this.value)" style="padding:9px 12px;font-size:13px;border:1px solid #d0d7de;border-radius:8px;background:#fafbfc;cursor:pointer;">';
                html += '<option value="">-- Tất cả danh mục --</option>';
                categoriesCache.forEach(function(cat) {
                    var sel = (String(cat.id) === String(currentCategoryId)) ? ' selected' : '';
                    html += '<option value="' + cat.id + '"' + sel + '>' + esc(cat.name) + '</option>';
                });
                html += '</select>';

                html += '<button class="btn-primary btn-sm" onclick="searchProductsByName()">Tìm kiếm</button>';
                html += '<button class="btn-secondary btn-sm" onclick="clearProductSearch()">Xóa lọc</button>';
                html += '</div>';

                if (!products.length) {
                    html += '<div class="empty-state"><div class="icon">&#128269;</div><p>Không tìm thấy sản phẩm phù hợp.</p></div>';
                    html += '</div>';
                    el.innerHTML = html;
                    attachProductSearchEvents();
                    updateBreadcrumb();
                    return;
                }

                // Pagination
                var totalPages = Math.ceil(products.length / PRODUCTS_PER_PAGE);
                if (currentProductPage >= totalPages) currentProductPage = totalPages - 1;
                var pageStart = currentProductPage * PRODUCTS_PER_PAGE;
                var paginated = products.slice(pageStart, pageStart + PRODUCTS_PER_PAGE);

                html += '<div class="product-grid">';

                paginated.forEach(function(prod) {
                    var count = prod.feedbacks.length;
                    var avgRating = count ? avg(prod.feedbacks) : 0;
                    var avgFixed = Math.round(avgRating * 10) / 10;

                    // Rating distribution [5,4,3,2,1]
                    var dist = {
                        5: 0,
                        4: 0,
                        3: 0,
                        2: 0,
                        1: 0
                    };
                    prod.feedbacks.forEach(function(f) {
                        dist[f.overallRating] = (dist[f.overallRating] || 0) + 1;
                    });

                    html += '<div class="product-card" onclick="renderReviewsView(' + prod.id + ')">';
                    html += '<div class="pc-name" title="' + esc(prod.name) + '">' + esc(prod.name) + '</div>';

                    if (count > 0) {
                        html += '<div class="pc-meta">';
                        html += '<div class="pc-avg">' + avgFixed.toFixed(1) + '</div>';
                        html += '<div class="pc-avg-right">' + starsHtml(Math.round(avgRating)) + '<div class="pc-count">' + count + ' đánh giá</div></div>';
                        html += '</div>';

                        html += '<div class="rating-bars">';
                        [5, 4, 3, 2, 1].forEach(function(star) {
                            var pct = count > 0 ? Math.round(dist[star] / count * 100) : 0;
                            html += '<div class="rbar-row"><span class="rbar-label">' + star + '</span><div class="rbar-track"><div class="rbar-fill" style="width:' + pct + '%"></div></div><span class="rbar-count">' + (dist[star] || 0) + '</span></div>';
                        });
                        html += '</div>';
                    } else {
                        html += '<div style="padding:18px 0;text-align:center;color:#bbb;font-size:12px;">Chưa có đánh giá</div>';
                    }

                    html += '<div class="pc-action">';
                    if (count > 0) {
                        html += '<button class="btn-primary btn-sm" onclick="event.stopPropagation();renderReviewsView(' + prod.id + ')">Xem ' + count + ' phản hồi &rsaquo;</button>';
                    } else {
                        html += '<span style="font-size:12px;color:#bbb;">Chưa có phản hồi</span>';
                    }
                    html += '</div>';
                    html += '</div>'; // .product-card
                });

                html += '</div>';

                // Pagination controls
                if (totalPages > 1) {
                    html += '<div style="display:flex;align-items:center;justify-content:center;gap:6px;margin-top:20px;flex-wrap:wrap;">';
                    html += '<button class="btn-secondary btn-sm" onclick="goToProductPage(' + (currentProductPage - 1) + ')" ' + (currentProductPage === 0 ? 'disabled' : '') + '>&#8592; Trước</button>';

                    // Page number buttons — show max 7 pages around current
                    var start = Math.max(0, currentProductPage - 3);
                    var end = Math.min(totalPages - 1, currentProductPage + 3);
                    if (start > 0) html += '<button class="btn-secondary btn-sm" onclick="goToProductPage(0)">1</button>' + (start > 1 ? '<span style="padding:0 4px;color:#888;">…</span>' : '');
                    for (var pi = start; pi <= end; pi++) {
                        var active = pi === currentProductPage;
                        html += '<button class="' + (active ? 'btn-primary' : 'btn-secondary') + ' btn-sm" onclick="goToProductPage(' + pi + ')">' + (pi + 1) + '</button>';
                    }
                    if (end < totalPages - 1) html += (end < totalPages - 2 ? '<span style="padding:0 4px;color:#888;">…</span>' : '') + '<button class="btn-secondary btn-sm" onclick="goToProductPage(' + (totalPages - 1) + ')">' + totalPages + '</button>';

                    html += '<button class="btn-secondary btn-sm" onclick="goToProductPage(' + (currentProductPage + 1) + ')" ' + (currentProductPage === totalPages - 1 ? 'disabled' : '') + '>Sau &#8594;</button>';
                    html += '<span style="font-size:12px;color:#888;margin-left:8px;">Trang ' + (currentProductPage + 1) + '/' + totalPages + ' &bull; ' + products.length + ' sản phẩm</span>';
                    html += '</div>';
                }

                html += '</div>';
                el.innerHTML = html;
                attachProductSearchEvents();
                updateBreadcrumb();
            }

            function searchProductsByName() {
                var input = document.getElementById('productSearchInput');
                productSearchKeyword = input ? input.value.trim() : '';
                currentProductPage = 0;
                renderProductsView();
            }

            function clearProductSearch() {
                productSearchKeyword = '';
                currentCategoryId = '';
                currentProductPage = 0;
                renderProductsView();
            }

            function filterByCategory(catId) {
                currentCategoryId = catId;
                currentProductPage = 0;
                renderProductsView();
            }

            function goToProductPage(page) {
                currentProductPage = page;
                renderProductsView();
                document.getElementById('view-products').scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }

            function attachProductSearchEvents() {
                var input = document.getElementById('productSearchInput');
                if (!input) return;
                input.addEventListener('keydown', function(e) {
                    if (e.key === 'Enter') searchProductsByName();
                });
            }

            // ── View 2: Reviews of a product ─────────────────────────────────────
            function renderReviewsView(productId) {
                currentView = 'reviews';

                // Find product info
                var group = null;
                var groups = {};
                allFeedbacks.forEach(function(f) {
                    if (!groups[f.productId]) groups[f.productId] = {
                        id: f.productId,
                        name: f.productName,
                        feedbacks: []
                    };
                    groups[f.productId].feedbacks.push(f);
                });
                productsCache.forEach(function(p) {
                    if (!groups[p.id]) groups[p.id] = {
                        id: p.id,
                        name: p.name,
                        feedbacks: []
                    };
                });
                group = groups[productId];
                if (!group) return;

                // Sort feedbacks newest first
                var reviews = group.feedbacks.slice().sort(function(a, b) {
                    return (b.createdAt || '').localeCompare(a.createdAt || '');
                });

                currentProduct = group;
                showView('reviews');

                var avgRating = reviews.length ? avg(reviews) : 0;
                var el = document.getElementById('view-reviews');

                var html = '<div class="card">';

                // Header
                html += '<div class="section-header">';
                html += '<div><div class="section-title">' + esc(group.name) + '</div>';
                if (reviews.length) {
                    html += '<div style="font-size:12px;color:#888;margin-top:4px;">' + starsHtml(Math.round(avgRating)) + ' ' + avg(reviews).toFixed(1) + '/5 &bull; ' + reviews.length + ' đánh giá</div>';
                }
                html += '</div>';
                html += '<button class="btn-secondary btn-sm" onclick="renderProductsView()">&#8592; Quay lại</button>';
                html += '</div>';

                if (!reviews.length) {
                    html += '<div class="empty-state"><div class="icon">&#128172;</div><p>Sản phẩm này chưa có phản hồi nào.</p></div>';
                    html += '</div>';
                    el.innerHTML = html;
                    updateBreadcrumb();
                    return;
                }

                html += '<div class="review-list">';
                reviews.forEach(function(f) {
                    var attrCount = (f.attributeRatings ? f.attributeRatings.length : 0);
                    html += '<div class="review-card">';
                    html += '<div class="rc-header">';
                    html += '<div class="avatar">' + esc(avatarInitial(f.reviewer)) + '</div>';
                    html += '<div class="rc-info">';
                    html += '<div class="rc-reviewer">' + esc(f.reviewer) + '</div>';
                    html += '<div class="rc-date">&#128337; ' + formatDate(f.createdAt) + '</div>';
                    html += '</div>';
                    html += '<div>' + ratingBadge(f.overallRating) + '</div>';
                    html += '</div>'; // rc-header

                    if (f.comment) {
                        html += '<div class="rc-body">' + esc(f.comment) + '</div>';
                    } else {
                        html += '<div class="rc-body no-comment">Không có nhận xét chung</div>';
                    }

                    if (attrCount > 0) {
                        html += '<div class="rc-attr-count">&#128203; ' + attrCount + ' thuộc tính được đánh giá</div>';
                    }

                    html += '<div class="rc-actions">';
                    html += '<button class="btn-primary btn-sm" onclick="renderDetailView(' + f.id + ')">Xem chi tiết &rsaquo;</button>';
                    html += ' <button class="btn-danger btn-sm" onclick="delFeedback(' + f.id + ', ' + productId + ')">Xóa</button>';
                    html += '</div>';
                    html += '</div>'; // review-card
                });

                html += '</div></div>';
                el.innerHTML = html;
                updateBreadcrumb();
                document.getElementById('view-reviews').scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }

            // ── View 3: Single review detail ─────────────────────────────────────
            function renderDetailView(feedbackId) {
                currentView = 'detail';
                showView('detail');
                var el = document.getElementById('view-detail');
                el.innerHTML = '<div class="spinner">&#8635; Đang tải chi tiết...</div>';
                updateBreadcrumb();

                fetchJson(FEEDBACK_API + '/' + feedbackId).then(function(f) {
                    currentFeedback = f;
                    updateBreadcrumb();

                    var html = '';

                    // Hero card
                    html += '<div class="detail-hero">';
                    html += '<div class="dh-product">&#128230; ' + esc(f.productName) + '</div>';
                    html += '<div class="dh-reviewer">' + esc(f.reviewer) + '</div>';
                    html += '<div class="dh-meta">';
                    html += '<span>' + starsHtml(f.overallRating) + ' ' + f.overallRating + '/5 sao</span>';
                    html += '<span>&#128337; ' + formatDate(f.createdAt) + '</span>';
                    html += '<span>Phản hồi #' + f.id + '</span>';
                    html += '</div>';
                    if (f.comment) {
                        html += '<div class="dh-comment">&#8220; ' + esc(f.comment) + ' &#8221;</div>';
                    }
                    html += '</div>'; // detail-hero

                    html += '<div class="card">';
                    html += '<div class="section-header">';
                    html += '<div class="section-title">&#128203; Đánh giá chi tiết theo thuộc tính</div>';
                    html += '<button class="btn-secondary btn-sm" onclick="renderReviewsView(' + f.productId + ')">&#8592; Quay lại</button>';
                    html += '</div>';

                    if (f.attributeRatings && f.attributeRatings.length) {
                        html += '<table class="attr-detail-table">';
                        html += '<thead><tr><th>Thuộc tính</th><th>Điểm</th><th>Nhận xét</th></tr></thead>';
                        html += '<tbody>';
                        f.attributeRatings.forEach(function(ar) {
                            var starClass = ar.rating >= 4 ? 'badge-green' : (ar.rating >= 3 ? 'badge-warn' : 'badge-red');
                            html += '<tr class="attr-detail-row">';
                            html += '<td><b>' + esc(ar.attributeName) + '</b></td>';
                            html += '<td><span class="badge ' + starClass + '">' + starsHtml(ar.rating) + ' ' + ar.rating + '</span></td>';
                            html += '<td>' + (ar.comment ? esc(ar.comment) : '<span style="color:#bbb;font-style:italic;">Không có nhận xét</span>') + '</td>';
                            html += '</tr>';
                        });
                        html += '</tbody></table>';
                    } else {
                        html += '<div class="empty-state"><div class="icon">&#128203;</div><p>Phản hồi này chưa có đánh giá theo từng thuộc tính.</p></div>';
                    }

                    html += '</div>'; // card

                    el.innerHTML = html;
                    el.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });

                }).catch(function(e) {
                    el.innerHTML = '<div class="card"><p style="color:#ea4335;">Không thể tải chi tiết: ' + esc(e.message) + '</p></div>';
                });
            }

            // ── Show/hide views ───────────────────────────────────────────────────
            function showView(name) {
                document.getElementById('view-products').style.display = (name === 'products') ? '' : 'none';
                document.getElementById('view-reviews').style.display = (name === 'reviews') ? '' : 'none';
                document.getElementById('view-detail').style.display = (name === 'detail') ? '' : 'none';
            }

            // ── Breadcrumb ────────────────────────────────────────────────────────
            function updateBreadcrumb() {
                var el = document.getElementById('breadcrumb');
                var html = '<span class="breadcrumb-item" onclick="renderProductsView()">&#128202; Tất cả sản phẩm</span>';

                if (currentView === 'reviews' && currentProduct) {
                    html += '<span class="breadcrumb-sep">&#8250;</span>';
                    html += '<span class="breadcrumb-item current">' + esc(currentProduct.name) + '</span>';
                }

                if (currentView === 'detail' && currentProduct) {
                    html += '<span class="breadcrumb-sep">&#8250;</span>';
                    html += '<span class="breadcrumb-item" onclick="renderReviewsView(' + currentProduct.id + ')">' + esc(currentProduct.name) + '</span>';
                    if (currentFeedback) {
                        html += '<span class="breadcrumb-sep">&#8250;</span>';
                        html += '<span class="breadcrumb-item current">Phản hồi #' + currentFeedback.id + ' &mdash; ' + esc(currentFeedback.reviewer) + '</span>';
                    }
                }

                el.innerHTML = html;
            }

            // Chế độ admin read-only: không hỗ trợ form gửi phản hồi.

            // ── Delete feedback ────────────────────────────────────────────────────
            function delFeedback(id, productId) {
                if (!confirm('Xóa phản hồi #' + id + '?')) return;
                fetchText(FEEDBACK_API + '/' + id, {
                    method: 'DELETE'
                }).then(function() {
                    allFeedbacks = allFeedbacks.filter(function(f) {
                        return f.id !== id;
                    });
                    if (currentView === 'reviews') renderReviewsView(productId);
                    else renderProductsView();
                }).catch(function(e) {
                    alert('Lỗi: ' + e.message);
                });
            }
        </script>
    </body>

    </html>