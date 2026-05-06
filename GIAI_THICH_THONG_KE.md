# GIẢI THÍCH CHỨC NĂNG: THỐNG KÊ PHẢN HỒI

---

## TỔNG QUAN: Dữ liệu đi từ đâu đến đâu?

```
Người dùng chọn ngày → nhấn "Thống kê" (feedback-stats.html)
        ↓
JS gọi API lấy feedbacks trong khoảng thời gian (feedback-stats.js)
        ↓
API Gateway chuyển tiếp (port 8080)
        ↓
FeedbackController nhận request (feedback-service, port 8083)
        ↓
FeedbackService truy vấn DB + gọi sang service khác để lấy tên
        ↓  (gọi sang product-service lấy tên thuộc tính)
        ↓  (gọi sang user-service lấy tên khách hàng)
        ↓
Trả danh sách feedback đầy đủ thông tin về JS
        ↓
JS tính toán thống kê và hiển thị theo 3 tầng
```

---

## KIẾN TRÚC 3 TẦNG (3 Layer)

Trang thống kê không hiển thị tất cả cùng lúc. Nó có **3 tầng**, người dùng nhấn vào mới đi sâu hơn:

```
TẦNG 1: Danh sách sản phẩm + điểm TB (sau khi chọn ngày)
    → Nhấn vào 1 sản phẩm
TẦNG 2: Danh sách tất cả feedback của sản phẩm đó
    → Nhấn vào 1 feedback
TẦNG 3: Chi tiết đầy đủ: điểm từng thuộc tính, nhận xét
```

Điểm quan trọng: **JS chỉ gọi API 1 lần duy nhất** khi nhấn "Thống kê". Tầng 2 và tầng 3 chỉ lọc/hiển thị từ dữ liệu đã có trong bộ nhớ, không gọi thêm API.

---

## BƯỚC 1 — Khởi tạo trang

**File:** `frontend/html/js/feedback-stats.js` (dòng 8–18)

Khi trang vừa mở, JS chạy hàm `init()` tự động:

```javascript
(function init() {
  // Tự điền ngày mặc định: từ đầu tháng đến hôm nay
  document.getElementById('toDate').value   = fmt(today);       // hôm nay
  document.getElementById('fromDate').value = fmt(firstOfMonth); // đầu tháng

  // Tải sẵn danh sách sản phẩm để có tên hiển thị sau này
  fetch('/api/products?page=0&size=500')
    .then(r => r.json())
    .then(d => { allProducts = d.content || []; });
})();
```

Tại sao phải tải sản phẩm trước? Vì feedback chỉ lưu `productId` (số), không lưu tên. JS cần danh sách sản phẩm để tra tên.

---

## BƯỚC 2 — Người dùng nhấn "Thống kê"

**File:** `frontend/html/js/feedback-stats.js` (dòng 51–74)

Hàm `doSearch()` chạy:

```javascript
function doSearch() {
  const from = '2025-01-01';  // ngày bắt đầu
  const to   = '2025-12-31';  // ngày kết thúc

  // Kiểm tra cơ bản
  if (!from || !to)  → báo lỗi
  if (from > to)     → báo lỗi "Ngày bắt đầu phải trước ngày kết thúc"

  // Gọi API
  fetch(`/api/feedbacks/range?from=2025-01-01&to=2025-12-31`)
    .then(r => r.json())
    .then(feedbacks => {
      allFeedbacks = feedbacks; // lưu vào bộ nhớ để dùng cho tầng 2, 3
      renderLayer1(feedbacks, ...);  // hiển thị tầng 1
    });
}
```

---

## BƯỚC 3 — Request đi qua API Gateway → FeedbackController

**File:** `feedback-service/.../controller/FeedbackController.java` (dòng 41–48)

```java
@GetMapping("/range")
public List<Feedback> getByDateRange(
        @RequestParam String from,       // "2025-01-01"
        @RequestParam String to,         // "2025-12-31"
        @RequestParam(required = false) Long productId) {  // không bắt buộc
    return feedbackService.getFeedbacksByDateRange(from, to, productId);
}
```

---

## BƯỚC 4 — FeedbackService xử lý

**File:** `feedback-service/.../service/FeedbackService.java` (dòng 44–84)

### 4a: Chuyển đổi ngày và truy vấn DB

```java
public List<Feedback> getFeedbacksByDateRange(String fromDate, String toDate, Long productId) {
    // Chuyển "2025-01-01" → 2025-01-01T00:00:00 (đầu ngày)
    LocalDateTime from = LocalDate.parse(fromDate).atStartOfDay();
    // Chuyển "2025-12-31" → 2025-12-31T23:59:59 (cuối ngày)
    LocalDateTime to   = LocalDate.parse(toDate).atTime(LocalTime.MAX);

    // Truy vấn DB
    List<Feedback> list = (productId != null)
        ? feedbackRepository.findByProductIdAndDateRange(productId, from, to)
        : feedbackRepository.findByDateRange(from, to);  // lấy tất cả nếu không có productId

    return enrich(list); // bổ sung tên khách hàng và tên thuộc tính
}
```

