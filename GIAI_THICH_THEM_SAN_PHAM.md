# GIẢI THÍCH CHỨC NĂNG: THÊM SẢN PHẨM

---

## TỔNG QUAN: Dữ liệu đi từ đâu đến đâu?

```
Người dùng điền form (products.html)
        ↓
JavaScript đóng gói JSON và gửi lên (products.js)
        ↓
API Gateway nhận và chuyển tiếp (port 8080)
        ↓
ProductController nhận request (product-service, port 8081)
        ↓
ProductService xử lý logic nghiệp vụ
        ↓
Lưu vào database (product_db)
        ↓
Trả kết quả về → JS hiển thị thông báo thành công
```

---

## BƯỚC 1 — Người dùng mở form

**File:** `frontend/html/products.html` (dòng 119)
**File:** `frontend/html/js/products.js` (dòng 95–121)

Khi nhấn nút **"+ Thêm mới"**, JS chạy hàm `openAddForm()`:

```javascript
function openAddForm() {
  document.getElementById('addPanel').classList.add('open'); // hiện form ra
  loadCategories();       // gọi API lấy danh sách danh mục
  window.scrollTo(...);   // cuộn lên đầu trang
}
```

Hàm `loadCategories()` gọi `GET /api/categories` để lấy danh sách danh mục (Điện thoại, Laptop, ...) rồi đổ vào dropdown.

---

## BƯỚC 2 — Người dùng chọn danh mục

**File:** `frontend/html/products.html` (dòng 141)
**File:** `frontend/html/js/products.js` (dòng 123–140)

Khi người dùng chọn danh mục, dropdown có `onchange="loadFixedAttrs(this.value)"`.

Hàm `loadFixedAttrs(categoryId)` gọi `GET /api/categories/{id}/attributes` để lấy **các thuộc tính cố định** của danh mục đó (ví dụ: Điện thoại có thuộc tính "Màu sắc", "RAM", "Dung lượng").

Kết quả hiển thị thành các ô checkbox + input. Người dùng **tick vào thuộc tính nào** thì mới nhập giá trị cho thuộc tính đó.

---

## BƯỚC 3 — Người dùng thêm thuộc tính tùy chỉnh (không bắt buộc)

**File:** `frontend/html/js/products.js` (dòng 149–157)

Nhấn **"+ Thêm thuộc tính"** → hàm `addExtraRow()` tạo thêm 1 hàng gồm 2 ô:
- Ô 1: Tên thuộc tính (ví dụ: "Xuất xứ")
- Ô 2: Giá trị (ví dụ: "Việt Nam")

Đây là thuộc tính **người dùng tự đặt**, không bị ràng buộc bởi danh mục.

---

## BƯỚC 4 — Người dùng nhấn "Lưu sản phẩm"

**File:** `frontend/html/js/products.js` (dòng 159–192)

Hàm `saveProduct()` chạy theo 3 giai đoạn:

### Giai đoạn 4a: Kiểm tra hợp lệ (Validation)

```javascript
if (!name)                     → báo lỗi "Vui lòng nhập tên sản phẩm"
if (isNaN(price) || price < 0) → báo lỗi "Vui lòng nhập giá hợp lệ"
if (!categoryId)               → báo lỗi "Vui lòng chọn danh mục"
```

Nếu thiếu bất kỳ thứ gì → dừng lại, hiển thị lỗi đỏ, KHÔNG gửi lên server.

### Giai đoạn 4b: Thu thập dữ liệu từ form

```javascript
// Thu thập thuộc tính CỐ ĐỊNH (những cái đã tick checkbox)
const fixedAttributes = [];
document.querySelectorAll('.fixed-attr-cb:checked').forEach(cb => {
  fixedAttributes.push({
    attributeId: cb.dataset.id,  // ID thuộc tính
    value: input.value           // Giá trị người dùng nhập
  });
});

// Thu thập thuộc tính TÙY CHỈNH
const extraAttributes = [];
document.querySelectorAll('.extra-row').forEach(row => {
  extraAttributes.push({ name: "Xuất xứ", value: "Việt Nam" });
});
```

