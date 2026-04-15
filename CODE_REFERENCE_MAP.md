# Code Reference Map - Feedback Service

Quick reference for all key files and lines related to the feedback data flow.

## 📁 File Locations & Key Lines

### Backend - Core Services

| File | Path | Key Lines | Purpose |
|------|------|-----------|---------|
| **FeedbackController** | `feedback-service/src/main/java/com/example/feedback/controller/FeedbackController.java` | L22-66 | API endpoints:<br/>GET /api/feedbacks<br/>GET /api/feedbacks/{id}<br/>GET /api/feedbacks/product/{productId}<br/>POST/DELETE operations |
| **FeedbackService** | `feedback-service/src/main/java/com/example/feedback/service/FeedbackService.java` | L25-160 | **Key method:** `toResponse()` at L108<br/>**Issue:** No attribute name lookup<br/>Calls userServiceClient + productServiceClient |
| **FeedbackResponse DTO** | `feedback-service/src/main/java/com/example/feedback/dto/FeedbackResponse.java` | L1-67 | **Issue:** Has `customerName` not `reviewer`<br/>**Issue:** AttributeRatingDto missing `attributeName`<br/>Nested class at L49-67 |
| **Feedback Entity** | `feedback-service/src/main/java/com/example/feedback/entity/Feedback.java` | L15-65 | OneToMany relationship to AttributeRating<br/>**Issue:** Only stores IDs, not names |
| **AttributeRating Entity** | `feedback-service/src/main/java/com/example/feedback/entity/AttributeRating.java` | L1-60 | Stores: attributeId (not name), rating, comment<br>**Issue:** attributeId is just a reference |
| **FeedbackRepository** | `feedback-service/src/main/java/com/example/feedback/repository/FeedbackRepository.java` | L1-12 | Simple queries with no custom @Query<br/>**Issue:** No JOIN operations |
| **UserServiceClient** | `feedback-service/src/main/java/com/example/feedback/client/UserServiceClient.java` | L1-32 | Calls user-service to get customer details<br/>Returns: CustomerDto with fullName |
| **ProductServiceClient** | `feedback-service/src/main/java/com/example/feedback/client/ProductServiceClient.java` | L1-65 | Calls product-service to get product details<br/>Returns: ProductDto with name<br/>**Issue:** No method for attribute names |

### Backend - DTOs & Models

| File | Path | Key Lines | Issue |
|------|------|-----------|-------|
| **CustomerDto** | `feedback-service/src/main/java/com/example/feedback/dto/CustomerDto.java` | L1-37 | Has: id, username, fullName, email<br/>fullName is what backend sends for reviewer |
| **ProductDto** | `feedback-service/src/main/java/com/example/feedback/dto/ProductDto.java` | L1-25 | Has: id, name<br/>**Missing:** attributes array or method |
| **FeedbackCreateRequest** | `feedback-service/src/main/java/com/example/feedback/dto/FeedbackCreateRequest.java` | L1-? | Input DTO for creating feedback<br/>Contains AttributeRatingEntry inner class |

### Frontend - JSP & JavaScript

| File | Path | Lines | Issue |
|------|------|-------|-------|
| **feedback-stats.jsp** | `feedback-service/src/main/webapp/WEB-INF/jsp/feedback-stats.jsp` | L850-850 | Config section:<br/>PRODUCT_API, FEEDBACK_API setup<br/>**Note:** Can use port 8083 directly or via gateway |
| **feedback-stats.jsp** | (same) | L900-950 | `renderProductsView()` function<br/>✅ Correctly uses f.productName |
| **feedback-stats.jsp** | (same) | L1030-1035 | **ISSUE LINE 1:** `f.reviewer` undefined<br/>```javascript<br/>html += '<div class="avatar">' + esc(avatarInitial(f.reviewer)) + '</div>';<br/>html += '<div class="rc-reviewer">' + esc(f.reviewer) + '</div>';<br/>```<br/>Should use: `f.customerName` or backend should send `reviewer` |
| **feedback-stats.jsp** | (same) | L1180-1220 | `renderDetailView()` function<br/>Calls `/api/feedbacks/{id}` |
| **feedback-stats.jsp** | (same) | L1200-1220 | **ISSUE LINE 2:** `ar.attributeName` undefined<br/>```javascript<br/>f.attributeRatings.forEach(function(ar) {<br/>  html += '<td><b>' + esc(ar.attributeName) + '</b></td>';<br/>```<br/>Backend sends only `ar.attributeId` |
| **feedback-stats.jsp** | (same) | L750-800 | Styling for avatar, review cards, attribute table |