### 4b: Gọi sang service khác để lấy tên (hàm enrich)

```java
private List<Feedback> enrich(List<Feedback> list) {
    Map<Long, String> customerCache  = new HashMap<>();  // cache để không gọi trùng
    Map<Long, String> attributeCache = new HashMap<>();

    for (Feedback fb : list) {

        // Lấy tên khách hàng từ user-service
        String customerName = customerCache.computeIfAbsent(fb.getCustomerId(), id -> {
            CustomerDto c = userServiceClient.getCustomer(id); // gọi sang user-service
            return c.getFullName();
        });
        fb.setCustomerName(customerName); // gắn vào, không lưu DB (field @Transient)

        // Lấy tên thuộc tính từ product-service
        for (AttributeRating ar : fb.getAttributeRatings()) {
            String attrName = attributeCache.computeIfAbsent(ar.getAttributeId(), id -> {
                AttributeDto a = productServiceClient.getAttribute(id); // gọi sang product-service
                return a.getName();
            });
            ar.setAttributeName(attrName); // gắn vào, không lưu DB
        }
    }
    return list;
}
```

**Tại sao cần cache?** Nếu có 100 feedback của cùng 1 khách hàng, không cache sẽ gọi user-service 100 lần. Với cache, chỉ gọi 1 lần, 99 lần còn lại lấy từ bộ nhớ.

**`@Transient` là gì?** Là annotation nói với JPA: "field này KHÔNG lưu vào database". `customerName` và `attributeName` chỉ tồn tại trong lúc trả về API, không bao giờ lưu xuống DB. Mỗi lần cần thì gọi sang service khác để lấy lại.

### 4c: Cấu trúc dữ liệu DB cần biết

**Bảng `feedbacks`** (feedback_db):
| id | productId | customerId | comment | overallRating | createdAt |
|----|-----------|------------|---------|---------------|-----------|
| 1  | 5 | 12 | "Tốt lắm" | 4 | 2025-03-15 |

Lưu ý: `productId` và `customerId` là số nguyên thô. Không có khóa ngoại sang DB khác (vì microservice mỗi cái có DB riêng).

**Bảng `attribute_ratings`**:
| id | feedback_id | attributeId | rating | comment |
|----|-------------|-------------|--------|---------|
| 1  | 1 | 3 | 5 | "Màu đẹp" |
| 2  | 1 | 4 | 4 | "RAM ổn" |

---

## BƯỚC 5 — Dữ liệu trả về JS có dạng như này

```json
[
  {
    "id": 1,
    "productId": 5,
    "customerId": 12,
    "customerName": "Nguyễn Văn A",  ← được enrich từ user-service
    "comment": "Tốt lắm",
    "overallRating": 4,
    "createdAt": "2025-03-15T10:30:00",
    "attributeRatings": [
      {
        "attributeId": 3,
        "attributeName": "Màu sắc",  ← được enrich từ product-service
        "rating": 5,
        "comment": "Màu đẹp"
      }
    ]
  }
]
```

---

## BƯỚC 6 — JS hiển thị TẦNG 1

**File:** `frontend/html/js/feedback-stats.js` (dòng 87–168)

Hàm `renderLayer1(feedbacks, ...)`:

```javascript
// Bước 1: Gom feedback theo sản phẩm
const map = {};
feedbacks.forEach(f => {
  if (!map[f.productId]) map[f.productId] = { productId: f.productId, feedbacks: [] };
  map[f.productId].feedbacks.push(f);
});
// Kết quả: map = { 5: { feedbacks: [fb1, fb5, fb9] }, 3: { feedbacks: [fb2, fb7] } }

// Bước 2: Tính điểm trung bình cho từng sản phẩm
let rows = Object.values(map).map(g => {
  const total = g.feedbacks.length;
  const avg   = g.feedbacks.reduce((s, f) => s + f.overallRating, 0) / total;
  const name  = getProductName(g.productId); // tra tên từ allProducts đã load sẵn
  return { productId, name, total, avg };
});

// Bước 3: Sắp xếp theo số phản hồi nhiều nhất
rows.sort((a, b) => b.total - a.total);

// Bước 4: Hiển thị bảng + 3 ô thống kê tổng
```

