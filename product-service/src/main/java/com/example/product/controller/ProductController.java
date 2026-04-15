package com.example.product.controller;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.product.dto.AttributeResponseDto;
import com.example.product.dto.ProductCreateRequest;
import com.example.product.dto.ProductResponse;
import com.example.product.service.ProductService;

import jakarta.servlet.http.HttpServletRequest;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    private static final Logger log = LoggerFactory.getLogger(ProductController.class);

    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping
    public List<ProductResponse> getAllProducts(@RequestParam(required = false) String keyword) {
        if (keyword != null && !keyword.trim().isEmpty()) {
            log.info("GET /api/products?keyword='{}'", keyword);
            return productService.searchProducts(keyword);
        }
        log.info("GET /api/products");
        return productService.getAllProducts();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProductResponse> getProductById(@PathVariable Long id,
                                                          HttpServletRequest request) {
        String correlationId = request.getHeader("X-Correlation-ID");
        log.info("[INTER-SERVICE] [CID:{}] GET /api/products/{} - duoc goi tu feedback-service",
                correlationId != null ? correlationId : "N/A", id);
        ProductResponse response = productService.getProductById(id);
        return ResponseEntity.ok(response);
    }

    @PostMapping
    public ResponseEntity<ProductResponse> createProduct(@RequestBody ProductCreateRequest request) {
        log.info("[ADMIN] POST /api/products - tao san pham | name='{}', categoryId={}",
                request.getName(), request.getCategoryId());
        ProductResponse response = productService.createProduct(request);
        log.info("[ADMIN] POST /api/products - tao thanh cong | id={}", response.getId());
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        log.info("[ADMIN] DELETE /api/products/{} - xoa san pham", id);
        productService.deleteProduct(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/attributes/{id}")
    public ResponseEntity<AttributeResponseDto> getAttributeById(@PathVariable Long id,
                                                         HttpServletRequest request) {
        String correlationId = request.getHeader("X-Correlation-ID");
        log.info("[INTER-SERVICE] [CID:{}] GET /api/products/attributes/{} - lay thong tin thuoc tinh",
                correlationId != null ? correlationId : "N/A", id);
        AttributeResponseDto response = productService.getAttributeById(id);
        if (response == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(response);
    }
}
