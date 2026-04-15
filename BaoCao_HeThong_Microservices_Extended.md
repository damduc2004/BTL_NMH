# BỔ SUNG: THIẾT KẾ CHI TIẾT CSDL, BIỂU ĐỒ TỰ PHỐI VÀ DESIGN PATTERN

Các phần bổ sung sau đây áp dụng structure từ tài liệu PDF hệ thống rạp chiếu phim vào hệ thống Product/Feedback của bạn.

---

## 5. THIẾT KẾ CSDL CHI TIẾT

### 5.1 Database: `product_db` (Product Service)

```sql
-- ============ TÀI KHOẢN QUẢN TRỊ ============
CREATE TABLE users (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    username   VARCHAR(100) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,           -- BCrypt hash
    full_name  VARCHAR(200),
    email      VARCHAR(200),
    tel        VARCHAR(20),
    role       VARCHAR(20) DEFAULT 'ADMIN',     -- ADMIN / USER
    status     TINYINT(1)  NOT NULL DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============ DANH MỤC SẢN PHẨM ============
CREATE TABLE categories (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(255) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============ THUỘC TÍNH SẢN PHẨM ============
CREATE TABLE attributes (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(255) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============ QUAN HỆ: Category ──N:N──→ Attribute ============
CREATE TABLE category_attributes (
    category_id  BIGINT NOT NULL,
    attribute_id BIGINT NOT NULL,
    PRIMARY KEY (category_id, attribute_id),
    FOREIGN KEY (category_id)  REFERENCES categories(id)  ON DELETE CASCADE,
    FOREIGN KEY (attribute_id) REFERENCES attributes(id)  ON DELETE CASCADE
);

-- ============ SẢN PHẨM ============
CREATE TABLE products (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(255) NOT NULL,
    price          DECIMAL(19,2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    category_id    BIGINT NOT NULL,
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
    INDEX idx_category (category_id),
    INDEX idx_name (name)
);

-- ============ GIÁ TRỊ THUỘC TÍNH SẢN PHẨM (N:N via ProductAttribute) ============
CREATE TABLE product_attributes (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id   BIGINT NOT NULL,
    attribute_id BIGINT NOT NULL,
    attr_value   VARCHAR(255),
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (product_id, attribute_id),
    FOREIGN KEY (product_id)   REFERENCES products(id)   ON DELETE CASCADE,
    FOREIGN KEY (attribute_id) REFERENCES attributes(id) ON DELETE CASCADE,
    INDEX idx_product (product_id),
    INDEX idx_attribute (attribute_id)
);

-- ============ THỐNG KÊ BẢNG DỮ LIỆU ============
/*
Quan hệ:
  - users ──1:N──→ products (indirect: qua điều khiển)
  - categories ──1:N──→ products
  - categories ──N:N──→ attributes (via category_attributes)
  - products ──N:N──→ attributes (via product_attributes)
  
Chỉ mục:
  - idx_category, idx_name (products): Tối ưu tìm kiếm
  - idx_product, idx_attribute (product_attributes): Tối ưu lấy thuộc tính sản phẩm
*/
```

### 5.2 Database: `feedback_db` (Feedback Service)

```sql
-- ============ PHẢN HỒI CHÍNH ============
CREATE TABLE feedbacks (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id     BIGINT       NOT NULL,        -- Logical ref (from product-service)
    product_name   VARCHAR(255) NOT NULL,
    user_id        BIGINT       NOT NULL,        -- FK to users (role='USER' only)
    comment        VARCHAR(1000),
    overall_rating INT          NOT NULL,        -- 1-5
    created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT chk_overall_rating CHECK (overall_rating BETWEEN 1 AND 5),
    INDEX idx_product (product_id),
    INDEX idx_user (user_id),
    INDEX idx_created (created_at DESC)
);

-- ============ ĐÁNH GIÁ TỪNG THUỘC TÍNH ============
CREATE TABLE attribute_ratings (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    feedback_id    BIGINT       NOT NULL,
    attribute_name VARCHAR(255) NOT NULL,
    rating         INT          NOT NULL,        -- 1-5
    comment        VARCHAR(500),
    FOREIGN KEY (feedback_id) REFERENCES feedbacks(id) ON DELETE CASCADE,
    CONSTRAINT chk_attr_rating CHECK (rating BETWEEN 1 AND 5),
    INDEX idx_feedback (feedback_id)
);

-- ============ THỐNG KÊ BẢNG DỮ LIỆU ============
/*
Quan hệ:
  - feedbacks ──1:N──→ attribute_ratings (cascade delete)
  - Logical: feedbacks.product_id tham chiếu product-service.products.id
  - feedbacks.user_id tham chiếu product-service.users.id (role='USER')
  
Ràng buộc:
  - overall_rating, individual rating phải trong [1-5]
  - user_id phải là USER (kiểm tra ở application layer)
  
Chỉ mục:
  - idx_product, idx_user, idx_created (feedbacks): Tối ưu truy vấn
  - idx_feedback (attribute_ratings): Tối ưu lấy chi tiết phản hồi
*/
```

