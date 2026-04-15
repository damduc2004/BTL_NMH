# BÁO CÁO THIẾT KẾ HỆ THỐNG MICROSERVICES
## Demo – Product & Feedback Management System

---

## MỤC LỤC

1. [Kiến trúc hệ thống](#1-kiến-trúc-hệ-thống)
2. [Các module được trình bày](#2-các-module-được-trình-bày)
3. [Hoạt động của từng module](#3-hoạt-động-của-từng-module)
4. [Thiết kế thực thể (Entity Design)](#4-thiết-kế-thực-thể)
5. [Thiết kế CSDL](#5-thiết-kế-csdl)
6. [Thiết kế chi tiết – Module Quản lý Sản phẩm (product-service)](#6-thiết-kế-chi-tiết--module-quản-lý-sản-phẩm)
7. [Thiết kế chi tiết – Module Phản hồi (feedback-service)](#7-thiết-kế-chi-tiết--module-phản-hồi)
8. [Thiết kế chi tiết – API Gateway](#8-thiết-kế-chi-tiết--api-gateway)

---

## 1. KIẾN TRÚC HỆ THỐNG

### 1.1 Kiến trúc theo chiều dọc – Microservices

Hệ thống được triển khai theo kiến trúc **Microservices**, mỗi service hoạt động độc lập, có database riêng, giao tiếp qua REST API qua một **API Gateway** trung tâm.

```
Client (Browser)
      │
      ▼
┌─────────────────┐
│   API Gateway   │  :8080 (Spring Cloud Gateway)
└────────┬────────┘
         │ Định tuyến theo path
    ┌────┴────┐
    ▼         ▼
┌─────────┐  ┌──────────────┐
│product  │  │ feedback     │
│service  │  │ service      │
│:8081    │  │ :8082        │
└────┬────┘  └──────┬───────┘
     │               │
┌────┴────┐  ┌───────┴──────┐
│product  │  │ feedback_db  │
│_db      │  │  (MySQL)     │
│(MySQL)  │  └──────────────┘
└─────────┘
```

**Ưu điểm của Microservices:**
- Mỗi service được triển khai, mở rộng, cập nhật độc lập.
- Lỗi ở một service không kéo sập toàn hệ thống.
- Database tách biệt (product_db, feedback_db) giúp tránh coupling.
- feedback-service tham chiếu `productId` qua giá trị (không foreign key thật), đúng nguyên tắc bounded context.

### 1.2 Kiến trúc theo chiều ngang – MVC

Mỗi service đều áp dụng kiến trúc **MVC (Model–View–Controller)**:

```
Request
   │
   ▼
Controller  ←→  Service  ←→  Repository  ←→  Database
   │                │
   │           (Business Logic)
   ▼
View (JSP)  /  JSON Response
```

| Lớp | Vai trò | Ví dụ |
|-----|---------|-------|
| Controller | Nhận HTTP request, gọi Service, trả response | `ProductController`, `FeedbackController` |
| Service | Chứa business logic, xử lý nghiệp vụ | `ProductService`, `FeedbackService` |
| Repository | Truy cập CSDL qua Spring Data JPA | `ProductRepository`, `FeedbackRepository` |
| Entity/Model | Ánh xạ bảng CSDL | `Product`, `Feedback`, ... |
| DTO | Truyền dữ liệu vào/ra, tách biệt Entity | `ProductCreateRequest`, `FeedbackResponse` |
| View | Giao diện người dùng (JSP) | `main.jsp`, `add-product.jsp`, `feedback-stats.jsp` |

---

## 2. CÁC MODULE ĐƯỢC TRÌNH BÀY

| # | Module | Service | Lý do chọn |
|---|--------|---------|------------|
| 1 | **Xác thực & Phân Quyền (ADMIN/USER)** | product-service | BCrypt password hash, session-based auth, role-based access (ADMIN quản lý, USER gửi feedback) |
| 2 | **Quản lý Sản phẩm & Thuộc Tính** | product-service | **Chỉ ADMIN được dùng**: Tìm kiếm full-text, thêm mới với 2 loại thuộc tính (fixed + extra), số lượng tồn kho, xóa cascade |
| 3 | **Thống kê Phản hồi từ Khách hàng** | feedback-service | Phản hồi được gửi bởi USER (không phải ADMIN); thiết kế 1-nhiều lồng (Feedback → AttributeRating) |
| 4 | **Định tuyến tập trung qua API Gateway** | api-gateway | Một điểm vào duy nhất, routing theo path pattern, tích hợp các route xác thực |

---

## 3. HOẠT ĐỘNG CỦA TỪNG MODULE

### Module 1: Xác thực & Phân Quyền (product-service)

**Phân Quyền:**
- **ADMIN**: Đăng nhập vào hệ thống quản trị, quản lý sản phẩm, xem thống kê phản hồi. Trang chủ có menu **Quản lý sản phẩm** + **Xem phản hồi**.
- **USER** (Khách hàng): Chỉ được gửi phản hồi (feedback) về sản phẩm, không truy cập trang quản trị.

**Luồng đăng nhập (ADMIN):**
1. Khách truy cập `http://localhost:8080/` → `AuthInterceptor` kiểm tra session, chưa có → redirect đến `/login`.
2. Hệ thống hiển thị trang đăng nhập (`login.jsp`):

```
┌────────────────────────────────────────────────┐
│                                                │
│                📦                              │
│          Product Manager                       │
│      Hệ thống quản trị sản phẩm               │
│                                                │
│   Tên đăng nhập                                │
│   [________________________]                   │
│                                                │
│   Mật khẩu                                     │
│   [________________________]                   │
│                                                │
│          [ Đăng nhập ]                         │
│                                                │
│     Demo: admin / admin123                     │
└────────────────────────────────────────────────┘
```

3. Người dùng nhập `admin` / `admin123` → gửi `POST /login`.
4. `AuthController` tra cứu `UserRepository`, so khớp BCrypt hash → tạo session attribute `loggedUser`.
5. Redirect về `/` → `AuthInterceptor` thấy session hợp lệ → vào dashboard.

**Luồng đăng xuất:** Nhấn **Đăng xuất** → `GET /logout` → `session.invalidate()` → redirect về `/login`.

---

### Module 2: Quản lý Sản phẩm và Thuộc Tính Sản Phẩm (product-service)

**Trang Dashboard (`/` → `main.jsp`):**

```
┌────────────────────────────────────────────────────────────────────┐
│  📦 Product Manager                    👤 Quan tri vien  [Đăng xuất]│
├────────────────────────────────────────────────────────────────────┤
│               Chào mừng, Quan tri vien!                            │
│        Hệ thống quản lý sản phẩm và thống kê phản hồi             │
│                                                                    │
│   ┌──────────────────────────┐  ┌──────────────────────────┐      │
│   │  📦 Quản lý sản phẩm    │  │  ⭐ Thống kê phản hồi    │      │
│   │  Tìm kiếm, thêm mới,    │  │  Xem thống kê phản hồi   │      │
│   │  xóa sản phẩm. Gán danh │  │  của khách hàng. Chi tiết│      │
│   │  mục & thuộc tính.      │  │  điểm đánh giá theo từng │      │
│   │                          │  │  thuộc tính sản phẩm.    │      │
│   │  [Quản lý sản phẩm]     │  │  [Xem thống kê]          │      │
│   └──────────────────────────┘  └──────────────────────────┘      │
└────────────────────────────────────────────────────────────────────┘
```

**Luồng quản lý sản phẩm:**
1. Người dùng nhấn **Quản lý sản phẩm** → hệ thống hiển thị trang quản lý (`add-product.jsp`):

```
┌────────────────────────────────────────────────────────────────────────┐
│  ← Trang chủ  📦 Quản lý sản phẩm       👤 Quan tri vien  [Đăng xuất]│
├────────────────────────────────────────────────────────────────────────┤
│  Danh sách sản phẩm                                                    │
│  ┌──────────────────────────────────────────────┬──────────────────┐  │
│  │ 🔍 [Tìm kiếm sản phẩm hoặc danh mục...     ] │[🔍 Tìm kiếm][+Thêm]│
│  └──────────────────────────────────────────────┴──────────────────┘  │
│  ┌─────┬───────────────┬────────────┬──────────┬──────────┬──────┬──┐ │
│  │ ID  │ Tên sản phẩm  │     Giá    │ Tồn kho  │ Danh mục │Thuộc│  │ │
│  ├─────┼───────────────┼────────────┼──────────┼──────────┼─────┼──┤ │
│  │ #1  │ iPhone 15 Pro │ 25.000.000₫│    50    │[Điện thoại]│[tag]│[X]│
│  │ #2  │ Samsung S25   │ 22.000.000₫│    30    │[Điện thoại]│[..]│[X]│
│  └─────┴───────────────┴────────────┴──────────┴──────────┴─────┴──┘ │
└────────────────────────────────────────────────────────────────────────┘
```

**Luồng tìm kiếm sản phẩm:**
- Người dùng nhập từ khóa vào ô tìm kiếm → nhấn **Tìm kiếm** hoặc gõ Enter.
- Hệ thống gọi `GET /api/products?keyword=<từ khóa>` → `ProductService.searchProducts()` → tìm theo tên hoặc danh mục (JPQL LIKE).
- Kết quả hiển thị ngay lập tức trong bảng.

**Luồng thêm sản phẩm mới:**
1. Người dùng nhấn **+ Thêm mới sản phẩm** → panel thêm mới hiện ra phía trên bảng.

```
┌────────────────────────────────────────────────────────────────────────┐
│  Thêm sản phẩm mới                                                     │
│  ┌──────────────────┬──────────────────┬──────────────────────┐       │
│  │ Tên sản phẩm *   │ Giá (VNĐ) *      │ Số lượng tồn kho     │       │
│  │[________________]│ [_______________] │ [____________________]│       │
│  └──────────────────┴──────────────────┴──────────────────────┘       │
│  Danh mục *  [▼ Chọn danh mục ──────────────────────]                 │
└────────────────────────────────────────────────────────────────────────┘
```

2. Hệ thống tự động tải danh sách danh mục từ `GET /api/categories` vào dropdown **Danh mục**.
3. Người dùng nhập **Tên sản phẩm**, **Giá**, **Số lượng tồn kho**, chọn **Danh mục**.
4. Khi người dùng chọn danh mục, hệ thống gọi `GET /api/categories/{id}/attributes` và hiển thị **Thuộc tính cố định** của danh mục đó:

```
│  Thuộc tính danh mục                          │
│  ┌──────────────────────────────────────────┐ │
│  │ [✓] Màu sắc      [_________________]    │ │
│  │ [✓] Kích cỡ      [_________________]    │ │
│  │ [✓] Chất liệu    [_________________]    │ │
│  └──────────────────────────────────────────┘ │
│  (bỏ tích để bỏ qua một thuộc tính)           │
```

5. Người dùng nhập giá trị cho từng thuộc tính cố định (có thể bỏ tích để bỏ qua).
6. Người dùng thêm **Thuộc tính bổ sung** nếu cần (nhấn **+ Thêm**, nhập tên + giá trị tự do):

```
│  Thuộc tính bổ sung            [+ Thêm]      │
│  ┌────────────────┬──────────────┬──────┐    │
│  │ Xuất xứ        │ Việt Nam     │  [✕] │    │
│  │ Bảo hành       │ 12 tháng     │  [✕] │    │
│  └────────────────┴──────────────┴──────┘    │
```

7. Người dùng nhấn **Lưu sản phẩm** → hệ thống gửi `POST /api/products`, xử lý và lưu bao gồm cả thuộc tính cố định và thuộc tính bổ sung (tự động tạo `Attribute` mới nếu chưa tồn tại).
8. Hệ thống thông báo **thêm thành công** (tên + ID sản phẩm) và tự động cập nhật danh sách bên phải.

**Luồng xoá sản phẩm:**
1. Trong danh sách sản phẩm bên phải, người dùng nhấn nút **Xóa** tương ứng với sản phẩm.
2. Hệ thống hiển thị hộp thoại xác nhận.
3. Người dùng xác nhận → hệ thống gọi `DELETE /api/products/{id}`, xóa sản phẩm và tất cả thuộc tính liên quan (cascade), cập nhật lại danh sách.

---

### Module 2: Thống Kê Phản Hồi của Người Dùng về Sản Phẩm (feedback-service)

**⚠️ BẢO VỆ**: Chỉ user có **role = USER** (khách hàng) được gửi feedback. ADMIN không thể gửi.

**Luồng truy cập trang thống kê phản hồi:**
1. Người dùng nhấn **Xem phản hồi** từ trang chủ (hoặc chọn menu **Phản hồi**).
2. Hệ thống hiển thị trang `feedback-stats.jsp` với giao diện 2 cột:

```
┌────────────────────────────────────────────────────────────────────────┐
│  📦 Product Manager          [Trang chủ] [Sản phẩm] [Phản hồi*]       │
├──────────────────────┬─────────────────────────────────────────────────┤
│                      │  [Breadcrumb: 📊 Tất cả sản phẩm]              │
│  ✏️ Gửi phản hồi mới  │                                                 │
│  ────────────────── │  📊 Tổng quan phản hồi    X sản phẩm • Y đánh giá│
│  Chọn sản phẩm *    │  ┌──────────────┐  ┌──────────────┐             │
│  [▼ Chọn SP...   ]  │  │ Sản phẩm A   │  │ Sản phẩm B   │             │
│                      │  │ 4.2  ★★★★☆   │  │ 3.8  ★★★★☆   │             │
│  Tên người đánh giá*│  │ 12 đánh giá  │  │ 5 đánh giá   │             │
│  [__________________]│  │ 5 ████ 6     │  │ 5 ██   2     │             │
│                      │  │ 4 ███  4     │  │ 4 ███  3     │             │
│  Đánh giá tổng *    │  │ 3 ██   2     │  │ ...          │             │
│  [▼ ⭐ 5 sao      ]  │  │ ...          │  │[Xem 5 PH ›]  │             │
│                      │  │[Xem 12 PH ›] │  └──────────────┘             │
│  Nhận xét chung     │  └──────────────┘                                │
│  [________________] │                                                   │
│                      │                                                  │
│  Đánh giá theo thuộc│                                                  │
│  tính               │                                                  │
│  [hint: chọn SP]    │                                                  │
│                      │                                                  │
│  [ ✓ Gửi phản hồi ] │                                                  │
└──────────────────────┴──────────────────────────────────────────────────┘
```

**Luồng gửi phản hồi:**
1. Người dùng chọn **Sản phẩm** từ dropdown → hệ thống hiển thị các thuộc tính của sản phẩm đó trong vùng **Đánh giá theo từng thuộc tính**:

```
│  Đánh giá theo từng thuộc tính               │
│  ┌──────────────────┬────────┬─────────────┐ │
│  │ Màu sắc          │[▼ 4 ]  │[Nhận xét...] │ │
│  │ Kích cỡ          │[▼ 5 ]  │[Nhận xét...] │ │
│  │ Chất liệu        │[▼ 3 ]  │[Nhận xét...] │ │
│  └──────────────────┴────────┴─────────────┘ │
│  (điểm 1-5 cho mỗi thuộc tính + nhận xét)   │
```

2. Người dùng nhập **Tên người đánh giá**, chọn **Đánh giá tổng** (1–5 sao), nhập **Nhận xét chung**.
3. Người dùng chọn điểm và nhập nhận xét cho từng thuộc tính sản phẩm.
4. Người dùng nhấn **Gửi phản hồi** → hệ thống lưu phản hồi và tự động cập nhật vùng thống kê bên phải.
5. Hệ thống thông báo **gửi thành công**.

**Luồng xem thống kê – Cấp 1: Tổng quan tất cả sản phẩm:**
- Màn hình bên phải hiển thị lưới card các sản phẩm, sắp xếp theo số lượng phản hồi nhiều nhất trên cùng.
- Mỗi card sản phẩm gồm: tên sản phẩm, điểm trung bình, số sao, số lượng đánh giá, phân bố điểm theo từng mức sao (1–5) dưới dạng thanh bar.
- Người dùng nhấn **Xem X phản hồi** hoặc click vào card → chuyển sang Cấp 2.

**Luồng xem thống kê – Cấp 2: Danh sách phản hồi của một sản phẩm:**

```
│  [Breadcrumb: 📊 Tất cả sản phẩm › Sản phẩm A]    [← Quay lại] │
│  Sản phẩm A                                                      │
│  ★★★★☆ 4.2/5 • 12 đánh giá                                      │
│  ┌────────────────────────────────────────────────────────┐     │
│  │ [A]  Nguyễn Văn A            ★★★★★ 5      🕐 2026-04-10 │     │
│  │      "Sản phẩm rất tốt, đáng tiền."                   │     │
│  │      📋 3 thuộc tính được đánh giá                     │     │
│  │      [ Xem chi tiết › ]  [ Xóa ]                      │     │
│  ├────────────────────────────────────────────────────────┤     │
│  │ [T]  Trần Thị B              ★★★★☆ 4      🕐 2026-04-08 │     │
│  │      "Chất lượng ổn, giao hàng nhanh."                │     │
│  │      📋 3 thuộc tính được đánh giá                     │     │
│  │      [ Xem chi tiết › ]  [ Xóa ]                      │     │
│  └────────────────────────────────────────────────────────┘     │
```

- Danh sách phản hồi sắp xếp mới nhất trên cùng.
- Mỗi phản hồi hiển thị: avatar (chữ cái đầu tên), tên người đánh giá, thời gian, điểm tổng (badge màu), nhận xét chung, số thuộc tính được đánh giá.
- Người dùng nhấn **Xem chi tiết** → chuyển sang Cấp 3.

**Luồng xem thống kê – Cấp 3: Chi tiết phản hồi theo từng thuộc tính sản phẩm:**

```
│  [Breadcrumb: 📊 Tất cả › Sản phẩm A › Phản hồi #5 – Nguyễn Văn A] │
│                                                                      │
│  ┌─────────────── (Hero card nền xanh gradient) ─────────────────┐  │
│  │  📦 Sản phẩm A                                                │  │
│  │  Nguyễn Văn A                                                 │  │
│  │  ★★★★★ 5/5 sao   🕐 2026-04-10 10:30   Phản hồi #5           │  │
│  │  " Sản phẩm rất tốt, màu sắc đẹp, đáng mua. "               │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  📋 Đánh giá chi tiết theo thuộc tính      [← Quay lại]            │
│  ┌──────────────┬──────────────────┬───────────────────────────┐   │
│  │ Thuộc tính   │ Điểm             │ Nhận xét                  │   │
│  ├──────────────┼──────────────────┼───────────────────────────┤   │
│  │ Màu sắc      │ ★★★★★ 5 (xanh)  │ "Màu rất đẹp"             │   │
│  │ Kích cỡ      │ ★★★★☆ 4 (xanh)  │ "Vừa vặn"                 │   │
│  │ Chất liệu    │ ★★★☆☆ 3 (vàng)  │ "Ổn, nhưng có thể tốt hơn"│   │
│  └──────────────┴──────────────────┴───────────────────────────┘   │
```

- Hệ thống hiển thị thông tin chi tiết phản hồi: tên sản phẩm, tên người đánh giá, điểm tổng, thời gian, nhận xét chung (trên hero card).
- Bảng đánh giá chi tiết theo từng thuộc tính: tên thuộc tính, điểm số kèm sao và badge màu (xanh ≥4, vàng =3, đỏ ≤2), nhận xét riêng cho từng thuộc tính.
- Người dùng nhấn **Quay lại** để về Cấp 2, hoặc nhấn breadcrumb để về Cấp 1.

---

## 4. THIẾT KẾ THỰC THỂ

### 4.1 Tổng hợp các thực thể của hệ thống

Hệ thống gồm 2 service độc lập, mỗi service có CSDL riêng với các thực thể sau:

| Service | Thực thể | Vai trò | Các thuộc tính |
|---------|----------|---------|----------------|
| **product-service** | **Category** | Danh mục sản phẩm | id, name |
| **product-service** | **Attribute** | Danh sách thuộc tính | id, name |
| **product-service** | **User** | Tài khoản (ADMIN + USER) | id, username, password (BCrypt), fullName, email, tel, role, status |
| **product-service** | **Product** | Thông tin sản phẩm | id, name, price, stockQuantity, category (FK) |
| **product-service** | **ProductAttribute** | Giá trị thuộc tính sản phẩm | id, product (FK), attribute (FK), value |
| **feedback-service** | **Feedback** | Phản hồi khách hàng | id, productId (logic ref), productName, user_id (FK - chỉ USER), comment, overallRating (1–5), createdAt |
| **feedback-service** | **AttributeRating** | Đánh giá chi tiết thuộc tính | id, feedback (FK), attributeName, rating (1–5), comment |

> **Lưu ý về phân chia vai trò:** `User.role` có 2 giá trị:
> - **ADMIN**: Đăng nhập vào trang quản lý, quản trị sản phẩm, xem thống kê phản hồi. **KHÔNG thể** gửi feedback.
> - **USER** (Khách hàng): Chỉ có quyền gửi phản hồi (feedback) về sản phẩm. `Feedback.user_id` **bắt buộc** phải là USER, không phải ADMIN.

### 4.2 Biểu đồ lớp thực thể tổng hợp

```
═══════════════════════════ UNIFIED DATABASE (shared_db) ═══════════════════════════

  ┌────────────────────────────────┐
  │             User               │  (ADMIN + USER)
  ├────────────────────────────────┤
  │ id       : Long (PK)           │
  │ username : String (unique)     │
  │ password : String (BCrypt)     │
  │ fullName : String              │
  │ email    : String              │
  │ tel      : String              │
  │ role     : String              │  ← ADMIN: quản lý | USER: gửi feedback
  │ status   : boolean             │
  └────────────────────────────────┘

  ┌──────────────┐   N─────N   ┌──────────────────┐
  │  Category    │             │   Attribute      │
  ├──────────────┤(category_   ├──────────────────┤
  │ id    : Long │ attributes  │ id   : Long      │
  │ name  : Str. │ join table) │ name : String    │
  └──────┬───────┘             └────────▲─────────┘
         │ 1                            │ 1
         │                              │
         │ N                            │ N
  ┌──────▼───────────────┐      ┌───────┴──────────────┐
  │     Product          │ 1──N │  ProductAttribute    │
  ├──────────────────────┤      ├──────────────────────┤
  │ id       : Long      │      │ id        : Long     │
  │ name     : String    │      │ product   : FK       │
  │ price    : Decimal   │      │ attribute : FK       │
  │ stockQty : Integer   │      │ value     : String   │
  │ category : FK        │      └──────────────────────┘
  └──────────────────────┘

  ┌──────────────────────────────────┐  1──N  ┌────────────────────────┐
  │           Feedback               │        │    AttributeRating     │
  ├──────────────────────────────────┤        ├────────────────────────┤
  │ id            : Long             │        │ id            : Long   │
  │ product_id    : Long  ────────┐  │        │ feedback      : FK     │
  │ product_name  : String        │  │        │ attributeName : String │
  │ user          : FK ────────┐  │  │        │ rating        : Int(1-5)│
  │ comment       : String     │  │  │        │ comment       : String │
  │ overall_rating: Int (1-5)  │  │  │        └────────────────────────┘
  │ created_at    : LocalDateTime│  │
  │ attributeRatings: 1─N       │  │
  └──────────────────────────────────┘
         │                          │
         │ FK (thật) [Product.id]  │
         │ (logical ref)            │
         │                          └─ [User.id]
         │                             (FK - bắt buộc)
         └─ Tham chiếu chéo DB

  ┌─────────────────────────────────────────────────────────┐
  │                  MỐI QUAN HỆ TÓM TẮT                    │
  ├─────────────────────────────────────────────────────────┤
  │ Categories ◄──1:N──► Products                           │
  │ Categories ◄──N:N──► Attributes (category_attributes)   │
  │ Products ◄──N:N──► Attributes (product_attributes)      │
  │ Products ◄──1:N──► Feedbacks (logical ref)              │
  │ Users ◄──1:N──► Feedbacks (role=USER only)              │
  │ Feedbacks ◄──1:N──► AttributeRatings                     │
  └─────────────────────────────────────────────────────────┘
```

---

### 4.2 Mối quan hệ giữa các thực thể

**Trong product-service (product_db):**

| Quan hệ | Loại | Mô tả |
|---------|------|-------|
| Category — Product | **1 – N** | Một danh mục chứa nhiều sản phẩm; một sản phẩm thuộc đúng một danh mục |
| Category — Attribute | **N – N** | Một danh mục có nhiều thuộc tính cố định; một thuộc tính có thể gắn với nhiều danh mục. Quan hệ quản lý ẩn qua bảng `category_attributes` |
| Product — Attribute | **N – N** | Tách thành thực thể trung gian **ProductAttribute** (có thêm trường `value` – giá trị thuộc tính của sản phẩm đó). Quan hệ: Product – ProductAttribute (1–N); Attribute – ProductAttribute (1–N) |

**Trong feedback-service (feedback_db):**

| Quan hệ | Loại | Mô tả |
|---------|------|-------|
| Feedback — AttributeRating | **1 – N** | Một phản hồi có thể có điểm đánh giá cho nhiều thuộc tính; cascade lưu và xóa |
| Feedback → Product | **tham chiếu logic** | `Feedback.productId` lưu ID sản phẩm từ product-service nhưng không có foreign key thật (2 service dùng 2 DB độc lập) |
| User → Feedback | **1 – N** (USER only) | **Chỉ user có role=USER** mới được gửi feedback (FK bắt buộc); ADMIN không thể gửi feedback |

---

### 4.3 Biểu đồ lớp thực thể tổng hợp

**Kiến trúc Unified Database (tất cả dữ liệu trong 1 DB):**

```
═══════════════════════════ UNIFIED DATABASE (shared_db) ═══════════════════════════

  ┌────────────────────────────────┐
  │             User               │  (ADMIN + CUSTOMER)
  ├────────────────────────────────┤
  │ id       : Long (PK)           │
  │ username : String (unique)     │
  │ password : String (BCrypt)     │
  │ fullName : String              │
  │ email    : String              │
  │ tel      : String              │
  │ role     : String              │  ← ADMIN: quản lý | USER: gửi feedback
  │ status   : boolean             │
  └────────────────────────────────┘

  ┌──────────────┐   N─────N   ┌──────────────────┐
  │  Category    │             │   Attribute      │
  ├──────────────┤(category_   ├──────────────────┤
  │ id    : Long │ attributes  │ id   : Long      │
  │ name  : Str. │ join table) │ name : String    │
  └──────┬───────┘             └────────▲─────────┘
         │ 1                            │ 1
         │                              │
         │ N                            │ N
  ┌──────▼───────────────┐      ┌───────┴──────────────┐
  │     Product          │ 1──N │  ProductAttribute    │
  ├──────────────────────┤      ├──────────────────────┤
  │ id       : Long      │      │ id        : Long     │
  │ name     : String    │      │ product   : FK       │
  │ price    : Decimal   │      │ attribute : FK       │
  │ stockQty : Integer   │      │ value     : String   │
  │ category : FK        │      └──────────────────────┘
  └──────────────────────┘

  ┌──────────────────────────────────┐  1──N  ┌────────────────────────┐
  │           Feedback               │        │    AttributeRating     │
  ├──────────────────────────────────┤        ├────────────────────────┤
  │ id            : Long             │        │ id            : Long   │
  │ product_id    : Long  ────────┐  │        │ feedback      : FK     │
  │ product_name  : String        │  │        │ attributeName : String │
  │ user          : FK ────────┐  │  │        │ rating        : Int(1-5)│
  │ comment       : String     │  │  │        │ comment       : String │
  │ overall_rating: Int (1-5)  │  │  │        └────────────────────────┘
  │ created_at    : LocalDateTime│  │
  │ attributeRatings: 1─N       │  │
  └──────────────────────────────────┘
         │                          │
         │ FK (thật) [Product.id]  │
         │ (logical ref)            │
         │                          └─ [User.id]
         │                             (FK - bắt buộc)
         └─ Tham chiếu chéo DB

  ┌─────────────────────────────────────────────────────────┐
  │                  RELATIONSHIP SUMMARY                   │
  ├─────────────────────────────────────────────────────────┤
  │ Categories ◄──1:N──► Products                           │
  │ Categories ◄──N:N──► Attributes (via category_attributes)│
  │ Products ◄──N:N──► Attributes (via product_attributes)  │
  │ Products ◄──1:N──► Feedbacks (logical ref)              │
  │ Users ◄──1:N──► Feedbacks                               │
  │ Feedbacks ◄──1:N──► AttributeRatings                     │
  └─────────────────────────────────────────────────────────┘
```

**Ghi chú về Database Unity:**

| Aspek | Chi tiết |
|--------|---------|
| **Số Database** | **1 database duy nhất**: `shared_db` chứa tất cả bảng |
| **Foreign Keys** | Tất cả FK đều thật (FK constraints bật), có thể JOIN trực tiếp giữa `Feedback` ↔ `Product` ↔ `Category` |
| **Tham chiếu** | `Feedback.product_id` là **actual FK** tới `Product.id` — không phải logical reference |
| **Vai trò User** | `User.role` phân biệt: **ADMIN** (quản lý) và **USER** (gửi feedback); chỉ USER mới được tạo Feedback |
| **Ưu điểm** | Đơn giản, JOIN dễ dàng, transaction ACID trên toàn bộ dữ liệu |
| **Nhược điểm** | Coupling cao; scaling khó; phải quản lý 1 DB lớn cho cả product-service và feedback-service |

**Cấu trúc bảng cụ thể:**
- `users`: Tài khoản (role=ADMIN quản lý sản phẩm, role=USER gửi feedback)
- `categories`: Danh mục sản phẩm
- `attributes`: Danh sách thuộc tính
- `category_attributes`: Ánh xạ danh mục ↔ thuộc tính (N:N)
- `products`: Danh sách sản phẩm
- `product_attributes`: Giá trị thuộc tính của mỗi sản phẩm
- `feedbacks`: Phản hồi sản phẩm (FK tới products + **FK tới users[role=USER]** - chỉ khách hàng gửi)
- `attribute_ratings`: Đánh giá từng thuộc tính (FK tới feedbacks)

---

## 5. THIẾT KẾ CSDL

### 5.1 Database: `product_db`

```sql
-- Bảng tài khoản quản trị
CREATE TABLE users (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    username   VARCHAR(100) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,              -- BCrypt hash
    full_name  VARCHAR(200),
    email      VARCHAR(200),
    tel        VARCHAR(20),
    role       VARCHAR(20) DEFAULT 'ADMIN',
    status     TINYINT(1)  NOT NULL DEFAULT 1
);

-- Bảng danh mục
CREATE TABLE categories (
    id   BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

-- Bảng thuộc tính
CREATE TABLE attributes (
    id   BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

-- Bảng trung gian: danh mục – thuộc tính (M:N)
CREATE TABLE category_attributes (
    category_id  BIGINT NOT NULL,
    attribute_id BIGINT NOT NULL,
    PRIMARY KEY (category_id, attribute_id),
    FOREIGN KEY (category_id)  REFERENCES categories(id),
    FOREIGN KEY (attribute_id) REFERENCES attributes(id)
);

-- Bảng sản phẩm
CREATE TABLE products (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(255) NOT NULL,
    price          DECIMAL(19,2),
    stock_quantity INT DEFAULT 0,
    category_id    BIGINT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Bảng thuộc tính sản phẩm (trung gian có giá trị)
CREATE TABLE product_attributes (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id   BIGINT NOT NULL,
    attribute_id BIGINT NOT NULL,
    attr_value   VARCHAR(255),
    FOREIGN KEY (product_id)   REFERENCES products(id)   ON DELETE CASCADE,
    FOREIGN KEY (attribute_id) REFERENCES attributes(id)
);
```

### 5.2 Database: `feedback_db`

```sql
-- Bảng phản hồi chính
CREATE TABLE feedbacks (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id     BIGINT       NOT NULL,          -- logical ref, no FK
    product_name   VARCHAR(255) NOT NULL,
    user_id        BIGINT       NOT NULL,          -- FK to users (role='USER' only)
    comment        VARCHAR(1000),
    overall_rating INT          NOT NULL,           -- 1-5
    created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
    -- Note: Application-level validation: check user.role = 'USER' before inserting
);

-- Bảng đánh giá theo thuộc tính
CREATE TABLE attribute_ratings (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    feedback_id    BIGINT       NOT NULL,
    attribute_name VARCHAR(255) NOT NULL,
    rating         INT          NOT NULL,           -- 1-5
    comment        VARCHAR(500),
    FOREIGN KEY (feedback_id) REFERENCES feedbacks(id) ON DELETE CASCADE
);
```

---

## 6. THIẾT KẾ CHI TIẾT – MODULE QUẢN LÝ SẢN PHẨM

### 6.1 Thiết kế giao diện người dùng

**Trang đăng nhập (`/login` → `login.jsp`):**
```
┌──────────────────────────────────────────┐
│              📦                          │
│         Product Manager                  │
│   Hệ thống quản trị sản phẩm            │
│                                          │
│  Tên đăng nhập                           │
│  [____________________________________]  │
│  Mật khẩu                                │
│  [____________________________________]  │
│           [ Đăng nhập ]                  │
│      Demo: admin / admin123             │
└──────────────────────────────────────────┘
```

**Trang chủ Admin (`/` → `main.jsp`):**
```
┌─────────────────────────────────────────────────────────────────┐
│  📦 Product Manager            👤 Quan tri vien   [Đăng xuất]  │
├─────────────────────────────────────────────────────────────────┤
│              Chào mừng, Quan tri vien!                          │
│        Hệ thống quản lý sản phẩm và thống kê phản hồi          │
│                                                                 │
│  ┌────────────────────────┐   ┌────────────────────────┐       │
│  │  📦 Quản lý sản phẩm  │   │  ⭐ Thống kê phản hồi  │       │
│  │  Tìm kiếm, thêm mới,  │   │  Xem thống kê phản hồi │       │
│  │  xóa sản phẩm.        │   │  của khách hàng, chi   │       │
│  │                        │   │  tiết theo thuộc tính. │       │
│  │ [Quản lý sản phẩm]     │   │ [Xem thống kê]         │       │
│  └────────────────────────┘   └────────────────────────┘       │
└─────────────────────────────────────────────────────────────────┘
```

**Trang quản lý sản phẩm (`/products/add` → `add-product.jsp`):**
```
┌─────────────────────────────────────────────────────────────────┐
│  ← Trang chủ  📦 Quản lý sản phẩm   👤 Quan tri vien [Đăng xuất]│
├─────────────────────────────────────────────────────────────────┤
│  Danh sách sản phẩm                                             │
│  ┌────────────────────────────────────────────┬────────────────┐│
│  │ 🔍 [Tìm kiếm sản phẩm hoặc danh mục...  ] │[🔍 Tìm][+Thêm]││
│  └────────────────────────────────────────────┴────────────────┘│
│  ┌────┬─────────────────┬─────────────┬──────────┬─────────┬──┐ │
│  │ ID │ Tên sản phẩm    │ Giá         │ Tồn kho  │ DM │Tag│  │ │
│  ├────┼─────────────────┼─────────────┼──────────┼─────────┼──┤ │
│  │ #1 │ iPhone 15 Pro   │ 25.000.000₫ │    50    │[ĐT]│.. │[X]│
│  │ #2 │ Samsung S25     │ 22.000.000₫ │    30    │[ĐT]│.. │[X]│
│  └────┴─────────────────┴─────────────┴──────────┴─────────┴──┘ │
└─────────────────────────────────────────────────────────────────┘
```

*Khi nhấn + Thêm:* panel form xuất hiện phía trên bảng với các trường Tên, Giá, Số lượng tồn kho, Danh mục, Thuộc tính cố định (checkbox per attr) và Thuộc tính tùy chỉnh (+ thêm dòng).

### 6.2 Thiết kế biểu đồ lớp chi tiết

```
«interface»
JpaRepository<Product,Long>
        ▲
        │ implements
┌───────────────────────┐
│  ProductRepository    │
├───────────────────────┤
│ +findAllByOrderByIdDesc()│
└───────────────────────┘
           ▲
           │ uses
┌──────────────────────────────────────────────────────┐
│                     ProductService                   │
├──────────────────────────────────────────────────────┤
│ - productRepository : ProductRepository              │
│ - categoryRepository: CategoryRepository             │
│ - attributeRepository: AttributeRepository           │
├──────────────────────────────────────────────────────┤
│ +createProduct(req: ProductCreateRequest)            │
│   : ProductResponse                                  │
│ +getAllProducts() : List<ProductResponse>             │
│ +searchProducts(keyword: String): List<ProductResponse>│
│ +deleteProduct(id: Long) : void                      │
│ -toResponse(p: Product) : ProductResponse  «private»│
└──────────────────────────────────────────────────────┘
           ▲
           │ depends on
┌────────────────────────────┐
│    ProductController       │   «@RestController»
├────────────────────────────┤   «@RequestMapping /api/products»
│ - productService           │
├────────────────────────────┤
│ +getAllProducts(keyword?):  │  GET  /api/products[?keyword=]
│    List<..>                │
│ +createProduct(...):       │  POST /api/products
│    ResponseEntity<..>      │
│ +deleteProduct(id):        │  DELETE /api/products/{id}
│    ResponseEntity<Void>    │
└────────────────────────────┘

┌──────────────────────┐         ┌──────────────────────┐
│   AuthController     │         │  HandlerInterceptor  │
├──────────────────────┤         ├──────────────────────┤
│ +loginPage(): String │ GET /login│                    │
│ +doLogin(...):String │ POST /login│ AuthInterceptor   │
│ +logout(...): String │ GET /logout│ preHandle():      │
└──────────────────────┘         │  check session +    │
                                  │  redirect /login    │
«Entity»                          └──────────────────────┘
┌────────────────────┐
│       User         │  «@Entity» @Table(users)
├────────────────────┤
│ id: Long           │
│ username: String   │
│ password: String   │  ← BCrypt hash
│ fullName: String   │
│ role: String       │  ADMIN / USER
│ status: boolean    │
└────────────────────┘

«Entity»                          «Entity»
┌──────────────────┐              ┌──────────────────────┐
│     Product      │  1 ──── N   │   ProductAttribute   │
├──────────────────┤              ├──────────────────────┤
│ id: Long         │              │ id: Long             │
│ name: String     │              │ product: Product     │
│ price: BigDecimal│              │ attribute: Attribute  │
│ stockQuantity:   │              │ value: String        │
│   Integer        │              └──────────┬───────────┘
│ category:        │                         │ N ──── 1
│   Category       │                 «Entity»│
│ productAttributes│              ┌──────────┴───────┐
│   : List<..>     │              │    Attribute     │
└───────┬──────────┘              ├──────────────────┤
        │ N ──── 1                │ id: Long         │
        ▼                         │ name: String     │
«Entity»                          └──────────────────┘
┌────────────────┐
│    Category    │
├────────────────┤
│ id: Long       │
│ name: String   │
│ products: List │
│ attributes: List│
└────────────────┘
```

**Phân tích Pattern và Ưu điểm:**

| Pattern | Áp dụng | Ưu điểm |
|---------|---------|---------|
| **Session-based Auth** | `AuthController` + `AuthInterceptor` + `HttpSession` | Không cần Spring Security; đơn giản, kiểm soát hoàn toàn; BCrypt bảo vệ mật khẩu |
| **Repository Pattern** | `ProductRepository`, `CategoryRepository`, `AttributeRepository`, `UserRepository` extends `JpaRepository` | Tách biệt logic truy cập dữ liệu; dễ test (mock), dễ thay đổi ORM |
| **DTO (Data Transfer Object)** | `ProductCreateRequest`, `ProductResponse` | Entity nội bộ không bị lộ ra ngoài; validation tập trung; có thể thay đổi schema DB mà không ảnh hưởng API |
| **Service Layer** | `ProductService` | Tập trung business logic; Controller chỉ làm routing; dễ unit test |
| **Dependency Injection (Constructor)** | Tất cả class dùng constructor injection | Immutable dependencies; dễ test hơn field injection; rõ ràng dependencies |
| **find-or-create Pattern** | `attributeRepository.findByName(...).orElseGet(...)` | Cho phép người dùng thêm thuộc tính mới mà không cần form riêng; atomic, tránh duplicate |

### 6.3 Biểu đồ tuần tự – Thêm sản phẩm

```
Browser          API-Gateway     ProductController    ProductService     Repositories
   │                 │                  │                   │                 │
   │ GET /products/add│                 │                   │                 │
   │────────────────►│                 │                   │                 │
   │                 │ forward         │                   │                 │
   │                 │────────────────►│ return add-product.jsp             │
   │◄────────────────────────────────── (HTML page)        │                 │
   │                 │                  │                   │                 │
   │ GET /api/categories                │                   │                 │
   │────────────────►│                 │                   │                 │
   │                 │ forward ────────►│ getAllCategories() │                 │
   │                 │                  │                   │ findAll()       │
   │                 │                  │                   │────────────────►│
   │                 │                  │                   │◄────────────────│
   │◄── JSON [categories] ─────────────│                   │                 │
   │                 │                  │                   │                 │
   │ [user chọn danh mục]               │                   │                 │
   │ GET /api/categories/{id}/attributes│                   │                 │
   │────────────────►│────────────────►│ getAttrs(id)       │                 │
   │                 │                  │ findById(id)      │────────────────►│
   │                 │                  │◄──────────────────────── Category   │
   │◄── JSON [attributes] ─────────────│                   │                 │
   │                 │                  │                   │                 │
   │ [user điền form, nhấn submit]      │                   │                 │
   │ POST /api/products {body}          │                   │                 │
   │────────────────►│────────────────►│ createProduct(req)│                 │
   │                 │                  │──────────────────►│                 │
   │                 │                  │                   │ findById(catId) │
   │                 │                  │                   │────────────────►│
   │                 │                  │                   │◄── Category     │
   │                 │                  │                   │ findById(attrId)│
   │                 │                  │                   │────────────────►│
   │                 │                  │                   │ OR findByName() │
   │                 │                  │                   │────────────────►│
   │                 │                  │                   │ [auto-create?]  │
   │                 │                  │                   │ save(product)   │
   │                 │                  │                   │────────────────►│
   │                 │                  │                   │◄── saved Product│
   │                 │                  │◄── ProductResponse│                 │
   │◄─ 201 Created + JSON ─────────────│                   │                 │
   │ [UI updates product list]          │                   │                 │
```

---

## 7. THIẾT KẾ CHI TIẾT – MODULE PHẢN HỒI

### 7.1 Thiết kế giao diện người dùng

**Trang thống kê phản hồi (`/feedback/stats` → `feedback-stats.jsp`):**
```
┌─────────────────────────────────────────────────────────────┐
│  [LOGO] Phản hồi sản phẩm     [Trang chủ][Thêm phản hồi]  │
├────────────────────────────┬────────────────────────────────┤
│ GỬI PHẢN HỒI               │  THỐNG KÊ PHẢN HỒI           │
│ ─────────────────────────  │  ─────────────────────────   │
│ Sản phẩm:                  │  Chọn sản phẩm: [▼ iPhone]   │
│ [▼ iPhone 15          ]    │                               │
│                            │  Điểm TB tổng: ★★★★☆ 4.2    │
│ Người đánh giá:            │                               │
│ [___________________]      │  Theo thuộc tính:             │
│                            │  Thương hiệu  ████████░ 4.5  │
│ Điểm tổng: ★★★★☆           │  Màu sắc      ███████░░ 3.8  │
│ [1][2][3][4][5]            │  Chất lượng   █████████ 4.9  │
│                            │                               │
│ Nhận xét tổng:             │  ─── Danh sách phản hồi ─── │
│ [________________________] │  ┌─────────────────────────┐ │
│                            │  │ Nguyễn A - ★★★★☆       │ │
│ ĐÁNH GIÁ THEO THUỘC TÍNH: │  │ "Sản phẩm tốt"          │ │
│ Thương hiệu: ★★★★☆ [___]  │  │ Thương hiệu:4 Màu:5...  │ │
│ Màu sắc:     ★★★☆☆ [___]  │  └─────────────────────────┘ │
│ + ...                      │                               │
│ [  GỬI PHẢN HỒI  ]        │                               │
└────────────────────────────┴────────────────────────────────┘
```

### 7.2 Thiết kế biểu đồ lớp chi tiết

```
«interface»
JpaRepository<Feedback,Long>
        ▲
        │ implements
┌──────────────────────────────┐
│      FeedbackRepository      │
├──────────────────────────────┤
│ +findByProductId(id)         │
│ +findAllByOrderByIdDesc()    │
│ +findByProductIdOrderByIdDesc│
└──────────────────────────────┘
           ▲
           │ uses
┌───────────────────────────────────────────────────────┐
│                   FeedbackService                     │
├───────────────────────────────────────────────────────┤
│ - feedbackRepository: FeedbackRepository              │
├───────────────────────────────────────────────────────┤
│ +createFeedback(req: FeedbackCreateRequest)           │
│    : FeedbackResponse                                 │
│ +getAllFeedbacks() : List<FeedbackResponse>            │
│ +getFeedbacksByProduct(pid) : List<FeedbackResponse>  │
│ +getFeedbackById(id) : FeedbackResponse               │
│ +deleteFeedback(id) : void                            │
│ -toResponse(fb: Feedback) : FeedbackResponse «private»│
└───────────────────────────────────────────────────────┘
           ▲
           │ depends on
┌────────────────────────────────────┐
│       FeedbackController           │   «@RestController»
├────────────────────────────────────┤   «@RequestMapping /api/feedbacks»
│ +getAll()                          │  GET    /api/feedbacks
│ +getById(id)                       │  GET    /api/feedbacks/{id}
│ +getByProduct(productId)           │  GET    /api/feedbacks/product/{id}
│ +create(request)                   │  POST   /api/feedbacks
│ +delete(id)                        │  DELETE /api/feedbacks/{id}
└────────────────────────────────────┘

┌──────────────────────────────┐
│  FeedbackPageController      │   «@Controller»
├──────────────────────────────┤
│ +showFeedbackStatsPage()     │  GET /feedback/stats → "feedback-stats"
└──────────────────────────────┘

«Entity»                              «Entity»
┌─────────────────────────┐           ┌──────────────────────┐
│        Feedback         │  1 ──N    │   AttributeRating    │
├─────────────────────────┤           ├──────────────────────┤
│ id: Long                │           │ id: Long             │
│ productId: Long         │──────────►│ feedback: Feedback   │
│ productName: String     │           │ attributeName: String│
│ reviewer: String        │           │ rating: Integer(1-5) │
│ comment: String         │           │ comment: String      │
│ overallRating: Integer  │           └──────────────────────┘
│ createdAt: LocalDateTime│
│ attributeRatings: List  │
└─────────────────────────┘

DTO Layer:
┌───────────────────────────────────┐
│      FeedbackCreateRequest        │
├───────────────────────────────────┤
│ productId, productName, reviewer  │
│ comment, overallRating (1-5)      │
│ attributeRatings: List<           │
│   AttributeRatingEntry{           │
│     attributeName, rating,comment}│
│   >                               │
└───────────────────────────────────┘

┌───────────────────────────────────┐
│        FeedbackResponse           │
├───────────────────────────────────┤
│ id, productId, productName        │
│ reviewer, comment, overallRating  │
│ createdAt                         │
│ attributeRatings: List<           │
│   AttributeRatingDto{             │
│     attributeName, rating,comment}│
│   >                               │
└───────────────────────────────────┘
```

**Phân tích Pattern và Ưu điểm:**

| Pattern | Áp dụng | Ưu điểm |
|---------|---------|---------|
| **Cascade Persistence** | `Feedback` → `AttributeRating` với `CascadeType.ALL, orphanRemoval=true` | Lưu/xoá phản hồi tự động kéo theo tất cả đánh giá thuộc tính; không cần gọi repository `AttributeRating` thủ công |
| **Logical Reference (Bounded Context)** | `productId` là Long thuần tuý, không FK | Đúng nguyên tắc microservices: feedback-service hoàn toàn độc lập với product-service; không bị lỗi nếu product-service down |
| **De-normalization** | Lưu `productName` trực tiếp trong `Feedback` | Tránh gọi API cross-service khi đọc dữ liệu; tăng performance đọc |
| **Nested DTO** | `AttributeRatingDto` lồng trong `FeedbackResponse` | Trả về toàn bộ dữ liệu phản hồi trong 1 request, giảm round-trip |
| **Dual Controller** | `FeedbackController` (REST) + `FeedbackPageController` (MVC) | Tách biệt rõ ràng: controller JSON API vs controller trả view; single responsibility |

### 7.3 Biểu đồ tuần tự – Gửi phản hồi

```
Browser        API-Gateway    FeedbackController   FeedbackService   FeedbackRepository
   │                │                 │                  │                  │
   │ GET /feedback/stats              │                  │                  │
   │───────────────►│                 │                  │                  │
   │                │ forward ───────►│(FeedbackPageCtrl)│                  │
   │◄── feedback-stats.jsp (HTML) ───│                  │                  │
   │                │                 │                  │                  │
   │ GET /api/products (cross-call to product-service)   │                  │
   │───────────────►│── route to product-service :8081   │                  │
   │◄── JSON [product list] ─────────│                  │                  │
   │                │                 │                  │                  │
   │ [user chọn sản phẩm]             │                  │                  │
   │ GET /api/categories/{id}/attrs   │                  │                  │
   │───────────────►│── product-service │                │                  │
   │◄── JSON [attributes] ───────────│                  │                  │
   │                │                 │                  │                  │
   │ [user điền form đánh giá]        │                  │                  │
   │ POST /api/feedbacks {body}        │                  │                  │
   │───────────────►│────────────────►│ create(request)  │                  │
   │                │                 │─────────────────►│                  │
   │                │                 │                  │ [INTER-SERVICE]  │
   │                │                 │                  │ GET /api/products/{id}
   │                │                 │                  │──────────────────────► product-service :8081
   │                │                 │                  │◄── ProductDto {id, name}
   │                │                 │                  │ new Feedback()   │
   │                │                 │                  │ (productName từ  │
   │                │                 │                  │  product-service)│
   │                │                 │                  │ new List<        │
   │                │                 │                  │ AttributeRating> │
   │                │                 │                  │ save(feedback)   │
   │                │                 │                  │─────────────────►│
   │                │                 │                  │◄─── saved        │
   │                │                 │◄── FeedbackResponse                 │
   │◄─ 201 Created + JSON ───────────│                  │                  │
   │ [UI hiển thị thống kê mới]       │                  │                  │
   │                │                 │                  │                  │
   │ GET /api/feedbacks/product/{id}  │                  │                  │
   │───────────────►│────────────────►│ getByProduct(pid)│                  │
   │                │                 │─────────────────►│ findByProductId │
   │                │                 │                  │─────────────────►│
   │                │                 │                  │◄── List<Feedback>│
   │◄─ JSON [feedbacks] ─────────────│                  │                  │
   │ [tính avg, render biểu đồ]       │                  │                  │
```

---

## 8. THIẾT KẾ CHI TIẾT – API GATEWAY

### 8.1 Vai trò và cấu hình

API Gateway là điểm vào duy nhất của hệ thống, sử dụng **Spring Cloud Gateway** để định tuyến request.

**Bảng routing (`application.properties`):**

| Route ID | Path Predicate | Destination |
|----------|----------------|-------------|
| `product-service` | `/api/products/**`, `/api/categories/**` | `http://localhost:8081` |
| `product-pages` | `/`, `/products/**`, `/login`, `/logout` | `http://localhost:8081` |
| `feedback-service` | `/api/feedbacks/**` | `http://localhost:8082` |
| `feedback-pages` | `/feedback/**` | `http://localhost:8082` |

### 8.2 Biểu đồ lớp – Gateway

```
「application.properties」
  spring.cloud.gateway.routes[0..3]
           │
           ▼
┌──────────────────────────────────────────┐
│         Spring Cloud Gateway             │
│  (RouteLocator auto-configured từ props) │
├──────────────────────────────────────────┤
│ Route[0]: /api/products/**  → :8081      │
│ Route[1]: /products/**      → :8081      │
│ Route[2]: /api/feedbacks/** → :8082      │
│ Route[3]: /feedback/**      → :8082      │
└──────────────────────────────────────────┘
```

### 8.3 Triển khai – Docker Compose

Hệ thống được đóng gói Docker và chạy local bằng **Docker Compose**:

```
docker-compose.yml
│
├── mysql-product   (MySQL 8.0, port 3307, DB: product_db)
├── mysql-feedback  (MySQL 8.0, port 3308, DB: feedback_db)
├── product-service (Spring Boot WAR, port 8081)
├── feedback-service(Spring Boot WAR, port 8082)
└── api-gateway     (Spring Cloud Gateway, port 8080)
```

**Lệnh chạy toàn hệ thống:**
```bash
# Build và khởi động tất cả services
docker-compose up --build -d

# Xem log của một service
docker-compose logs -f feedback-service

# Dừng hệ thống
docker-compose down
```

**Truy cập:**  
- Trang chính (product-service): `http://localhost:8080/`  
- Trang phản hồi (feedback-service): `http://localhost:8080/feedback/stats`  
- API products: `http://localhost:8080/api/products`  
- API feedbacks: `http://localhost:8080/api/feedbacks`

---

## PHỤ LỤC – TÓM TẮT CÔNG NGHỆ SỬ DỤNG

| Thành phần | Công nghệ |
|------------|-----------|
| Backend framework | Spring Boot 3.x |
| Gateway | Spring Cloud Gateway |
| ORM | Spring Data JPA + Hibernate |
| Database | MySQL 8.0 |
| View (JSP) | Jakarta EE JSP + JSTL |
| Authentication | Session-based (HttpSession) + BCryptPasswordEncoder |
| Build tool | Maven (multi-module) |
| Containerization | Docker |
| Run environment | Docker Compose |
| Logging | SLF4J + Logback (file + console) |

---

*Báo cáo được tạo cho hệ thống Demo Microservices – Product & Feedback Management*
