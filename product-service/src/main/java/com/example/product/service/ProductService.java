package com.example.product.service;

import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.product.dto.AttributeResponseDto;
import com.example.product.dto.ProductCreateRequest;
import com.example.product.dto.ProductResponse;
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
    public ProductResponse createProduct(ProductCreateRequest req) {
        log.info("Creating product: name='{}', categoryId={}, fixedAttrs={}, extraAttrs={}",
                req.getName(), req.getCategoryId(),
                req.getFixedAttributes() != null ? req.getFixedAttributes().size() : 0,
                req.getExtraAttributes() != null ? req.getExtraAttributes().size() : 0);
        Category category = categoryRepository.findById(req.getCategoryId())
                .orElseThrow(() -> {
                    log.warn("Category not found: id={}", req.getCategoryId());
                    return new IllegalArgumentException(
                            "Category khong ton tai voi id: " + req.getCategoryId());
                });

        Product product = new Product();
        product.setName(req.getName());
        product.setPrice(req.getPrice());
        product.setStockQuantity(req.getStockQuantity());
        product.setCategory(category);

        List<ProductAttribute> productAttributes = new ArrayList<>();

        if (req.getFixedAttributes() != null) {
            for (ProductCreateRequest.FixedAttributeEntry entry : req.getFixedAttributes()) {
                Attribute attr = attributeRepository.findById(entry.getAttributeId())
                        .orElseThrow(() -> new IllegalArgumentException(
                                "Attribute khong ton tai voi id: " + entry.getAttributeId()));
                productAttributes.add(new ProductAttribute(product, attr, entry.getValue()));
            }
        }

        if (req.getExtraAttributes() != null) {
            for (ProductCreateRequest.ExtraAttributeEntry entry : req.getExtraAttributes()) {
                if (entry.getName() == null || entry.getName().trim().isEmpty()) continue;
                String trimmedName = entry.getName().trim();
                Attribute attr = attributeRepository.findByName(trimmedName)
                        .orElseGet(() -> attributeRepository.save(new Attribute(trimmedName)));
                productAttributes.add(new ProductAttribute(product, attr, entry.getValue()));
            }
        }

        product.setProductAttributes(productAttributes);
        Product saved = productRepository.save(product);
        log.info("[ADMIN] Product created: id={}, name='{}', category='{}', stock={}, attributes={}",
                saved.getId(), saved.getName(), saved.getCategory().getName(),
                saved.getStockQuantity(), saved.getProductAttributes().size());
        return toResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<ProductResponse> getAllProducts() {
        List<ProductResponse> list = productRepository.findAllByOrderByIdDesc().stream()
                .map(this::toResponse)
                .toList();
        log.debug("getAllProducts: returned {} products", list.size());
        return list;
    }

    @Transactional(readOnly = true)
    public List<ProductResponse> searchProducts(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllProducts();
        }
        List<ProductResponse> list = productRepository.searchByKeyword(keyword.trim()).stream()
                .map(this::toResponse)
                .toList();
        log.debug("searchProducts keyword='{}': returned {} products", keyword, list.size());
        return list;
    }

    @Transactional(readOnly = true)
    public ProductResponse getProductById(Long id) {
        log.info("[INTER-SERVICE] Nhan yeu cau lay thong tin san pham: id={}", id);
        Product product = productRepository.findById(id)
                .orElseThrow(() -> {
                    log.warn("[INTER-SERVICE] Khong tim thay san pham: id={}", id);
                    return new IllegalArgumentException("Product khong ton tai voi id: " + id);
                });
        log.info("[INTER-SERVICE] Tra ve san pham: id={}, name='{}', category='{}'",
                product.getId(), product.getName(), product.getCategory().getName());
        return toResponse(product);
    }

    @Transactional
    public void deleteProduct(Long id) {
        if (!productRepository.existsById(id)) {
            log.warn("Delete failed - product not found: id={}", id);
            throw new IllegalArgumentException("Product khong ton tai voi id: " + id);
        }
        productRepository.deleteById(id);
        log.info("[ADMIN] Product deleted: id={}", id);
    }

    public AttributeResponseDto getAttributeById(Long id) {
        return attributeRepository.findById(id)
                .map(attr -> new AttributeResponseDto(attr.getId(), attr.getName()))
                .orElse(null);
    }

    private ProductResponse toResponse(Product product) {
        ProductResponse res = new ProductResponse();
        res.setId(product.getId());
        res.setName(product.getName());
        res.setPrice(product.getPrice());
        res.setStockQuantity(product.getStockQuantity());
        res.setCategoryId(product.getCategory().getId());
        res.setCategoryName(product.getCategory().getName());
        res.setAttributes(
            product.getProductAttributes().stream()
                .map(pa -> new ProductResponse.AttributeDto(
                        pa.getAttribute().getId(),
                        pa.getAttribute().getName(),
                        pa.getValue()))
                .toList()
        );
        return res;
    }
}