---

## 6. THIẾT KẾ BIỂU ĐỒ TUẦN TỰ – LUỒNG TÀI CHÍNH

### 6.1 Kịch bản: Thêm Sản Phẩm Mới

**Bước:**
1. ADMIN điền form (Tên, Giá, Số lượng, Danh mục, Thuộc tính)
2. Form POST /api/products
3. ProductController nhận → ProductService.createProduct()
4. Service: Tạo Product, thêm ProductAttribute, lưu DB
5. Trả ProductResponse + hiển thị thông báo

**Biểu đồ tuần tự:**

```
Client (Browser)
    │
    │ POST /api/products
    │ { name, price, category_id, attributes: [] }
    │
    ├────────→ API Gateway (:8080)
    │           │
    │           ├─ Route: /api/products → product-service (:8081)
    │           │
    │           ├────────→ ProductController
    │                       │
    │                       ├─ createProduct(req)
    │                       │
    │                       ├────────→ ProductService
    │                       │           │
    │                       │           ├─ validate(req)
    │                       │           │  check category exists
    │                       │           │
    │                       │           ├─ new Product()
    │                       │           │  set name, price, category
    │                       │           │
    │                       │           ├────────→ ProductRepository.save(product)
    │                       │           │           │
    │                       │           │           ├───→ Database
    │                       │           │           │       INSERT INTO products
    │                       │           │           │       RETURN id (auto)
    │                       │           │           │
    │                       │           │           ←─────  Product with id
    │                       │           │
    │                       │           ├─ for each attribute in req:
    │                       │           │   new ProductAttribute()
    │                       │           │   set product, attribute, value
    │                       │           │
    │                       │           ├────────→ ProductAttributeRepository
    │                       │           │           .saveAll(attrs)
    │                       │           │           │
    │                       │           │           ├───→ Database
    │                       │           │           │       INSERT INTO product_attributes
    │                       │           │           │
    │                       │           │           ←─────  List<ProductAttribute>
    │                       │           │
    │                       │           ├─ ProductResponse toResponse(product)
    │                       │           │
    │                       │           ←─────────────────  ProductResponse
    │                       │
    │                       ├─ ResponseEntity.ok(response)
    │                       │
    │                       ←──────────────────────────  HTTP 200
    │                                                    { id, name, price, ... }
    │
    ├────────────────────────────────--  HTTP 200 + JSON
    │
    └─ Client JS:
      • Parse response
      • Show: ✓ Thêm sản phẩm #5 thành công
      • Reload product list
```

### 6.2 Kịch bản: Gửi Phản Hồi

**Bước:**
1. USER chọn sản phẩm, đánh giá từng thuộc tính, viết nhận xét
2. Gửi POST /api/feedbacks (feedback + list attribute ratings)
3. FeedbackController → FeedbackService.createFeedback()
4. Service: Validate user (role=USER), tạo Feedback, tạo AttributeRating, lưu DB
5. Trả FeedbackResponse + cập nhật UI thống kê

**Biểu đồ tuần tự:**