Hiển thị:
- Ô "Tổng phản hồi": tổng số feedback
- Ô "Điểm TB toàn hệ thống": trung bình tất cả
- Ô "Sản phẩm được đánh giá": số sản phẩm có feedback
- Bảng sản phẩm: tên, điểm TB, số sao, số feedback

---

## BƯỚC 7 — Người dùng nhấn vào 1 sản phẩm → TẦNG 2

**File:** `frontend/html/js/feedback-stats.js` (dòng 171–208)

```javascript
function openProduct(productId, productName) {
  currentProduct = { id: productId, name: productName };

  // LỌC từ allFeedbacks đã có sẵn trong bộ nhớ — KHÔNG gọi thêm API!
  const list = allFeedbacks
    .filter(f => f.productId === productId)     // chỉ lấy feedback của sp này
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)); // mới nhất trước

  renderLayer2(list);
  goLayer(2); // chuyển sang hiển thị tầng 2
}
```

Hiển thị: danh sách thẻ (card) mỗi thẻ có tên khách hàng, số sao, nhận xét ngắn.

---

## BƯỚC 8 — Người dùng nhấn vào 1 feedback → TẦNG 3

**File:** `frontend/html/js/feedback-stats.js` (dòng 211–267)

```javascript
function openFeedback(feedbackId) {
  // Tìm trong allFeedbacks — KHÔNG gọi thêm API!
  const f = allFeedbacks.find(x => x.id === feedbackId);

  // Render bảng đánh giá chi tiết từng thuộc tính
  const attrRows = f.attributeRatings.map(ar => `
    <tr>
      <td>${ar.attributeName}</td>  ← tên thuộc tính đã được enrich sẵn
      <td>${ar.rating}/5</td>
      <td>${ar.comment}</td>
    </tr>
  `);

  goLayer(3); // chuyển sang hiển thị tầng 3
}
```

---

## BƯỚC 9 — Điều hướng giữa các tầng

**File:** `frontend/html/js/feedback-stats.js` (dòng 23–48)

```javascript
function goLayer(n) {
  // Ẩn tất cả các tầng, chỉ hiện tầng n
  document.querySelectorAll('.layer').forEach((el, i) => {
    el.classList.toggle('active', i + 1 === n);
  });
  updateBreadcrumb(n); // cập nhật breadcrumb: Thống kê › iPhone 15 Pro › Chi tiết
}
```

Breadcrumb (đường dẫn ở trên) cũng là nút: nhấn "Thống kê" quay về tầng 1, nhấn tên sản phẩm quay về tầng 2.

---

## SƠ ĐỒ CÁC FILE LIÊN QUAN

```
Người dùng
    │
    ▼
feedback-stats.html     ← Giao diện: 3 div layer, form chọn ngày
    │
    ▼
js/feedback-stats.js    ← Logic JS: gọi API, tính toán, render 3 tầng
    │  GET /api/feedbacks/range?from=...&to=...
    ▼
api-gateway             ← Cổng 8080: chuyển tiếp request
    │
    ▼
FeedbackController.java ← Nhận request, chuyển cho Service
    │
    ▼
FeedbackService.java    ← Truy vấn DB + gọi sang service khác
    │
    ├── FeedbackRepository.java      ← Truy vấn feedback theo khoảng ngày
    │       └── feedback_db (bảng feedbacks, attribute_ratings)
    │
    ├── UserServiceClient.java       ← Gọi user-service lấy tên khách hàng
    │       └── user-service (cổng 8082) → user_db
    │
    └── ProductServiceClient.java    ← Gọi product-service lấy tên thuộc tính
            └── product-service (cổng 8081) → product_db
```

---

## TÓM TẮT BẰNG LỜI BÌNH DÂN

1. Trang mở lên: JS tự tải sẵn danh sách sản phẩm và điền ngày mặc định
2. Bạn chọn khoảng ngày → nhấn "Thống kê"
3. JS gọi API 1 lần duy nhất, lấy TẤT CẢ feedback trong khoảng đó
4. Server truy vấn DB, rồi gọi sang 2 service khác để bổ sung tên khách hàng và tên thuộc tính
5. Toàn bộ dữ liệu trả về được lưu vào biến `allFeedbacks` trong bộ nhớ trình duyệt
6. **Tầng 1**: JS tự tính toán (gom nhóm, tính trung bình) từ `allFeedbacks` → hiện bảng sản phẩm
7. **Tầng 2**: Nhấn sản phẩm → JS lọc `allFeedbacks` theo productId → hiện danh sách feedback (không gọi API)
8. **Tầng 3**: Nhấn feedback → JS tìm trong `allFeedbacks` theo id → hiện chi tiết (không gọi API)

**Tại sao thiết kế vậy?** Gọi API ít lần nhất có thể → trang chạy nhanh, không bị giật khi chuyển tầng.
