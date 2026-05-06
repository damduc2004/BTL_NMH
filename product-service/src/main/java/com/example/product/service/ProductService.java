package com.example.product.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.product.entity.Attribute;
import com.example.product.entity.Category;
import com.example.product.entity.Product;
import com.example.product.entity.ProductAttribute;
import com.example.product.repository.AttributeRepository;
import com.example.product.repository.CategoryRepository;
import com.example.product.repository.ProductRepository;

@Service
public class ProductService {

    private static final Logger log = LoggerFactory.getLogger(ProductService.class);

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final AttributeRepository attributeRepository;

    public ProductService(ProductRepository productRepository,
                          CategoryRepository categoryRepository,
                          AttributeRepository attributeRepository) {
        this.productRepository = productRepository;
        this.categoryRepository = categoryRepository;
        this.attributeRepository = attributeRepository;
    }

    @Transactional
    public Product createProduct(Map<String, Object> req) {
        String name = (String) req.get("name");
        Number price = (Number) req.get("price");
        Number stock = (Number) req.get("stockQuantity");
        Number categoryId = (Number) req.get("categoryId");

        if (name == null || name.isBlank()) throw new IllegalArgumentException("Tên sản phẩm không được trống");
        if (price == null) throw new IllegalArgumentException("Giá không được trống");
        if (categoryId == null) throw new IllegalArgumentException("Danh mục không được trống");

        Category category = categoryRepository.findById(categoryId.longValue())
                .orElseThrow(() -> new IllegalArgumentException("Category không tồn tại: id=" + categoryId));

        Product product = new Product();
        product.setName(name.trim());
        product.setPrice(new java.math.BigDecimal(price.toString()));
        product.setStockQuantity(stock != null ? stock.intValue() : 0);
        product.setCategory(category);

        List<ProductAttribute> productAttributes = new ArrayList<>();

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> fixedAttrs = (List<Map<String, Object>>) req.get("fixedAttributes");
        if (fixedAttrs != null) {
            for (Map<String, Object> entry : fixedAttrs) {
                Long attrId = ((Number) entry.get("attributeId")).longValue();
                String value = (String) entry.get("value");
                Attribute attr = attributeRepository.findById(attrId)
                        .orElseThrow(() -> new IllegalArgumentException("Attribute không tồn tại: id=" + attrId));
                productAttributes.add(new ProductAttribute(product, attr, value));
            }
        }

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> extraAttrs = (List<Map<String, Object>>) req.get("extraAttributes");
        if (extraAttrs != null) {
            for (Map<String, Object> entry : extraAttrs) {
                String attrName = (String) entry.get("name");
                String value = (String) entry.get("value");
                if (attrName == null || attrName.isBlank()) continue;
                Attribute attr = attributeRepository.findByName(attrName.trim())
                        .orElseGet(() -> attributeRepository.save(new Attribute(attrName.trim())));
                productAttributes.add(new ProductAttribute(product, attr, value));
            }
        }

        product.setProductAttributes(productAttributes);
        Product saved = productRepository.save(product);
        log.info("[ADMIN] Product created: id={}, name='{}', category='{}'",
                saved.getId(), saved.getName(), saved.getCategory().getName());
        return saved;
    }

    @Transactional(readOnly = true)
    public Page<Product> getProducts(String keyword, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        if (keyword != null && !keyword.isBlank()) {
            return productRepository.searchByKeyword(keyword.trim(), pageable);
        }
        return productRepository.findAllByOrderByIdDesc(pageable);
    }

    @Transactional(readOnly = true)
    public Product getProductById(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Product không tồn tại: id=" + id));
    }

    @Transactional
    public void deleteProduct(Long id) {
        if (!productRepository.existsById(id)) {
            throw new IllegalArgumentException("Product không tồn tại: id=" + id);
        }
        productRepository.deleteById(id);
        log.info("[ADMIN] Product deleted: id={}", id);
    }

    @Transactional(readOnly = true)
    public Attribute getAttributeById(Long id) {
        return attributeRepository.findById(id).orElse(null);
    }
}