```
User (Browser – Khách hàng role=USER)
    │
    │ POST /api/feedbacks
    │ {
    │   user_id, product_id, product_name,
    │   comment, overall_rating,
    │   attributeRatings: [
    │     { attributeName, rating, comment },
    │     ...
    │   ]
    │ }
    │
    ├────────→ API Gateway (:8080)
    │           │ Route: /api/feedbacks → feedback-service (:8082)
    │           │
    │           ├────────→ FeedbackController
    │                       │
    │                       ├─ createFeedback(req)
    │                       │
    │                       ├────────→ FeedbackService
    │                       │           │
    │                       │           ├─ validateUser(user_id)
    │                       │           │  check role = 'USER'
    │                       │           │  [call to product-service UserService]
    │                       │           │  if ADMIN: throw exception
    │                       │           │
    │                       │           ├─ new Feedback()
    │                       │           │  set product_id, user_id, comment,
    │                       │           │  overall_rating, created_at
    │                       │           │
    │                       │           ├────────→ FeedbackRepository.save(feedback)
    │                       │           │           │
    │                       │           │           ├───→ Database
    │                       │           │           │       INSERT INTO feedbacks
    │                       │           │           │       RETURN id (auto)
    │                       │           │           │
    │                       │           │           ←─────  Feedback with id
    │                       │           │
    │                       │           ├─ for each attr in req.attributeRatings:
    │                       │           │   new AttributeRating()
    │                       │           │   set feedback_id, attributeName,
    │                       │           │   rating, comment
    │                       │           │
    │                       │           ├────────→ AttributeRatingRepository
    │                       │           │           .saveAll(attrs)
    │                       │           │           │
    │                       │           │           ├───→ Database
    │                       │           │           │       INSERT INTO attribute_ratings
    │                       │           │           │
    │                       │           │           ←─────  List<AttributeRating>
    │                       │           │
    │                       │           ├─ FeedbackResponse toResponse(feedback)
    │                       │           │
    │                       │           ←─────────────────  FeedbackResponse
    │                       │
    │                       ├─ ResponseEntity.ok(response)
    │                       │
    │                       ←──────────────────────────  HTTP 201 / 200
    │                                                    { id, product_id, ... }
    │
    ├────────────────────────────-----  HTTP 200 + JSON
    │
    └─ Client JS:
      • Parse response
      • Show: ✓ Gửi phản hồi thành công
      • Reload feedback stats (server-side calculation)
```

---

## 7. THIẾT KẾ API GATEWAY

### 7.1 Cấu hình Routing (`application.yml`)

```yaml
spring:
  application:
    name: api-gateway
  cloud:
    gateway:
      routes:
        # Product Service routes
        - id: product-service
          uri: http://localhost:8081
          predicates:
            - Path=/api/products/**
            - Path=/api/categories/**
            - Path=/api/attributes/**
            - Path=/login
            - Path=/logout
          filters:
            - StripPrefix=0
            - AuthFilter

        # Feedback Service routes
        - id: feedback-service
          uri: http://localhost:8082
          predicates:
            - Path=/api/feedbacks/**
            - Path=/api/feedbacks/stats/**
          filters:
            - StripPrefix=0
            - AuthFilter

server:
  port: 8080

logging:
  level:
    org.springframework.cloud.gateway: DEBUG
```

### 7.2 Luồng Routing

```
┌─────────────────────────────────────────────────────────────────────┐
│                        API Gateway (:8080)                         │
│                                                                     │
│  1. Nhận HTTP request từ client                                    │
│  2. Kiểm tra path + method                                         │
│  3. Match predicate → route to service                             │
│  4. Gọi filter (AuthFilter: check JWT/Session)                    │
│  5. Forward request tới target service                             │
│  6. Nhận response từ service                                       │
│  7. Gửi response về client                                        │
└─────────────────────────────────────────────────────────────────────┘

Pre-request Routing:
┌─────────────────────┐
│ GET /api/products   │
│ (+ JWT header)      │
└──────────┬──────────┘
           │
           ├─ Match: Path=/api/products/**
           │
           ├─ Apply filters:
           │  └─ AuthFilter: Validate JWT
           │
           ├─ Route to: http://localhost:8081/api/products
           │
           ├─ Forward request
           │
           └─→ ProductService (:8081)

Post-response Routing:
┌─────────────────────────────────────┐
│ ProductService returns HTTP 200     │
│ { id: 1, name: "iPhone", ...}       │
└──────────┬──────────────────────────┘
           │
           ├─ API Gateway received response
           │
           ├─ Apply response filters
           │  (add CORS headers, etc.)
           │
           └─→ Send to Client Browser
              ┌──────────────────────────┐
              │ HTTP 200 OK              │
              │ Content-Type: application/json
              │ { id: 1, name: "iPhone",│
              │   price: 25000000, ...}  │
              └──────────────────────────┘
```