### Giai đoạn 4c: Gửi HTTP POST lên server

```javascript
// Dữ liệu JSON gửi đi trông như thế này:
{
  "name": "iPhone 15 Pro",
  "price": 25000000,
  "stockQuantity": 100,
  "categoryId": 1,
  "fixedAttributes": [
    { "attributeId": 3, "value": "Xanh titan" },
    { "attributeId": 4, "value": "8GB" }
  ],
  "extraAttributes": [
    { "name": "Xuất xứ", "value": "Mỹ" }
  ]
}
```

Gửi đến: `POST /api/products`

---

## BƯỚC 5 — API Gateway chuyển tiếp

**File:** `api-gateway/src/main/resources/application.properties`

API Gateway (chạy ở cổng 8080) nhận request và tự động chuyển tiếp:

```
POST /api/products → product-service (cổng 8081)
```

Frontend không cần biết product-service chạy ở đâu. Mọi thứ đều đi qua cổng 8080.

---

## BƯỚC 6 — ProductController nhận request

**File:** `product-service/src/main/java/com/example/product/controller/ProductController.java` (dòng 53–58)

```java
@PostMapping                    // Lắng nghe POST /api/products
public ResponseEntity<Product> createProduct(@RequestBody Map<String, Object> request) {
    log.info("[ADMIN] POST /api/products name='{}'", request.get("name"));
    Product created = productService.createProduct(request); // chuyển xuống Service
    return ResponseEntity.status(HttpStatus.CREATED).body(created); // trả về 201 + dữ liệu
}
```

Controller không xử lý logic, chỉ là **người gác cửa**: nhận request → chuyển cho Service → trả kết quả về.

---

## BƯỚC 7 — ProductService xử lý logic chính

**File:** `product-service/src/main/java/com/example/product/service/ProductService.java` (dòng 40–92)

Đây là trái tim của chức năng. Có annotation `@Transactional` nghĩa là: **nếu bước nào lỗi thì hủy toàn bộ, không lưu nửa vời**.

### 7a: Kiểm tra lại lần nữa ở server

```java
if (name == null || name.isBlank()) throw new IllegalArgumentException("Tên sản phẩm không được trống");
if (price == null)                  throw new IllegalArgumentException("Giá không được trống");
if (categoryId == null)             throw new IllegalArgumentException("Danh mục không được trống");
```

### 7b: Tìm danh mục trong database

```java
Category category = categoryRepository.findById(categoryId)
    .orElseThrow(() -> new IllegalArgumentException("Category không tồn tại"));
```

Nếu `categoryId` không tồn tại trong DB → ném lỗi, dừng ngay.

### 7c: Tạo đối tượng Product

```java
Product product = new Product();
product.setName("iPhone 15 Pro");
product.setPrice(25000000);
product.setStockQuantity(100);
product.setCategory(category);
```

Lúc này Product chưa được lưu vào DB, mới chỉ tồn tại trong bộ nhớ.

### 7d: Xử lý thuộc tính CỐ ĐỊNH (fixedAttributes)

```java
for (Map<String, Object> entry : fixedAttrs) {
    Long attrId = entry.get("attributeId");
    String value = entry.get("value");
    
    // Tìm Attribute trong DB theo ID
    Attribute attr = attributeRepository.findById(attrId).orElseThrow(...);
    
    // Tạo ProductAttribute nối Product ↔ Attribute kèm giá trị
    productAttributes.add(new ProductAttribute(product, attr, value));
}
```

`ProductAttribute` là bảng trung gian: biết sản phẩm nào có thuộc tính nào với giá trị gì.

### 7e: Xử lý thuộc tính TÙY CHỈNH (extraAttributes)

