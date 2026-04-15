package com.example.product.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpSession;

@Controller
public class LoginController {

    private static final Logger log = LoggerFactory.getLogger(LoginController.class);

    private static final String ADMIN_USERNAME = "admin";
    private static final String ADMIN_PASSWORD = "admin123";
    private static final String SESSION_KEY    = "adminLoggedIn";

    @GetMapping("/login")
    public String showLogin(HttpSession session) {
        if (Boolean.TRUE.equals(session.getAttribute(SESSION_KEY))) {
            return "redirect:/";
        }
        return "login";
    }

    @PostMapping("/login")
    public String doLogin(@RequestParam String username,
                          @RequestParam String password,
                          HttpSession session,
                          Model model) {
        if (ADMIN_USERNAME.equals(username) && ADMIN_PASSWORD.equals(password)) {
            session.setAttribute(SESSION_KEY, Boolean.TRUE);
            log.info("[AUTH] Admin logged in successfully");
            return "redirect:/";
        }
        log.warn("[AUTH] Failed login attempt for username='{}'", username);
        model.addAttribute("hasError", Boolean.TRUE);
        return "login";
    }

    @GetMapping("/logout")
    public String doLogout(HttpSession session) {
        session.invalidate();
        log.info("[AUTH] Admin logged out");
        return "redirect:/login";
    }
}
