package com.example.user.service;

import com.example.user.entity.Customer;
import com.example.user.entity.User;
import com.example.user.dto.UserResponse;
import com.example.user.repository.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    @Autowired
    private CustomerRepository customerRepository;

    public UserResponse getCustomerById(Long id) {
        Customer customer = customerRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Customer not found with ID: " + id));
        if (customer.getStatus() == 0) {
            throw new RuntimeException("Customer is inactive");
        }
        return mapToResponse(customer);
    }

    private UserResponse mapToResponse(User user) {
        return UserResponse.builder()
            .id(user.getId())
            .username(user.getUsername())
            .fullName(user.getFullName())
            .email(user.getEmail())
            .phone(user.getPhone())
            .status(user.getStatus())
            .userType(user instanceof Customer ? "CUSTOMER" : "ADMIN")
            .createdAt(user.getCreatedAt())
            .build();
    }
}
