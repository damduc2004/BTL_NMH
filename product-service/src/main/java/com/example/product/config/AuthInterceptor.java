package com.example.product.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * Bảo vệ các endpoint admin (POST/DELETE /api/products và trang /products/**).
 * Cho phép tất cả GET /api/products, /api/categories công khai.
 */
@Component
public class AuthInterceptor implements HandlerInterceptor {

    private static final Logger log = LoggerFactory.getLogger(AuthInterceptor.class);
    private static final String SESSION_KEY = "adminLoggedIn";

    @Override
    public boolean preHandle(HttpServletRequest request,
                              HttpServletResponse response,
                              Object handler) throws Exception {
        String path   = request.getRequestURI();
        String method = request.getMethod();

        // ⚠️ DEV MODE: Chi phép tất cả (bỏ hết auth)
        log.info("[DEV] Allow all: {} {}", method, path);
        return true;
    }
}
