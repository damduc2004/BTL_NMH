# 📐 Phân Tích Kiến Trúc Hệ Thống Hiện Tại

## 🎯 Kết Luận Cuối Cùng

Hệ thống của bạn theo **MICROSERVICES ARCHITECTURE** kết hợp với **MVC Pattern** ở mỗi service.

---

## 1. KIẾN TRÚC TỔNG THỂ - MICROSERVICES ✅

### 1.1 Đặc Trưng Microservices của Hệ Thống Bạn

```
✅ Nhiều Services độc lập:
   • user-service (port 8082)      → Quản lý user/admin
   • product-service (port 8081)   → Quản lý sản phẩm
   • feedback-service (port 8083)  → Quản lý review/feedback
   • api-gateway (port 8080)       → Routing tập trung

✅ Cơ sở dữ liệu riêng biệt (Database per Service):
   • user_db (port 3306)       → user-service
   • product_db (port 3307)    → product-service
   • feedback_db (port 3308)   → feedback-service

✅ Giao tiếp giữa services:
   • Thông qua HTTP REST APIs (không chia sẻ DB)
   • product-service gọi user-service để lấy tên admin
   • feedback-service gọi user-service & product-service

✅ Độc lập triển khai:
   • Mỗi service có riêng Dockerfile
   • Orchestrate bằng Docker Compose
   • Có thể scale từng service riêng biệt

✅ Độc lập phát triển:
   • Mỗi service có riêng teams/modules
   • Có thể deploy từng service mà không ảnh hưởng khác
   • Mỗi service là Maven module độc lập
```

### 1.2 So Sánh với Kiến Trúc Khác

| Yếu tố | **Microservices** (Bạn) | Monolithic | SOA |
|--------|------------------------|-----------|-----|
| **Số Services** | 4 độc lập | 1 ứng dụng | 3-5 services |
| **Database** | 3 DB riêng | 1 DB chung | Thường 1 DB |
| **Deploy** | Từng service | Toàn bộ | Từng service |
| **Scale** | Từng service | Toàn bộ | Từng service |
| **Fault Isolation** | Nếu user-service down, product vẫn OK* | Nếu down toàn bộ | Nếu down toàn bộ |
| **Complexity** | Cao (phức tạp hơn) | Thấp (đơn giản) | Trung bình |

**\*Ghi chú**: Hiện tại nếu user-service down, product-service sẽ call fail. Cần implement retry/fallback.

---

## 2. KIẾN TRÚC CHIỀU DỌC - MVC PER SERVICE ✅

### 2.1 Model Lớp Ngang (Layer Architecture) trong Mỗi Service

Mỗi service tuân theo **MVC/Layered Architecture**:

```
┌─────────────────────────────────────────────────┐
│          HTTP Client / Browser                   │
│       (Frontend / Postman / Mobile)             │
└──────────────────┬──────────────────────────────┘
                   │ HTTP Request
                   ▼
┌─────────────────────────────────────────────────┐
│        PRESENTATION LAYER (V = View)            │
│                                                  │
│  • Controller (REST Endpoints)                  │
│    - ProductController.java                     │
│    - FeedbackController.java                    │
│    - UserController.java                        │
│                                                  │
│  • DTO (Data Transfer Objects)                  │
│    - ProductCreateRequest                       │
│    - ProductResponse                            │
│    - FeedbackResponse                           │
│                                                  │
│  Returns: JSON / XML Response                   │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│        BUSINESS LOGIC LAYER (C = Controller)    │
│                                                  │
│  • Service Classes                              │
│    - ProductService.java                        │
│    - FeedbackService.java                       │
│    - UserService.java                           │
│                                                  │
│  Xử lý:                                         │
│  • Validation                                   │
│  • Business Rules                               │
│  • Orchestration (gọi repositories)             │
│  • Inter-service calls (HTTP)                   │
│                                                  │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│        DATA ACCESS LAYER (M = Model)            │
│                                                  │
│  • Repository Classes                           │
│    - ProductRepository (JpaRepository)          │
│    - FeedbackRepository                         │
│    - UserRepository                             │
│                                                  │
│  • Entity Classes (ORM Models)                  │
│    - Product.java (@Entity)                     │
│    - Feedback.java (@Entity)                    │
│    - User.java / Admin.java (@Entity)           │
│                                                  │
│  Xử lý: SQL queries, CRUD operations           │
│                                                  │
└──────────────────┬──────────────────────────────┘
                   │ SQL
                   ▼
┌─────────────────────────────────────────────────┐
│          DATABASE LAYER                          │
│                                                  │
│  • MySQL Database                               │
│    - Tables, Indexes, Foreign Keys              │
│    - Stored Procedures (optional)               │
│                                                  │
└─────────────────────────────────────────────────┘
```

