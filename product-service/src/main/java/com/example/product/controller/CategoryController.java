package com.example.product.controller;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.product.entity.Category;
import com.example.product.repository.CategoryRepository;

@RestController
@RequestMapping("/api/categories")
public class CategoryController {

    private static final Logger log = LoggerFactory.getLogger(CategoryController.class);

    private final CategoryRepository categoryRepository;

    public CategoryController(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    @GetMapping
    public List<Map<String, Object>> getAllCategories() {
        log.info("GET /api/categories");
        return categoryRepository.findAll().stream()
                .map(c -> Map.<String, Object>of("id", c.getId(), "name", c.getName()))
                .collect(Collectors.toList());
    }

    @GetMapping("/{id}/attributes")
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getCategoryAttributes(@PathVariable Long id) {
        log.info("GET /api/categories/{}/attributes", id);
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> {
                    log.warn("Category not found: id={}", id);
                    return new IllegalArgumentException("Category khong ton tai");
                });
        return category.getAttributes().stream()
                .map(a -> Map.<String, Object>of("id", a.getId(), "name", a.getName()))
                .collect(Collectors.toList());
    }
}
