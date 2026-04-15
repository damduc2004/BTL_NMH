# Kiến Trúc Product Service

Áp dụng mô hình `item_service` (từ sơ đồ UML) vào hệ thống quản lý sản phẩm hiện tại.

---

## Sơ đồ kiến trúc (Class Diagram)

```mermaid
classDiagram
    direction TB

    %% ─── Controller Layer ───────────────────────────────────────
    class ProductController {
        -productService : ProductService
        +getAllProducts() : ResponseEntity
        +createProduct() : ResponseEntity
        +deleteProduct(id : Long) : ResponseEntity
    }
    class CategoryController {
        -categoryRepository : CategoryRepository
        +getAllCategories() : ResponseEntity
        +getCategoryAttributes(id : Long) : ResponseEntity
    }

    %% ─── Service Layer ──────────────────────────────────────────
    class ProductService {
        <<Service>>
        -productRepository : ProductRepository
        -categoryRepository : CategoryRepository
        -attributeRepository : AttributeRepository
        +createProduct() : Product
        +getAllProducts() : List~Product~
        +deleteProduct(id : Long) : void
    }

    %% ─── Repository Layer ───────────────────────────────────────
    class ProductRepository {
        <<Interface>>
    }

    class CategoryRepository {
        <<Interface>>
        +findByName(name : String) : Optional~Category~
    }

    class AttributeRepository {
        <<Interface>>
        +findByName(name : String) : Optional~Attribute~
    }

    class JpaRepository~T_ID~ {
        <<Interface>>
        +save(entity : T) : T
        +findAll() : List~T~
        +findById(id : ID) : Optional~T~
        +deleteById(id : ID) : void
    }

    %% ─── Entity Layer ───────────────────────────────────────────
    class Product {
        <<Entity>>
        -id : Long
        -name : String
        -price : BigDecimal
        -category : Category
        -productAttributes : List~ProductAttribute~
    }

    class Category {
        <<Entity>>
        -id : Long
        -name : String
        -products : List~Product~
        -attributes : List~Attribute~
    }

    class ProductAttribute {
        <<Entity>>
        -id : Long
        -product : Product
        -attribute : Attribute
        -value : String
    }

    class Attribute {
        <<Entity>>
        -id : Long
        -name : String
    }

    %% ─── Relationships ──────────────────────────────────────────

    %% Controller → Service / Repository
    ProductController --> ProductService : depends on
    CategoryController --> CategoryRepository : uses

    %% Service → Repository
    ProductService --> ProductRepository : uses
    ProductService --> CategoryRepository : uses
    ProductService --> AttributeRepository : uses

    %% Repository → JpaRepository (extends)
    ProductRepository --|> JpaRepository~Product_Long~
    CategoryRepository --|> JpaRepository~Category_Long~
    AttributeRepository --|> JpaRepository~Attribute_Long~

    %% Repository → Entity
    ProductRepository ..> Product : manages
    CategoryRepository ..> Category : manages
    AttributeRepository ..> Attribute : manages

    %% Entity → Entity
    Product "many" --> "1" Category : belongs to
    Product "1" *-- "many" ProductAttribute : has
    ProductAttribute "many" --> "1" Attribute : references
    Category "many" <--> "many" Attribute : has (category_attributes)
```

---

## So sánh với kiến trúc gốc (item_service)

| Thành phần (item_service) | Tương đương (product-service) | Ghi chú khác biệt |
|---|---|---|
| `ItemController` | `ProductController` + `CategoryController` | Tách thành 2 controller |
| `ItemService` _(interface)_ | _(không có interface)_ | `ProductService` là class `@Service` trực tiếp |
| `ItemServiceImpl` | `ProductService` | Gộp interface + impl thành một class |
| `ItemRepository` | `ProductRepository` | Tương tự |
| `ItemRequest` | `ProductCreateRequest` | Tách attributes thành `fixedAttributes` + `extraAttributes` |
| `ItemResponse` | `ProductResponse` | Trả `categoryName` (String) thay vì object `Category` |
| `Item` | `Product` | Không có field `unit`, `stockQuantity`, `description` |
| `Category` | `Category` | Bổ sung quan hệ `@ManyToMany` với `Attribute` |
| `ItemAttribute` | `ProductAttribute` | Thêm field `value` thay cho `description` |
| `Attribute` | `Attribute` | Không có field `description` |