### 2.2 Cấu Trúc Thư Mục Cụ Thể trong Mỗi Service

**product-service** (ví dụ):
```
src/main/java/com/example/product/
│
├── controller/              ← PRESENTATION (View)
│   ├── ProductController.java
│   └── CategoryController.java
│
├── service/                ← BUSINESS LOGIC (Controller)
│   ├── ProductService.java
│   └── CategoryService.java
│
├── repository/            ← DATA ACCESS (Model - Repository)
│   ├── ProductRepository.java
│   └── CategoryRepository.java
│
├── entity/               ← DATA ACCESS (Model - Entity)
│   ├── Product.java
│   └── Category.java
│
├── dto/                 ← PRESENTATION (View - Data Transfer)
│   ├── ProductCreateRequest.java
│   ├── ProductResponse.java
│   └── ProductUpdateRequest.java
│
├── config/             ← Configuration
│   ├── WebMvcConfig.java
│   ├── JpaConfig.java
│   └── CorsConfig.java
│
└── ProductServiceApplication.java  ← Spring Boot Main
```

### 2.3 Luồng Request - MVC Flow

```
1️⃣ PRESENTATION LAYER (View)
   ├─ HTTP Request đến /api/products/1
   ├─ ProductController.getProduct(1)
   └─ Xử lý input, validation basic

2️⃣ BUSINESS LOGIC LAYER (Controller)
   ├─ ProductService.getProductById(1)
   ├─ Gọi ProductRepository
   └─ Xử lý business rules

3️⃣ DATA ACCESS LAYER (Model)
   ├─ ProductRepository.findById(1)
   ├─ SQL: SELECT * FROM products WHERE id=1
   └─ Trả về Product entity

4️⃣ MAPPING & RETURN
   ├─ Convert Product → ProductResponse (DTO)
   ├─ Return JSON response
   └─ HTTP 200 OK
```

---

## 3. KIẾN TÚC CHIỀU NGANG - ACROSS SERVICES ✅

### 3.1 Sơ Đồ Quan Hệ Services

```
┌──────────────────────────────────────────────────────────┐
│                   CLIENT / BROWSER                        │
│                  (Frontend Application)                   │
└──────────────────────────┬───────────────────────────────┘
                           │ HTTP:8080
                           ▼
        ┌──────────────────────────────────────┐
        │      API GATEWAY (Spring Cloud)      │
        │           Port 8080                   │
        │                                      │
        │  Routing Rules:                      │
        │  /api/products/** → :8081            │
        │  /api/feedbacks/** → :8083           │
        │  /api/users/** → :8082               │
        └──────────────┬───────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
   ┌─────────┐  ┌──────────┐  ┌────────────┐
   │ product │  │ feedback │  │    user    │
   │ service │  │ service  │  │ service    │
   │ :8081   │  │ :8083    │  │ :8082      │
   └────┬────┘  └────┬─────┘  └────┬───────┘
        │            │             │
        │            │ (calls)     │ (calls)
        ├────────────┼─────────────┤
        │            │             │
        ▼            ▼             ▼
   ┌─────────┐  ┌──────────┐  ┌────────────┐
   │product_ │  │feedback_ │  │  user_db   │
   │  db     │  │   db     │  │            │
   │:3307    │  │ :3308    │  │   :3306    │
   └─────────┘  └──────────┘  └────────────┘
```

