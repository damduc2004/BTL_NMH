<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng nhập – Product Manager</title>
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
                background: linear-gradient(135deg, #1a73e8 0%, #0d47a1 100%);
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            
            .login-card {
                background: #fff;
                border-radius: 16px;
                box-shadow: 0 8px 40px rgba(0, 0, 0, .25);
                padding: 48px 40px 40px;
                width: 360px;
            }
            
            .login-logo {
                text-align: center;
                font-size: 40px;
                margin-bottom: 8px;
            }
            
            .login-title {
                text-align: center;
                font-size: 22px;
                font-weight: 700;
                color: #1a1a2e;
                margin-bottom: 4px;
            }
            
            .login-sub {
                text-align: center;
                font-size: 13px;
                color: #888;
                margin-bottom: 32px;
            }
            
            label {
                display: block;
                font-size: 12px;
                font-weight: 600;
                color: #555;
                text-transform: uppercase;
                letter-spacing: .4px;
                margin-bottom: 6px;
                margin-top: 18px;
            }
            
            label:first-of-type {
                margin-top: 0;
            }
            
            input[type=text],
            input[type=password] {
                width: 100%;
                padding: 11px 14px;
                font-size: 14px;
                border: 1px solid #d0d7de;
                border-radius: 8px;
                background: #fafbfc;
                outline: none;
                transition: border-color .2s, box-shadow .2s;
            }
            
            input[type=text]:focus,
            input[type=password]:focus {
                border-color: #1a73e8;
                box-shadow: 0 0 0 3px rgba(26, 115, 232, .12);
                background: #fff;
            }
            
            .btn-login {
                width: 100%;
                margin-top: 28px;
                padding: 12px;
                font-size: 15px;
                font-weight: 700;
                background: #1a73e8;
                color: #fff;
                border: none;
                border-radius: 8px;
                cursor: pointer;
                transition: background .2s;
            }
            
            .btn-login:hover {
                background: #1557b0;
            }
            
            .error-msg {
                margin-top: 16px;
                padding: 10px 14px;
                background: #fce8e6;
                border-left: 4px solid #ea4335;
                color: #a50e0e;
                font-size: 13px;
                border-radius: 6px;
            }
            
            .hint {
                margin-top: 20px;
                text-align: center;
                font-size: 12px;
                color: #aaa;
            }
        </style>
    </head>

    <body>
        <div class="login-card">
            <div class="login-logo">📦</div>
            <div class="login-title">Product Manager</div>
            <div class="login-sub">Hệ thống chỉ dành cho quản trị viên (ADMIN)</div>

            <form action="/login" method="POST">
                <label for="username">Tên đăng nhập</label>
                <input type="text" id="username" name="username" placeholder="Nhập username..." autocomplete="username" required>

                <label for="password">Mật khẩu</label>
                <input type="password" id="password" name="password" placeholder="Nhập mật khẩu..." autocomplete="current-password" required>

                <button type="submit" class="btn-login">Đăng nhập</button>
            </form>

            <% if (Boolean.TRUE.equals(request.getAttribute("hasError"))) { %>
                <div class="error-msg">⚠ Tên đăng nhập hoặc mật khẩu không đúng.</div>
                <% } %>

                    <div class="hint">Demo: admin / admin123</div>
        </div>
    </body>

    </html>