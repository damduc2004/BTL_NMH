package com.example.feedback.client;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import com.example.feedback.dto.CustomerDto;

@Component
public class UserServiceClient {

    private static final Logger log = LoggerFactory.getLogger(UserServiceClient.class);

    @Value("${user-service.url}")
    private String userServiceUrl;

    private final RestTemplate restTemplate;

    public UserServiceClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public CustomerDto getCustomer(Long customerId) {
        String url = userServiceUrl + "/api/customers/" + customerId;
        log.info("[INTER-SERVICE] feedback-service → user-service | GET {} | customerId={}", url, customerId);
        try {
            CustomerDto customer = restTemplate.getForObject(url, CustomerDto.class);
            if (customer != null) {
                log.info("[INTER-SERVICE] user-service tra ve | customerId={}, fullName='{}'",
                        customerId, customer.getFullName());
            }
            return customer;
        } catch (Exception e) {
            log.error("[INTER-SERVICE] Loi khi goi user-service | customerId={} | Loi: {}", customerId, e.getMessage());
            return null;
        }
    }
}