```java
for (Map<String, Object> entry : extraAttrs) {
    String attrName = entry.get("name");   // "Xuất xứ"
    String value = entry.get("value");     // "Mỹ"
    
    // Tìm trong DB xem thuộc tính tên này đã tồn tại chưa
    // Nếu chưa → tạo mới, nếu rồi → dùng cái cũ
    Attribute attr = attributeRepository.findByName(attrName)
        .orElseGet(() -> attributeRepository.save(new Attribute(attrName)));
    
    productAttributes.add(new ProductAttribute(product, attr, value));
}
```

**Điểm thông minh:** Nếu bạn đã có thuộc tính "Xuất xứ" từ sản phẩm trước thì tái sử dụng, không tạo trùng.

### 7f: Lưu vào database

```java
product.setProductAttributes(productAttributes); // gắn danh sách thuộc tính vào product
Product saved = productRepository.save(product); // lưu 1 lần → Spring tự lưu luôn cả thuộc tính
```

Vì Product có cấu hình `CascadeType.ALL`, Spring tự động lưu `ProductAttribute` khi lưu `Product`. Không cần gọi save riêng cho từng thuộc tính.

---

## BƯỚC 8 — Dữ liệu trong Database

Sau khi lưu, database có dữ liệu như sau:

**Bảng `products`:**
| id | name | price | stock_quantity | category_id |
|----|------|-------|----------------|-------------|
| 5  | iPhone 15 Pro | 25000000 | 100 | 1 |

**Bảng `attributes`:**
| id | name |
|----|------|
| 3  | Màu sắc |
| 4  | RAM |
| 7  | Xuất xứ ← mới tạo |

**Bảng `product_attributes`:**
| id | product_id | attribute_id | value |
|----|------------|--------------|-------|
| 10 | 5 | 3 | Xanh titan |
| 11 | 5 | 4 | 8GB |
| 12 | 5 | 7 | Mỹ |

---

## BƯỚC 9 — Trả kết quả về Frontend

Server trả về HTTP 201 (Created) kèm thông tin product vừa tạo (JSON).

JS nhận được:
```javascript
.then(() => {
    showToast('Thêm sản phẩm thành công!', 'ok'); // thông báo xanh góc phải
    closeAddForm();          // đóng form
    loadProducts(...);       // tải lại danh sách → sản phẩm mới xuất hiện trong bảng
})
.catch(e => showFormErr('Lỗi: ' + e.message)); // nếu lỗi → hiện thông báo đỏ
```

---

## SƠ ĐỒ CÁC FILE LIÊN QUAN

```
Người dùng
    │
    ▼
products.html          ← Giao diện: form HTML
    │
    ▼
js/products.js         ← Logic JS: validation, thu thập data, gọi API
    │  POST /api/products (JSON)
    ▼
api-gateway            ← Cổng 8080: chuyển tiếp request
    │
    ▼
ProductController.java ← Nhận request, chuyển cho Service
    │
    ▼
ProductService.java    ← Logic nghiệp vụ: validate, tạo entity, lưu DB
    │
    ├── CategoryRepository.java    ← Tìm danh mục theo ID
    ├── AttributeRepository.java   ← Tìm/tạo thuộc tính theo tên
    └── ProductRepository.java     ← Lưu sản phẩm + thuộc tính
            │
            ▼
        Database (product_db)
        - Bảng products
        - Bảng attributes
        - Bảng product_attributes
```

---

## TÓM TẮT BẰNG LỜI BÌNH DÂN

1. Bạn điền form → JS kiểm tra xem có thiếu không
2. JS đóng gói hết thành 1 gói JSON rồi gắn nhãn "Gửi đến /api/products"
3. Gateway nhận gói, xem nhãn, chuyển sang Product Service
4. Controller nhận gói, đưa cho Service
5. Service mở gói ra: kiểm tra lại, tìm danh mục, tạo sản phẩm, xử lý từng thuộc tính, lưu tất cả vào DB trong 1 transaction
6. Nếu bước nào lỗi → hủy hết, báo lỗi về
7. Nếu thành công → trả dữ liệu về → JS hiện thông báo, load lại bảng
