<%@ page contentType="text/html;charset=UTF-8" language="java" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Trang chủ Admin – Product Manager</title>
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
                    
                    .container {
                        max-width: 900px;
                        margin: 60px auto;
                        padding: 0 24px;
                        text-align: center;
                    }
                    
                    .welcome {
                        font-size: 26px;
                        font-weight: 700;
                        color: #1a1a2e;
                        margin-bottom: 8px;
                    }
                    
                    .welcome-sub {
                        font-size: 14px;
                        color: #666;
                        margin-bottom: 48px;
                    }
                    
                    .cards {
                        display: flex;
                        gap: 28px;
                        justify-content: center;
                        flex-wrap: wrap;
                    }
                    
                    .card {
                        background: #fff;
                        border-radius: 16px;
                        box-shadow: 0 2px 16px rgba(0, 0, 0, .10);
                        padding: 40px 32px;
                        width: 300px;
                        text-decoration: none;
                        color: inherit;
                        transition: transform .2s, box-shadow .2s;
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        text-align: center;
                        border: 2px solid transparent;
                    }
                    
                    .card:hover {
                        transform: translateY(-6px);
                        box-shadow: 0 12px 32px rgba(0, 0, 0, .15);
                    }
                    
                    .card.blue:hover {
                        border-color: #1a73e8;
                    }
                    
                    .card.green:hover {
                        border-color: #34a853;
                    }
                    
                    .card .icon {
                        width: 72px;
                        height: 72px;
                        border-radius: 50%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 32px;
                        margin-bottom: 20px;
                    }
                    
                    .card.blue .icon {
                        background: #e8f0fe;
                    }
                    
                    .card.green .icon {
                        background: #e6f4ea;
                    }
                    
                    .card h3 {
                        font-size: 17px;
                        font-weight: 700;
                        margin-bottom: 10px;
                    }
                    
                    .card p {
                        font-size: 13px;
                        color: #666;
                        line-height: 1.7;
                    }
                    
                    .card .btn {
                        margin-top: 24px;
                        padding: 10px 26px;
                        border-radius: 8px;
                        border: none;
                        font-size: 13px;
                        font-weight: 700;
                        cursor: pointer;
                        text-decoration: none;
                        display: inline-block;
                        transition: background .2s;
                    }
                    
                    .card.blue .btn {
                        background: #1a73e8;
                        color: #fff;
                    }
                    
                    .card.blue .btn:hover {
                        background: #1558b0;
                    }
                    
                    .card.green .btn {
                        background: #34a853;
                        color: #fff;
                    }
                    
                    .card.green .btn:hover {
                        background: #2a8a44;
                    }
                    
                    footer {
                        text-align: center;
                        margin-top: 80px;
                        font-size: 12px;
                        color: #bbb;
                        padding-bottom: 32px;
                    }
                </style>
            </head>

            <body>
                <div class="topbar">
                    <span class="brand">📦 Product Manager</span>
                    <div class="user-info">
                        <span class="name">👤 Admin</span>
                        <a href="/logout" class="btn-logout">Đăng xuất</a>
                    </div>
                </div>

                <div class="container">
                    <div class="welcome">Chào mừng,
                        Admin!</div>
                    <div class="welcome-sub">Hệ thống quản lý sản phẩm và thống kê phản hồi khách hàng</div>

                    <div class="cards">
                        <a href="/products/add" class="card blue">
                            <div class="icon">📦</div>
                            <h3>Quản lý sản phẩm</h3>
                            <p>Tìm kiếm, thêm mới, xóa sản phẩm. Gán danh mục và thuộc tính chi tiết cho từng sản phẩm.</p>
                            <span class="btn">Quản lý sản phẩm</span>
                        </a>
                        <a id="feedbackLink" href="/feedback/stats" class="card green">
                            <div class="icon">⭐</div>
                            <h3>Thống kê phản hồi</h3>
                            <p>Xem thống kê phản hồi của khách hàng. Chi tiết điểm đánh giá theo từng thuộc tính sản phẩm.</p>
                            <span class="btn">Xem thống kê</span>
                        </a>
                    </div>
                </div>

                <footer>Product Manager &copy; 2026</footer>
                <script>
                    // Khi truy cập trực tiếp product-service (:8081), điều hướng feedback sang :8082
                    (function() {
                        if (location.port === '8081') {
                            document.getElementById('feedbackLink').href =
                                location.protocol + '//' + location.hostname + ':8082/feedback/stats';
                        }
                    })();
                </script>
            </body>

            </html>
            * {