### 3.2 Inter-Service Communication

```
Ví dụ 1: product-service gọi user-service
┌───────────────────────────────────────────┐
│ Client request: GET /api/products/1       │
└──────────────┬──────────────────────────┘
               │
               ▼
        ┌─────────────────┐
        │ ProductService  │
        │ getProduct(1)   │
        └────────┬────────┘
                 │
        1. Load product from DB
           → id=1, name="iPhone", created_by_user_id=3
        │
        2. Gọi user-service để lấy tên người tạo
           │
           ├─ HTTP GET /api/users/3
           │  (product-service → user-service:8082)
           │
           ▼
        ┌─────────────────┐
        │  UserService    │
        │ getUser(3)      │
        └────────┬────────┘
                 │
        1. Load admin từ user_db
           → id=3, username="manager1", fullName="Quản lý 1"
        │
        2. Return JSON response
           │
           └─ { id: 3, username: "manager1", fullName: "Quản lý 1" }
                 │
                 ▼
        ┌─────────────────────┐
        │ ProductService      │
        │ Receive response    │
        │ Merge data:         │
        │ {                   │
        │   id: 1,            │
        │   name: "iPhone",   │
        │   createdBy: {      │
        │     id: 3,          │
        │     name: "Quản lý" │
        │   }                 │
        │ }                   │
        └─────────────────────┘
```

---

## 4. PATTERN & PRINCIPLES ĐƯỢC ÁP DỤNG

### 4.1 Design Patterns

| Pattern | Vị trí | Mục đích |
|---------|--------|---------|
| **Repository** | `repository/` | Abstraction data access |
| **Service** | `service/` | Encapsulate business logic |
| **DTO (Data Transfer Object)** | `dto/` | Transfer data between layers |
| **Entity (ORM)** | `entity/` | Map DB tables to Java objects |
| **Dependency Injection** | `@Autowired` | Spring IoC container |
| **API Gateway** | `api-gateway/` | Centralized routing |
| **Microservices** | 4 services | Independent deployment |

### 4.2 SOLID Principles

✅ **S**ingle Responsibility: 
- ProductService chỉ xử lý product
- UserService chỉ xử lý user
- FeedbackService chỉ xử lý feedback

✅ **O**pen/Closed:
- Interface Repository mở extension
- Dễ add new service mà không sửa existing

✅ **L**iskov Substitution:
- JpaRepository<T, ID> có thể substitute cho repository implementation

✅ **I**nterface Segregation:
- ProductRepository chỉ định nghĩa product methods
- UserRepository chỉ định nghĩa user methods

✅ **D**ependency Inversion:
- Service depend on Repository interface (abstraction)
- Không depend on concrete repository implementation

---

## 5. SO SÁNH CHI TIẾT: KIẾN TRÚC CỦA BẠN

### 5.1 Không Phải Traditional Web (Monolithic)

❌ **Traditional Web Architecture**:
```
┌────────────────────────────────┐
│   Single Monolithic App        │
│  (Spring MVC / Django / etc)   │
│                                │
│  • Controller (HTTP Layer)      │
│  • Service (Business logic)    │
│  • DAO (Data Access)           │
│  • Model (Database)            │
│                                │
│  Deploy: 1 WAR/JAR file        │
│  Database: 1 shared DB         │
│                                │
│  Problem: Khó scale riêng phần │
└────────────────────────────────┘
```

✅ **Của bạn khác ở**:
- ✅ Có 4 services (không phải 1 monolith)
- ✅ Có 3 databases (không phải 1 shared DB)
- ✅ Deploy từng service (không phải 1 WAR file)

