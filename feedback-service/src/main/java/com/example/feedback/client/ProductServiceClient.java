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

import com.example.feedback.dto.AttributeDto;
import com.example.feedback.dto.ProductDto;

/**
 * Client goi sang product-service de lay thong tin san pham.
 * Duoc su dung khi feedback-service can xac minh san pham ton tai
 * va lay ten chinh xac truoc khi luu phan hoi.
 */
@Component
public class ProductServiceClient {

    private static final Logger log = LoggerFactory.getLogger(ProductServiceClient.class);

    @Value("${product-service.url}")
    private String productServiceUrl;

    private final RestTemplate restTemplate;

    public ProductServiceClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    /**
     * Goi GET /api/products/{id} tren product-service de lay thong tin san pham.
     *
     * @param productId ID san pham can tra cuu
     * @return ProductDto neu thanh cong, null neu loi hoac khong tim thay
     */
    public ProductDto getProduct(Long productId) {
        String correlationId = UUID.randomUUID().toString();
        String url = productServiceUrl + "/api/products/" + productId;
        log.info("[INTER-SERVICE] [CID:{}] feedback-service → product-service | GET {} | productId={}",
                correlationId, url, productId);
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set("X-Correlation-ID", correlationId);
            HttpEntity<Void> entity = new HttpEntity<>(headers);
            ResponseEntity<ProductDto> response = restTemplate.exchange(url, HttpMethod.GET, entity, ProductDto.class);
            ProductDto product = response.getBody();
            if (product != null) {
                log.info("[INTER-SERVICE] [CID:{}] product-service tra ve | id={}, name='{}'",
                        correlationId, product.getId(), product.getName());
            } else {
                log.warn("[INTER-SERVICE] [CID:{}] product-service tra ve null cho productId={}", correlationId, productId);
            }
            return product;
        } catch (Exception e) {
            log.error("[INTER-SERVICE] [CID:{}] Loi khi goi product-service | productId={} | Loi: {}",
                    correlationId, productId, e.getMessage());
            return null;
        }
    }

    /**
     * Goi GET /api/products/attributes/{id} tren product-service de lay thong tin thuoc tinh.
     *
     * @param attributeId ID thuoc tinh can tra cuu
     * @return AttributeDto neu thanh cong, null neu loi hoac khong tim thay
     */
    public AttributeDto getAttribute(Long attributeId) {
        String correlationId = UUID.randomUUID().toString();
        String url = productServiceUrl + "/api/products/attributes/" + attributeId;
        log.debug("[INTER-SERVICE] [CID:{}] feedback-service → product-service | GET {} | attributeId={}",
                correlationId, url, attributeId);
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set("X-Correlation-ID", correlationId);
            HttpEntity<Void> entity = new HttpEntity<>(headers);
            ResponseEntity<AttributeDto> response = restTemplate.exchange(url, HttpMethod.GET, entity, AttributeDto.class);
            AttributeDto attribute = response.getBody();
            if (attribute != null) {
                log.debug("[INTER-SERVICE] [CID:{}] product-service tra ve | attributeId={}, name='{}'",
                        correlationId, attribute.getId(), attribute.getName());
            } else {
                log.warn("[INTER-SERVICE] [CID:{}] product-service tra ve null cho attributeId={}", correlationId, attributeId);
            }
            return attribute;
        } catch (Exception e) {
            log.warn("[INTER-SERVICE] [CID:{}] Loi khi goi product-service/attributes | attributeId={} | Loi: {}",
                    correlationId, attributeId, e.getMessage());
            return null;
        }
    }
}
