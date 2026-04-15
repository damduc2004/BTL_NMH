package com.example.user.config;

import com.example.user.entity.Customer;
import com.example.user.entity.User;
import com.example.user.repository.CustomerRepository;
import com.example.user.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DataSeeder {

    @Bean
    public CommandLineRunner initUsers(UserRepository userRepository,
                                       CustomerRepository customerRepository) {
        return args -> {
            if (userRepository.findByUsername("admin").isEmpty()) {
                userRepository.save(User.builder()
                    .username("admin")
                    .password("admin123")
                    .fullName("Administrator")
                    .email("admin@example.com")
                    .phone("1234567890")
                    .role("ADMIN")
                    .status(1)
                    .build());
            }

            if (userRepository.findByUsername("manager1").isEmpty()) {
                userRepository.save(User.builder()
                    .username("manager1")
                    .password("manager123")
                    .fullName("Product Manager 1")
                    .email("manager1@example.com")
                    .phone("0987654321")
                    .role("ADMIN")
                    .status(1)
                    .build());
            }

            if (customerRepository.findAll().isEmpty()) {
                customerRepository.save(Customer.builder()
                    .username("customer1")
                    .password("customer123")
                    .fullName("Nguyen Van A")
                    .email("nguyenvana@example.com")
                    .phone("0901234567")
                    .role("CUSTOMER")
                    .status(1)
                    .build());

                customerRepository.save(Customer.builder()
                    .username("customer2")
                    .password("customer123")
                    .fullName("Tran Thi B")
                    .email("tranthib@example.com")
                    .phone("0912345678")
                    .role("CUSTOMER")
                    .status(1)
                    .build());

                customerRepository.save(Customer.builder()
                    .username("customer3")
                    .password("customer123")
                    .fullName("Le Van C")
                    .email("levanc@example.com")
                    .phone("0923456789")
                    .role("CUSTOMER")
                    .status(1)
                    .build());
            }
        };
    }
}