### 5.2 Không Phải SOA (Service Oriented Architecture)

⚠️ **SOA** thường:
- Sử dụng SOAP / XML (bạn dùng REST / JSON)
- Sử dụng ESB (Enterprise Service Bus) (bạn dùng simpler Gateway)
- Shared database (bạn dùng database per service)

### 5.3 Đây Là Microservices (Chuẩn)

✅ **Kiến trúc bạn là MICROSERVICES ARCHITECTURE** vì:

| Tiêu chí | Yêu cầu Microservices | Hệ thống bạn |
|---------|----------------------|-------------|
| Services độc lập | Chia thành modules nhỏ | ✅ 4 services |
| DB riêng | Database per service | ✅ 3 DBs |
| HTTP/REST | REST API giao tiếp | ✅ REST APIs |
| Deploy độc lập | Mỗi service riêng | ✅ Docker riêng |
| Scale riêng | Có thể scale service alone | ✅ Có thể |
| Loose coupling | Services độc lập | ✅ Có (mostly) |
| High cohesion | Logic tập trung | ✅ Có |

---

## 6. KIẾN TRÚC TRONG MỖI SERVICE: PRESENTATION LAYER

### 6.1 Ví Dụ ProductController (Presentation Layer)

```java
@RestController
@RequestMapping("/api/products")
public class ProductController {
    
    @Autowired
    private ProductService productService;
    
    // VIEW: Nhận HTTP request
    @GetMapping("/{id}")
    public ResponseEntity<ProductResponse> getProduct(@PathVariable Long id) {
        // Controller: Parse input + basic validation
        ProductResponse response = productService.getProductById(id);
        // VIEW: Return HTTP response
        return ResponseEntity.ok(response);
    }
    
    // VIEW: Request DTO
    @PostMapping
    public ResponseEntity<ProductResponse> createProduct(
        @RequestBody ProductCreateRequest request) {
        ProductResponse response = productService.createProduct(request);
        return ResponseEntity.status(201).body(response);
    }
}

// DTO = VIEW (Input/Output)
@Data
public class ProductCreateRequest {
    private String name;
    private BigDecimal price;
    private Long categoryId;
}

@Data
public class ProductResponse {
    private Long id;
    private String name;
    private BigDecimal price;
    private String categoryName;
}
```

### 6.2 Service Layer (Controller/Business Logic)

```java
@Service
public class ProductService {
    
    @Autowired
    private ProductRepository productRepository;
    
    @Autowired
    private CategoryRepository categoryRepository;
    
    // CONTROLLER: Xử lý business logic
    public ProductResponse createProduct(ProductCreateRequest req) {
        // Validation
        if (!categoryRepository.existsById(req.getCategoryId())) {
            throw new CategoryNotFoundException();
        }
        
        // Business logic
        Category category = categoryRepository.findById(req.getCategoryId()).get();
        Product product = new Product();
        product.setName(req.getName());
        product.setPrice(req.getPrice());
        product.setCategory(category);
        
        // Call data access layer
        Product saved = productRepository.save(product);
        
        // Return DTO
        return mapToResponse(saved);
    }
}
```

### 6.3 Data Access Layer (Model)

```java
// REPOSITORY
public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByNameContainingIgnoreCase(String keyword);
    List<Product> findByCategory(Category category);
}

// ENTITY (Model)
@Entity
@Table(name = "products")
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    private BigDecimal price;
    
    @ManyToOne
    @JoinColumn(name = "category_id")
    private Category category;
}
```

---

## 7. TÓIM TẮT CẤU TRÚC