---

## 8. DESIGN PATTERN SỬ DỤNG

### 8.1 Repository Pattern (Data Access Layer)

**Mục đích:**  
- Tách biệt logic truy cập dữ liệu (SQL queries) khỏi business logic (Service)
- Widget dễ test unit, dễ mock trong test

**Cách dùng:**
```java
// Interface
public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByNameContainingIgnoreCase(String keyword);
    List<Product> findByCategory(Category category);
}

// Service layer gọi Repository
@Service
public class ProductService {
    @Autowired
    private ProductRepository productRepository;
    
    public List<Product> searchProducts(String keyword) {
        return productRepository.findByNameContainingIgnoreCase(keyword);
    }
}
```

**Lợi ích:**
- Thay đổi DB implementation mà không ảnh hưởng Service
- Dễ test: mock repository trong unit test
- Consistent CRUD operations

---

### 8.2 Service Layer Pattern (Business Logic)

**Mục đích:**  
- Chứa toàn bộ business logic (validation, calculations, orchestration)
- Tách biệt khỏi Controller (HTTP concerns) và Repository (DB concerns)

**Cách dùng:**
```java
@Service
public class ProductService {
    @Autowired
    private ProductRepository productRepository;
    @Autowired
    private CategoryRepository categoryRepository;
    
    public ProductResponse createProduct(ProductCreateRequest req) {
        // Validation logic
        if (!categoryRepository.existsById(req.getCategoryId())) {
            throw new CategoryNotFoundException();
        }
        
        // Business logic
        Category category = categoryRepository.findById(req.getCategoryId()).get();
        Product product = new Product();
        product.setName(req.getName());
        product.setPrice(req.getPrice());
        product.setCategory(category);
        
        // Persist
        Product saved = productRepository.save(product);
        
        // Transform to DTO
        return toResponse(saved);
    }
}
```

**Lợi ích:**
- Tái sử dụng từ nhiều Controller
- Dễ unit test (mock collaborators)
- Business logic tập trung, dễ maintain

---

### 8.3 DTO Pattern (Data Transfer Object)

**Mục đích:**  
- Tách biệt Entity (DB schema) khỏi API Request/Response
- Kiểm soát dữ liệu nào được expose qua API
- Khác version API mà không ảnh hưởng DB schema

**Cách dùng:**
```java
// Request DTO
@Data
public class ProductCreateRequest {
    private String name;
    private BigDecimal price;
    private Integer stockQuantity;
    private Long categoryId;
    private List<ProductAttributeDto> attributes;
}

// Response DTO
@Data
public class ProductResponse {
    private Long id;
    private String name;
    private BigDecimal price;
    private Integer stockQuantity;
    private String categoryName;
    private List<ProductAttributeDto> attributes;
}

// Entity (DB)
@Entity
@Table(name = "products")
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    private BigDecimal price;
    private Integer stockQuantity;
    
    @ManyToOne
    @JoinColumn(name = "category_id")
    private Category category;
    
    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "product_id")
    private List<ProductAttribute> attributes;
}
```

**Lợi ích:**
- API independent từ DB schema
- Bảo mật: không expose all fields
- Dễ version API (v1, v2 khác nhau nhưng cùng DB)

---

### 8.4 Dependency Injection Pattern

**Mục đích:**  
- Quản lý dependencies (loose coupling)
- Dễ test: inject mock dependencies

**Cách dùng:**
```java
@RestController
@RequestMapping("/api/products")
public class ProductController {
    @Autowired
    private ProductService productService;  // Inject via Spring
    
    @PostMapping
    public ResponseEntity<ProductResponse> createProduct(
        @RequestBody ProductCreateRequest req) {
        ProductResponse response = productService.createProduct(req);
        return ResponseEntity.ok(response);
    }
}

// Trong test
@ExtendWith(MockitoExtension.class)
class ProductControllerTest {
    @Mock
    private ProductService mockProductService;
    
    @InjectMocks
    private ProductController controller;
    
    @Test
    void testCreateProduct() {
        // Arrange
        ProductCreateRequest req = new ProductCreateRequest();
        ProductResponse mockResponse = new ProductResponse();
        when(mockProductService.createProduct(req)).thenReturn(mockResponse);
        
        // Act
        ResponseEntity<ProductResponse> result = controller.createProduct(req);
        
        // Assert
        assertEquals(HttpStatus.OK, result.getStatusCode());
    }
}
```