## 🔍 Data Flow Trace

### Request Path: GET /api/feedbacks/1

```
1. Frontend JS: fetchJson(FEEDBACK_API + '/' + 1)
   ↓
2. FeedbackController.getById(1)
   ↓
3. FeedbackService.getFeedbackById(1)
   ├─ feedbackRepository.findById(1)
   │  └─ Database: SELECT * FROM feedbacks WHERE id=1
   │     Returns: Feedback { id:1, productId:101, customerId:5, ... }
   │
   ├─ userServiceClient.getCustomer(5)
   │  └─ HTTP GET http://user-service:8082/api/customers/5
   │     Returns: CustomerDto { id:5, fullName:"Nguyen Van A", email:"..." }
   │
   ├─ productServiceClient.getProduct(101)  
   │  └─ HTTP GET http://product-service:8081/api/products/101
   │     Returns: ProductDto { id:101, name:"Samsung Phone" }
   │
   └─ toResponse(feedback, customerDto, productDto)
      ├─ Sets: customerName ← customerDto.fullName ✅
      ├─ Sets: productName ← productDto.name ✅
      ├─ Maps: attributeRatings[].attributeId (but NOT attributeName) ❌
      └─ Returns: FeedbackResponse { ... }
   ↓
4. Spring converts to JSON:
{
  "id": 1,
  "productId": 101,
  "productName": "Samsung Phone",     ✅ correct
  "customerId": 5,
  "customerName": "Nguyen Van A",    ✅ correct
  "attributeRatings": [
    { "attributeId": 1, "rating": 5, "comment": "..." }  ❌ missing attributeName
  ]
}
   ↓
5. Frontend receives JSON
   ↓
6. renderDetailView() processes:
   html += f.reviewer ← UNDEFINED (expects this but gets f.customername)
   html += ar.attributeName ← UNDEFINED (expects this but gets ar.attributeId)
```

## 📊 Quick Fix Checklist

### Fix 1: Reviewer Name
- [ ] Open: `FeedbackResponse.java`
- [ ] ***Line 11*: Add field: `private String reviewer;`
- [ ] **OR** Rename: `customerName` → `reviewer` at Line 11
- [ ] Open: `FeedbackService.java`
- [ ] **Line 126**: Change `res.setCustomerName(...)` to `res.setReviewer(...)`
- [ ] Test: Verify `f.reviewer` now defined in JSON

### Fix 2: Attribute Names
- [ ] Open: `ProductServiceClient.java`
- [ ] **Add method:**
  ```java
  public AttributeDto getAttribute(Long attributeId) {
      String url = productServiceUrl + "/api/attributes/" + attributeId;
      return restTemplate.getForObject(url, AttributeDto.class);
  }
  ```
- [ ] Create: `AttributeDto.java` with fields: id, name
- [ ] Open: `FeedbackResponse.java`
- [ ] **Line 54**: Add field: `private String attributeName;` to AttributeRatingDto
- [ ] Open: `FeedbackService.java`
- [ ] **Line 128-135**: Update mapping to include attribute name lookup
- [ ] Test: Verify `ar.attributeName` now defined in JSON

## 🧪 Testing Points

| Test | Expected | Current | Status |
|------|----------|---------|--------|
| GET /api/feedbacks | List with customerName | Has customerName (not reviewer) | ⚠️  |
| GET /api/feedbacks/{id} | FeedbackResponse with reviewer | Has customerName (not reviewer) | ⚠️ |
| Detail view renders | Reviewer name shown | BLANK | ❌ |
| Attribute table renders | Attribute names shown | BLANK | ❌ |
| Attribute detail loads | With attributeName | Only attributeId | ❌ |

## 📝 Configuration References

### Settings Files
- **feedback-service/src/main/resources/application.properties**
  - `user-service.url=` (used in UserServiceClient)
  - `product-service.url=` (used in ProductServiceClient)

### Controller Routes
- `GET /feedback/stats` → renders feedback-stats.jsp page
- `GET /api/feedbacks` → returns list of all feedbacks
- `GET /api/feedbacks/{id}` → returns single feedback with details
- `GET /api/feedbacks/product/{productId}` → returns feedbacks for product