---

## Luồng xử lý: Tạo sản phẩm mới

```
Client
  │ 
  ▼  POST /api/products  {name, price, categoryId, fixedAttributes, extraAttributes}
ProductController.createProduct()
  │
  ▼
ProductService.createProduct()
  ├─► CategoryRepository.findById(categoryId)          → lấy Category
  ├─► AttributeRepository.findByName / findById        → lấy/tạo Attribute
  ├─► new Product(name, price, category)
  ├─► new ProductAttribute(product, attribute, value)  (cho mỗi attribute)
  └─► ProductRepository.save(product)
  │
  ▼
ProductController → ResponseEntity (HTTP 201 Created)
```

---

## Cấu trúc package

```
com.example.product
├── config/
│   ├── CorsConfig.java
│   ├── DataSeeder.java          ← seed dữ liệu mẫu lúc khởi động
│   └── TomcatConfig.java
├── controller/
│   ├── ProductController.java   ← REST API /api/products
│   ├── CategoryController.java  ← REST API /api/categories
│   ├── HomeController.java
│   └── ProductPageServlet.java
├── dto/
│   ├── ProductCreateRequest.java
│   └── ProductResponse.java
├── entity/
│   ├── Product.java
│   ├── Category.java
│   ├── Attribute.java
│   └── ProductAttribute.java
├── repository/
│   ├── ProductRepository.java
│   ├── CategoryRepository.java
│   └── AttributeRepository.java
├── service/
│   └── ProductService.java
└── ProductServiceApplication.java
```

---

## Kiến Trúc Feedback Service

### Sơ đồ kiến trúc (Class Diagram)

```mermaid
classDiagram
    direction TB

    %% ─── Controller Layer ───────────────────────────────────────
    class FeedbackPageController {
        +feedbackStats() : String
    }

    class FeedbackController {
        -feedbackService : FeedbackService
        +getAllFeedbacks() : ResponseEntity
        +getFeedbackById(id : Long) : ResponseEntity
        +getFeedbacksByProduct(productId : Long) : ResponseEntity
        +createFeedback() : ResponseEntity
        +deleteFeedback(id : Long) : ResponseEntity
    }

    %% ─── Service Layer ──────────────────────────────────────────
    class FeedbackService {
        <<Service>>
        -feedbackRepository : FeedbackRepository
        +getAllFeedbacks() : List~Feedback~
        +getFeedbackById(id : Long) : Feedback
        +getFeedbacksByProduct(productId : Long) : List~Feedback~
        +createFeedback() : Feedback
        +deleteFeedback(id : Long) : void
    }

    %% ─── Repository Layer ───────────────────────────────────────
    class FeedbackRepository {
        <<Interface>>
        +findByProductId(productId : Long) : List~Feedback~
    }

    class JpaRepository~T_ID~ {
        <<Interface>>
        +save(entity : T) : T
        +findAll() : List~T~
        +findById(id : ID) : Optional~T~
        +deleteById(id : ID) : void
    }

    %% ─── Entity Layer ───────────────────────────────────────────
    class Feedback {
        <<Entity>>
        -id : Long
        -productId : Long
        -productName : String
        -reviewer : String
        -comment : String
        -overallRating : int
        -createdAt : LocalDateTime
        -attributeRatings : List~AttributeRating~
    }

    class AttributeRating {
        <<Entity>>
        -id : Long
        -feedback : Feedback
        -attributeName : String
        -rating : int
        -comment : String
    }

    %% ─── Cross-service references (product-service) ────────────
    class Product {
        <<product-service>>
        -id : Long
        -name : String
    }
    class Attribute {
        <<product-service>>
        -id : Long
        -name : String
    }

    %% ─── Relationships ──────────────────────────────────────────
    FeedbackPageController --> FeedbackService : uses
    FeedbackController --> FeedbackService : depends on
    FeedbackService --> FeedbackRepository : uses
    FeedbackRepository --|> JpaRepository~Feedback_Long~
    FeedbackRepository ..> Feedback : manages
    Feedback "1" *-- "many" AttributeRating : has
    Feedback ..> Product : references (productId)
    AttributeRating ..> Attribute : references (attributeName)
```

---

