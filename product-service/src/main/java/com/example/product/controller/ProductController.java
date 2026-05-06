package com.example.product.controller;

import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
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

import com.example.product.entity.Attribute;
import com.example.product.entity.Product;
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
    public Page<Product> getProducts(
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        log.info("GET /api/products keyword='{}' page={} size={}", keyword, page, size);
        return productService.getProducts(keyword, page, size);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Long id, HttpServletRequest request) {
        String cid = request.getHeader("X-Correlation-ID");
        log.info("[INTER-SERVICE] [CID:{}] GET /api/products/{}", cid != null ? cid : "N/A", id);
        return ResponseEntity.ok(productService.getProductById(id));
    }

    @PostMapping
    public ResponseEntity<Product> createProduct(@RequestBody Map<String, Object> request) {
        log.info("[ADMIN] POST /api/products name='{}'", request.get("name"));
        Product created = productService.createProduct(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        log.info("[ADMIN] DELETE /api/products/{}", id);
        productService.deleteProduct(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/attributes/{id}")
    public ResponseEntity<Attribute> getAttributeById(@PathVariable Long id, HttpServletRequest request) {
        String cid = request.getHeader("X-Correlation-ID");
        log.info("[INTER-SERVICE] [CID:{}] GET /api/products/attributes/{}", cid != null ? cid : "N/A", id);
        Attribute attr = productService.getAttributeById(id);
        return attr != null ? ResponseEntity.ok(attr) : ResponseEntity.notFound().build();
    }
}
