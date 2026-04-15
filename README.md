# Demo – Microservices: 3-Service Architecture (User Data Provider, Product, Feedback)

Kiến trúc microservices gồm 3 service độc lập, mỗi service chạy trên port riêng với database riêng.

> **REFACTORED** (v2.1): `user-service` được refactor thành **Data Provider** (chỉ cung cấp API đọc thông tin admin).
> Xem [USER_SERVICE_DATA_PROVIDER.md](USER_SERVICE_DATA_PROVIDER.md) để biết thêm chi tiết.

---

## Cấu trúc tổng quan

```
demo/                        ← Parent POM (multi-module)
├── user-service/            ← Port :8082 | DB: user_db      [Data Provider]
├── product-service/         ← Port :8081 | DB: product_db
├── feedback-service/        ← Port :8083 | DB: feedback_db
└── api-gateway/             ← Port :8080 | Định tuyến request
```

## Cách chạy

### Option 1: Docker Compose (Recommended)

```bash
# Build và khởi động toàn bộ services + databases
docker-compose up -d

# Kiểm tra logs
docker-compose logs -f

# Dừng toàn bộ
docker-compose down
```

### Option 2: Local Development

```bash
# 1. Build toàn bộ
./mvnw clean install -DskipTests

# 2. Chạy từng service (mỗi cái 1 terminal)
cd user-service       && ../mvnw spring-boot:run
cd product-service    && ../mvnw spring-boot:run
cd feedback-service   && ../mvnw spring-boot:run
cd api-gateway        && ../mvnw spring-boot:run
```

Truy cập: `http://localhost:8080` (qua Gateway) hoặc trực tiếp.

---

## Services Overview

### 1. user-service (port 8082, DB: user_db) [Data Provider]

**Mục đích**: Cung cấp API đọc thông tin admin/user để các service khác sử dụng.
- ✅ Cung cấp thông tin admin by ID
- ✅ Cung cấp thông tin khách hàng by ID
- ✅ Liệt kê các admin theo department
- ❌ KHÔNG có registration
- ❌ KHÔNG có login
- ❌ KHÔNG lưu passwords

#### Endpoints:
- `GET /api/users/{id}` - Lấy thông tin admin by ID
- `GET /api/users/by-username/{username}` - Lấy thông tin admin by username
- `GET /api/customers/{id}` - Lấy thông tin khách hàng (cho feedback-service dùng)
- `GET /api/users` - Liệt kê tất cả admin đang hoạt động
- `GET /api/users/department/{department}` - Liệt kê admin theo department

#### Database: user_db
```sql
admins (id, username, full_name, email, tel, department, status, created_at)
```

#### Được sử dụng bởi:
- **product-service**: Lấy thông tin admin khi tạo/cập nhật sản phẩm
- **feedback-service**: Lấy thông tin người feedback/khách hàng
- **Statistics/Reports**: Xem thông tin admin chi tiết

#### Sample Users (created by DataSeeder)
- `admin` - Department: Management
- `manager1` - Department: Product
- `manager2` - Department: Product
- `feedback_manager` - Department: Quality

---

### 2. product-service (port 8081, DB: product_db)

Quản lý sản phẩm, danh mục, thuộc tính. **Không còn xử lý xác thực (Auth)** - tất cả user management đã chuyển sang user-service (Data Provider).

#### Gọi inter-service:
- **user-service**: Lấy thông tin admin (who created/updated this product)

#### `ProductServiceApplication.java`
Điểm khởi động. Kế thừa `SpringBootServletInitializer` để hỗ trợ WAR.

#### config/

| File | Tác dụng |
|------|----------|
| `DataSeeder.java` | Seed dữ liệu mẫu khi khởi động: 10 thuộc tính + 5 danh mục + 10 sản phẩm mẫu. |
| `CorsConfig.java` | Cho phép CORS giữa các service. |

#### controller/

| File | Tác dụng |
|------|----------|
| `HomeController.java` | `GET /` → trang chủ `main.jsp`. |
| `ProductPageServlet.java` | `GET /products/add` → trang thêm sản phẩm. |
| `ProductController.java` | REST: `GET/POST/PUT/DELETE /api/products`. |
| `CategoryController.java` | REST: `GET /api/categories`, `GET /api/categories/{id}/attributes`. |

#### dto/

| File | Tác dụng |
|------|----------|
| `ProductCreateRequest.java` | DTO nhận dữ liệu khi tạo sản phẩm (tên, giá, danh mục, thuộc tính). |
| `ProductResponse.java` | DTO trả về thông tin sản phẩm. |

#### entity/

| File | Tác dụng |
|------|----------|
| `Category.java` | Entity danh mục. Liên kết nhiều-nhiều với Attribute. |
| `Product.java` | Entity sản phẩm. Thuộc 1 danh mục, có danh sách thuộc tính riêng. |
| `Attribute.java` | Entity thuộc tính (Thương hiệu, Màu sắc, ...). |
| `ProductAttribute.java` | Entity trung gian nối Product–Attribute, lưu giá trị cụ thể. |

#### repository/