## Luồng xử lý: Thống kê phản hồi (3 cấp)

```mermaid
sequenceDiagram
    actor User
    participant Browser
    participant GW as API Gateway :8080
    participant FC as FeedbackController
    participant FS as FeedbackService
    participant FR as FeedbackRepository
    participant DB as MySQL (feedback_db)

    User->>Browser: Truy cập /feedback/stats
    Browser->>GW: GET /feedback/stats
    GW->>FC: route → feedback-pages
    FC-->>Browser: render feedback-stats.jsp

    rect rgb(220, 240, 220)
        Note over Browser,DB: Cấp 1 — Tổng quan sản phẩm (page load)
        Browser->>GW: GET /api/feedbacks
        GW->>FC: getAllFeedbacks()
        FC->>FS: getAllFeedbacks()
        FS->>FR: findAll()
        FR->>DB: SELECT feedbacks + attribute_ratings
        DB-->>FR: rows
        FR-->>FS: List~Feedback~
        FS-->>FC: List~Feedback~
        FC-->>Browser: JSON array
        Note over Browser: groupBy(productId)<br/>→ avgRating, count, phân phối sao 1–5<br/>→ render product cards
    end

    rect rgb(220, 230, 255)
        Note over Browser,DB: Cấp 2 — Danh sách đánh giá (click sản phẩm)
        User->>Browser: Click "Xem đánh giá" (productId)
        Browser->>GW: GET /api/feedbacks/product/{productId}
        GW->>FC: getFeedbacksByProduct(productId)
        FC->>FS: getFeedbacksByProduct(productId)
        FS->>FR: findByProductId(productId)
        FR->>DB: SELECT WHERE product_id = ?
        DB-->>FR: rows
        FR-->>FS: List~Feedback~
        FS-->>FC: List~Feedback~
        FC-->>Browser: JSON array
        Note over Browser: render danh sách<br/>reviewer | ★ rating | ngày | số thuộc tính
    end

    rect rgb(255, 245, 210)
        Note over Browser,DB: Cấp 3 — Chi tiết đánh giá (click review)
        User->>Browser: Click "Chi tiết" (feedbackId)
        Browser->>GW: GET /api/feedbacks/{id}
        GW->>FC: getFeedbackById(id)
        FC->>FS: getFeedbackById(id)
        FS->>FR: findById(id)
        FR->>DB: SELECT WHERE id = ?
        DB-->>FR: row
        FR-->>FS: Feedback
        FS-->>FC: Feedback
        FC-->>Browser: JSON {feedback + attributeRatings[]}
        Note over Browser: render bảng<br/>attributeName | ★ rating | comment
    end
```

### Tổng hợp: Luồng data thống kê

```
GET /api/feedbacks
  └─ feedbacks[]
       │
       ▼ JS (client-side aggregation)
       groupBy(productId) → Map<productId, feedbacks[]>
       │
       ├─ count      = feedbacks.length
       ├─ avgRating  = sum(overallRating) / count
       └─ starDist[1..5] = count per star value
       │
       ▼ render Cấp 1
       [Product Card]  tên SP | ★ avgRating | N đánh giá | thanh phân phối sao


GET /api/feedbacks/product/{productId}
  └─ feedbacks[] (lọc theo sản phẩm)
       │
       ▼ render Cấp 2
       [Review Row]  avatar | reviewer | ★ overallRating | createdAt | N thuộc tính


GET /api/feedbacks/{id}
  └─ feedback { ..., attributeRatings[] }
       │
       ▼ render Cấp 3
       [Detail Table]  attributeName | ★★★★☆ (rating) | comment
```

### Cấu trúc package

```
com.example.feedback
├── config/
│   ├── CorsConfig.java
│   ├── FeedbackDataSeeder.java  ← seed 10 phản hồi mẫu lúc khởi động
│   └── TomcatConfig.java
├── controller/
│   ├── FeedbackPageController.java  ← GET /feedback/stats → JSP
│   └── FeedbackController.java      ← REST API /api/feedbacks
├── entity/
│   ├── Feedback.java
│   └── AttributeRating.java
├── repository/
│   ├── FeedbackRepository.java
│   └── AttributeRatingRepository.java
├── service/
│   └── FeedbackService.java
└── FeedbackServiceApplication.java
```
