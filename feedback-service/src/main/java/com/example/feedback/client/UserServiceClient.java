package com.example.feedback.client;

import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
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
        String correlationId = UUID.randomUUID().toString();
        String url = userServiceUrl + "/api/customers/" + customerId;
        log.info("[INTER-SERVICE] [CID:{}] feedback-service → user-service | GET {} | customerId={}",
                correlationId, url, customerId);
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set("X-Correlation-ID", correlationId);
            HttpEntity<Void> entity = new HttpEntity<>(headers);
            ResponseEntity<CustomerDto> response = restTemplate.exchange(url, HttpMethod.GET, entity, CustomerDto.class);
            CustomerDto customer = response.getBody();
            if (customer != null) {
                log.info("[INTER-SERVICE] [CID:{}] user-service tra ve | customerId={}, fullName='{}'",
                        correlationId, customerId, customer.getFullName());
            } else {
                log.warn("[INTER-SERVICE] [CID:{}] user-service tra ve null cho customerId={}", correlationId, customerId);
            }
            return customer;
        } catch (Exception e) {
            log.error("[INTER-SERVICE] [CID:{}] Loi khi goi user-service | customerId={} | Loi: {}",
                    correlationId, customerId, e.getMessage());
            return null;
        }
    }
}