| File | Tác dụng |
|------|----------|
| `ProductRepository.java` | CRUD cho Product. |
| `CategoryRepository.java` | CRUD cho Category. |
| `AttributeRepository.java` | CRUD + `findByName()` cho Attribute. |

#### service/

| File | Tác dụng |
|------|----------|
| `ProductService.java` | Logic nghiệp vụ: tạo, liệt kê, xoá sản phẩm. |

---

### 3. feedback-service (port 8083, DB: feedback_db)

Quản lý phản hồi của người dùng về sản phẩm. Đánh giá tổng + đánh giá chi tiết trên từng thuộc tính.

**Gọi inter-service**:
- `user-service` (8082) để xác minh người dùng
- `product-service` (8081) để kiểm tra sản phẩm

#### `FeedbackServiceApplication.java`
Điểm khởi động.

#### config/

| File | Tác dụng |
|------|----------|
| `CorsConfig.java` | Cho phép CORS giữa các service. |
| `RestTemplateConfig.java` | Cấu hình RestTemplate cho inter-service calls. |

#### controller/

| File | Tác dụng |
|------|----------|
| `FeedbackController.java` | REST: `GET/POST/PUT/DELETE /api/feedbacks`, `GET /api/feedbacks/product/{id}`. |
| `FeedbackPageController.java` | `GET /feedback/stats` → trang thống kê phản hồi. |

#### dto/

| File | Tác dụng |
|------|----------|
| `FeedbackCreateRequest.java` | DTO nhận dữ liệu phản hồi (sản phẩm, người đánh giá, điểm tổng, đánh giá từng thuộc tính). |
| `FeedbackResponse.java` | DTO trả về thông tin phản hồi đầy đủ. |
| `ProductDto.java` | DTO để lấy thông tin sản phẩm từ product-service. |

#### entity/

| File | Tác dụng |
|------|----------|
| `Feedback.java` | Entity phản hồi: productId, userId, overallRating (1-5), comment. |
| `AttributeRating.java` | Entity đánh giá chi tiết trên từng thuộc tính: attributeName, rating (1-5), comment. |

#### repository/

| File | Tác dụng |
|------|----------|
| `FeedbackRepository.java` | CRUD + `findByProductId()`. |
| `AttributeRatingRepository.java` | CRUD cho AttributeRating. |

#### client/

| File | Tác dụng |
|------|----------|
| `ProductServiceClient.java` | Gọi product-service để lấy danh sách attributes. |

#### service/

| `FeedbackService.java` | Logic: tạo phản hồi (kèm đánh giá thuộc tính), liệt kê, xem chi tiết, xoá. Gọi user-service & product-service. |

---

### 4. api-gateway (port 8080)

Cổng trung tâm định tuyến request đến các service.

#### `ApiGatewayApplication.java`
Điểm khởi động.

#### Routing (spring.cloud.gateway.routes)

| Route ID | Predicate | Target Service | Port |
|----------|-----------|-----------------|------|
| `user-service` | `/api/users/**` | user-service | 8082 |
| `product-service` | `/api/products/**`, `/api/categories/**` | product-service | 8081 |
| `product-pages` | `/`, `/products/**` | product-service | 8081 |
| `feedback-service` | `/api/feedbacks/**` | feedback-service | 8083 |
| `feedback-pages` | `/feedback/**` | feedback-service | 8083 |

---

## Thay đổi chính (v2.1) - User Service as Data Provider

### user-service (Refactored):
- ❌ KHÔNG có registration
- ❌ KHÔNG có login
- ❌ KHÔNG lưu passwords
- ✅ CHỈ cung cấp API đọc thông tin admin
- ✅ GET /api/users/{id} - Lấy thông tin admin
- ✅ GET /api/customers/{id} - Lấy thông tin khách hàng
- ✅ GET /api/users - Liệt kê all active admins
- ✅ Được sử dụng bởi product-service và feedback-service

### product-service (Không thay đổi):
- ✅ Quản lý products, categories, attributes
- ❌ Không có authentication logic

### feedback-service (Cập nhật):
- ✅ Port: 8082 → 8083
- ✅ Gọi user-service để lấy reviewer info
- ✅ Gọi product-service để lấy product info

### api-gateway (Cập nhật):
- ✅ Routes: `/api/users/**` → user-service (Data Provider)
- ✅ Routes: `/api/customers/**` → user-service (Data Provider)

---

## Port Mapping

| Service | Internal Port | Docker Port | Database | DB Port |
|---------|---|---|---|---|
| user-service | 8082 | 8082 | user_db | 3306 |
| product-service | 8081 | 8081 | product_db | 3307 |
| feedback-service | 8083 | 8083 | feedback_db | 3308 |
| api-gateway | 8080 | 8888 | - | - |

---

## Cơ chế Inter-Service Communication

### Product Service → User Service
```
When displaying products:
GET /api/users/{admin_id}
→ Show "Created by: Admin Name"
```

### Feedback Service → User Service
```
When displaying feedback:
GET /api/users/{reviewer_id}
→ Show "Reviewed by: Admin Name"

GET /api/customers/{customer_id}
→ Show "Customer: Jane Smith"
```

---