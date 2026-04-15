package com.example.user.controller;

import com.example.user.dto.UserResponse;
import com.example.user.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping("/users/{id}")
    public ResponseEntity<UserResponse> getUserById(@PathVariable Long id) {
        return ResponseEntity.ok(userService.getUserById(id));
    }

    @GetMapping("/customers")
    public ResponseEntity<List<UserResponse>> getAllCustomers() {
        return ResponseEntity.ok(userService.getAllCustomers());
    }

    @GetMapping("/customers/{id}")
    public ResponseEntity<UserResponse> getCustomerById(@PathVariable Long id) {
        return ResponseEntity.ok(userService.getCustomerById(id));
    }

    @GetMapping("/users/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("User Service is running");
    }
}