```
┌────────────────────────────────────────────────────────────┐
│                 KIẾN TRÚC CỦA BẠN                          │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  📊 MACRO: MICROSERVICES ARCHITECTURE                      │
│  ├─ 4 Services độc lập (user, product, feedback, gateway) │
│  ├─ 3 Databases riêng (database per service)              │
│  ├─ REST API giao tiếp                                    │
│  └─ Deploy/Scale từng service                             │
│                                                             │
│  📋 MICRO (mỗi service): MVC / LAYERED ARCHITECTURE       │
│  ├─ Presentation Layer                                    │
│  │  ├─ Controller (HTTP endpoints)                        │
│  │  └─ DTO (Request/Response objects)                     │
│  │                                                         │
│  ├─ Business Logic Layer                                  │
│  │  └─ Service (@Service classes)                         │
│  │                                                         │
│  └─ Data Access Layer                                     │
│     ├─ Repository (JpaRepository)                         │
│     └─ Entity (ORM Model)                                 │
│                                                             │
│  🔧 TECH STACK:                                           │
│  ├─ Spring Boot 3.4.4                                    │
│  ├─ Spring Cloud Gateway                                  │
│  ├─ JPA/Hibernate ORM                                     │
│  ├─ MySQL 8.0                                            │
│  ├─ Docker Compose                                        │
│  └─ Maven                                                 │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

---

## 8. ADVANTAGES & CHALLENGES

### ✅ Ưu Điểm của Kiến Trúc

| Ưu điểm | Giải thích |
|--------|-----------|
| **Independent Deployment** | Deploy product-service mà không ảnh hưởng user-service |
| **Scalability** | Scale feedback-service nếu có nhiều reviews, không cần scale product |
| **Technology Flexibility** | Mỗi service có thể dùng DB khác nhau (MySQL, PostgreSQL, etc) |
| **Team Autonomy** | Teams khác nhau có thể phát triển services độc lập |
| **Fault Isolation** | Product-service down không làm crash user-service |
| **Easy Testing** | Dễ test từng service riêng biệt |
| **Clear Responsibilities** | Mỗi service có mục đích rõ ràng |

### ⚠️ Thách Thức

| Thách thức | Giải pháp |
|-----------|----------|
| **Distributed Transactions** | Implement Saga pattern hoặc compensating transactions |
| **Network Latency** | Cache results, implement retry logic |
| **Data Consistency** | Eventual consistency (không ACID toàn hệ thống) |
| **Operational Complexity** | DevOps, monitoring multiple services |
| **Service Failure** | Implement circuit breaker, fallback mechanisms |
| **Debugging** | Centralized logging (ELK Stack), Distributed Tracing |

### 📈 Sắp Tới: Cải Thiện Kiến Trúc

Có thể thêm:
1. **Resilience**: Spring Cloud Circuit Breaker (Hystrix / Resilience4j)
2. **Async Communication**: Message Queue (RabbitMQ / Kafka)
3. **Caching**: Redis caching layer
4. **Monitoring**: Prometheus + Grafana
5. **Distributed Tracing**: Spring Cloud Sleuth + Zipkin
6. **Config Server**: Spring Cloud Config
7. **Service Discovery**: Eureka / Consul
8. **Containerization**: Kubernetes (K8s)

---

## 🎓 KẾT LUẬN

**Hệ thống của bạn là:**

```
╔══════════════════════════════════════════════════════╗
║  ✅ MICROSERVICES ARCHITECTURE (Chi tiết MACRO)    ║
║                                                      ║
║  ✅ MVC / LAYERED PATTERN (Chi tiết MICRO)         ║
║                                                      ║
║  ✅ SPRING BOOT best practices                      ║
║                                                      ║
║  ✅ Production-ready fundamentals                   ║
╚══════════════════════════════════════════════════════╝
```

**Không phải:**
- ❌ Traditional monolithic web app
- ❌ SOA (Service Oriented Architecture)
- ❌ Simple web application

**Đây là**: ✅ **Modern Microservices Architecture** với **Layered Design** trong mỗi service.

---

**Document tạo**: April 15, 2026