**Lợi ích:**
- Loosely coupled components
- Dễ swap implementation (database, email service, etc.)
- Dễ unit test

---

### 8.5 JWT Token Pattern (Optional – Xác thực an toàn hơn)

**Mục đích:**  
- Xác thực stateless (không cần lưu session trên server)
- Scalable horizontal (nhiều server share cùng secret)

**Cách dùng:**
```java
// 1. Tạo JWT khi đăng nhập
@PostMapping("/login")
public ResponseEntity<?> login(@RequestBody LoginRequest req) {
    User user = userRepository.findByUsername(req.getUsername());
    if (user == null || !passwordMatches(req.getPassword(), user.getPassword())) {
        return ResponseEntity.status(401).body("Invalid credentials");
    }
    
    // Generate JWT
    String token = jwtProvider.generateToken(user.getId(), user.getRole());
    
    return ResponseEntity.ok(new LoginResponse(token));
}

// 2. Validate JWT ở mỗi request
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(HttpServletRequest req,
                                   HttpServletResponse res,
                                   FilterChain chain) {
        String token = extractToken(req);
        if (token != null && jwtProvider.validateToken(token)) {
            Long userId = jwtProvider.getUserIdFromToken(token);
            // Set authentication in SecurityContext
            // ...
        }
        chain.doFilter(req, res);
    }
}

// 3. JWT Provider
@Component
public class JwtProvider {
    @Value("${jwt.secret}")
    private String jwtSecret;
    
    public String generateToken(Long userId, String role) {
        return Jwts.builder()
            .setSubject(userId.toString())
            .claim("role", role)
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + 86400000)) // 24h
            .signWith(SignatureAlgorithm.HS512, jwtSecret)
            .compact();
    }
    
    public boolean validateToken(String token) {
        try {
            Jwts.parser().setSigningKey(jwtSecret).parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }
}
```

**Lợi ích:**
- Không cần shared session storage (Redis)
- Dễ scale horizontal
- Stateless: mỗi request tự chứa user info trong JWT

---

## 9. TỔNG KẾT KIẾN TRÚC

| Yếu tố | Giá trị | Ghi chú |
|---------|---------|---------|
| **Kiến trúc** | Microservices | 2 services độc lập (product, feedback) |
| **Database** | Unified (1 DB) | Tất cả bảng trong 1 database chung |
| **Giao tiếp** | REST API + HTTP | Services gọi nhau qua HTTP (logical ref) |
| **Gateway** | Spring Cloud Gateway | Routing tập trung, port 8080 |
| **Authentication** | Session-based | BCrypt hash; có thể upgrade JWT |
| **Pattern Main** | Repository + Service + DTO | Tách biệt concerns rõ ràng |
| **Framework** | Spring Boot + JPA | Rapid development, standard practices |
| **Lợi ích chính** | Maintainability + Testability | Dễ extend, dễ test, dễ scale |

---

## 10. THAM CHIẾU THÊM

### Các file thiết kế có trong workspace:
- `docker-compose.yml`: Orêng, MySQL service definitions
- `pom.xml`: Maven dependencies (product-service, api-gateway, feedback-service)
- `schema/`: SQL init scripts cho database

### Mở rộng tương lai:
1. **Thêm JWT authentication** (thay session)
2. **Message Queue** (RabbitMQ/Kafka) cho async notification
3. **Caching** (Redis) cho product list, stats cache
4. **Monitoring** (Spring Boot Actuator + Prometheus)
5. **Containerization** (Docker + Kubernetes)

---

**Tài liệu này áp dụng các khái niệm và cấu trúc từ báo cáo thiết kế hệ thống rạp chiếu phim vào hệ thống Product & Feedback Management, ensuring professional-grade architecture và documentation.**
