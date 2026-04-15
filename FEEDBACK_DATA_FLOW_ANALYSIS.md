# Phân Tích Chi Tiết - Feedback Service Data Flow

**Date:** 2026-04-15  
**Purpose:** Xác định vấn đề trả về dữ liệu giữa API backend và frontend feedback-stats.jsp

---

## 📋 Table of Contents
1. [API Endpoints & Response Structure](#1-api-endpoints--response-structure)
2. [Frontend Data Binding Issues](#2-frontend-data-binding-issues)
3. [Database Query & Repository Analysis](#3-database-query--repository-analysis)
4. [Client Service Calls](#4-client-service-calls)
5. [Root Cause Analysis](#5-root-cause-analysis)
6. [Problems Found](#6-problems-found)
7. [Recommended Fixes](#7-recommended-fixes)

---

## 1. API Endpoints & Response Structure

### 1.1 FeedbackController Endpoints

**File:** `feedback-service/src/main/java/com/example/feedback/controller/FeedbackController.java`

```java
@RestController
@RequestMapping("/api/feedbacks")
public class FeedbackController {
    
    @GetMapping                          // GET /api/feedbacks
    public List<FeedbackResponse> getAll()
    
    @GetMapping("/{id}")                 // GET /api/feedbacks/{id}
    public FeedbackResponse getById(@PathVariable Long id)
    
    @GetMapping("/product/{productId}")  // GET /api/feedbacks/product/{productId}
    public List<FeedbackResponse> getByProduct(@PathVariable Long productId)
    
    @PostMapping                         // POST /api/feedbacks
    public ResponseEntity<FeedbackResponse> create(@RequestBody FeedbackCreateRequest request)
    
    @DeleteMapping("/{id}")              // DELETE /api/feedbacks/{id}
    public ResponseEntity<Void> delete(@PathVariable Long id)
}
```

### 1.2 FeedbackResponse DTO Structure

**File:** `feedback-service/src/main/java/com/example/feedback/dto/FeedbackResponse.java`

```java
public class FeedbackResponse {
    private Long id;                              // ✅
    private Long productId;                       // ✅
    private String productName;                   // ✅ (added in previous fix)
    private Long customerId;                      // ✅
    private String customerName;                  // ✅ (customer full name from user-service)
    private String customerEmail;                 // ✅
    private String comment;                       // ✅
    private Integer overallRating;               // ✅ (1-5)
    private LocalDateTime createdAt;             // ✅
    private List<AttributeRatingDto> attributeRatings;  // ✅
    
    // ❌ MISSING: `reviewer` field (frontend expects this!)
}
```

### 1.3 AttributeRatingDto Nested Structure

```java
public static class AttributeRatingDto {
    private Long attributeId;              // ✅ ID of attribute (from product-service)
    private Integer rating;                // ✅ 1-5 stars
    private String comment;                // ✅ Comment about this attribute
    
    // ❌ MISSING: `attributeName` field (frontend expects this!)
}
```

### 1.4 Sample FeedbackResponse JSON

What frontend currently receives:
```json
{
  "id": 1,
  "productId": 101,
  "productName": "Samsung Galaxy Phone",      // ✅ correct
  "customerId": 5,
  "customerName": "Nguyen Van A",             // ✅ sent as fullName
  "customerEmail": "nguyenvana@gmail.com",
  "comment": "Điện thoại rất tốt",
  "overallRating": 5,
  "createdAt": "2026-04-15T10:30:45",
  "attributeRatings": [
    {
      "attributeId": 1,                        // ✅ ID sent
      "rating": 4,
      "comment": "Màu sắc đẹp"                 // ✅ comment
      // ❌ attributeName NOT included!
    },
    {
      "attributeId": 2,
      "rating": 5,
      "comment": "Pin tốt"
    }
  ]
}
```

---

## 2. Frontend Data Binding Issues

### 2.1 Issue 1: Field Name Mismatch for Reviewer

**File:** `feedback-service/src/main/webapp/WEB-INF/jsp/feedback-stats.jsp` (Line 1030-1035)

```javascript
reviews.forEach(function(f) {
    // ❌ Frontend uses: f.reviewer
    html += '<div class="avatar">' + esc(avatarInitial(f.reviewer)) + '</div>';
    html += '<div class="rc-reviewer">' + esc(f.reviewer) + '</div>';
```

**But Backend sends:** `f.customerName` (not `f.reviewer`)

**Result:** reviewer name is UNDEFINED/NULL in HTML output

### 2.2 Issue 2: Missing Attribute Names

**File:** `feedback-service/src/main/webapp/WEB-INF/jsp/feedback-stats.jsp` (Line 1209-1214)

```javascript
if (f.attributeRatings && f.attributeRatings.length) {
    html += '<table class="attr-detail-table">';
    html += '<thead><tr><th>Thuộc tính</th><th>Điểm</th><th>Nhận xét</th></tr></thead>';
    html += '<tbody>';
    f.attributeRatings.forEach(function(ar) {
        // ❌ Frontend expects: ar.attributeName
        html += '<td><b>' + esc(ar.attributeName) + '</b></td>';
```

**But Backend sends:** Only `ar.attributeId`, `ar.rating`, `ar.comment`

**Result:** Attribute names display as BLANK in the table

### 2.3 What Frontend CORRECTLY Uses

```javascript
// ✅ These work fine:
f.productName          // Gets product name correctly
f.customerId
f.customerEmail
f.overallRating
f.comment
f.createdAt
ar.attributeId         // Gets the ID
ar.rating              // Gets star rating
ar.comment             // Gets comment
```

---

## 3. Database Query & Repository Analysis

### 3.1 FeedbackRepository

**File:** `feedback-service/src/main/java/com/example/feedback/repository/FeedbackRepository.java`

```java
public interface FeedbackRepository extends JpaRepository<Feedback, Long> {
    List<Feedback> findByProductId(Long productId);
    List<Feedback> findAllByOrderByIdDesc();
    List<Feedback> findByProductIdOrderByIdDesc(Long productId);
    
    // ✅ No explicit @Query needed - Spring generates these
    // ✅ Hibernate automatically loads attributeRatings via OneToMany
    // ❌ NO JOIN with users table (usernames fetched via UserServiceClient)
    // ❌ NO JOIN with products table (product names fetched via ProductServiceClient)
}
```

**Query Method Analysis:**
| Method | Returns | JOIN | Notes |
|--------|---------|------|-------|
| `findById()` | Feedback | No | Loads entity + cascaded attributeRatings |
| `findByProductId()` | List<Feedback> | No | Lazy load attributeRatings on access |
| `findAllByOrderByIdDesc()` | List<Feedback> | No | Descending order by ID |

### 3.2 AttributeRatingRepository

**File:** `feedback-service/src/main/java/com/example/feedback/repository/AttributeRatingRepository.java`

```java
public interface AttributeRatingRepository extends JpaRepository<AttributeRating, Long> {
    // ❌ COMPLETELY EMPTY
    // No custom queries
    // Attribute names NEVER queried from this table
}
```

### 3.3 Entity Relationships

**Feedback Entity:**
```java
@Entity
@Table(name = "feedbacks")
public class Feedback {
    @Id @GeneratedValue
    private Long id;
    
    @Column(nullable = false)
    private Long productId;              // ✅ FK reference (NOT a foreign key)
    
    @Column(nullable = false)
    private Long customerId;             // ✅ FK reference (NOT a foreign key)
    
    @OneToMany(mappedBy = "feedback", cascade = CascadeType.ALL)
    private List<AttributeRating> attributeRatings;  // ✅ Loaded with feedback
}
```

**AttributeRating Entity:**
```java
@Entity
@Table(name = "attribute_ratings")
public class AttributeRating {
    @Id @GeneratedValue
    private Long id;
    
    @ManyToOne(optional = false)
    @JoinColumn(name = "feedback_id")
    private Feedback feedback;           // ✅ References Feedback
    
    @Column(nullable = false)
    private Long attributeId;            // ✅ References product service's Attribute
    
    @Column(nullable = false)
    private Integer rating;              // 1-5
    
    @Column(length = 500)
    private String comment;              // Comment about this attribute
}
```

**Key Finding:** 
- ❌ `attributeId` is just a number, stored in feedback-service DB
- ❌ Actual attribute name is in product-service, NOT accessible without calling product-service API
- ❌ No foreign key constraint between attribute_ratings.attributeId and product.attributes.id

---

## 4. Client Service Calls

### 4.1 FeedbackService Data Mapping

**File:** `feedback-service/src/main/java/com/example/feedback/service/FeedbackService.java`

```java
@Service
public class FeedbackService {
    private final FeedbackRepository feedbackRepository;
    private final ProductServiceClient productServiceClient;
    private final UserServiceClient userServiceClient;
    
    // ── Method 1: getAllFeedbacks() ──
    public List<FeedbackResponse> getAllFeedbacks() {
        return feedbackRepository.findAllByOrderByIdDesc().stream()
                .map(fb -> toResponseWithCustomerLookup(fb))
                .toList();
    }
    
    // ── Method 2: getFeedbackById() ──
    public FeedbackResponse getFeedbackById(Long id) {
        Feedback fb = feedbackRepository.findById(id)
                .orElseThrow(...);
        return toResponseWithCustomerLookup(fb);
    }
    
    // ── Conversion Method ──
    private FeedbackResponse toResponseWithCustomerLookup(Feedback fb) {
        // Look up customer from user-service
        CustomerDto customer = userServiceClient.getCustomer(fb.getCustomerId());
        // Look up product from product-service
        ProductDto product = productServiceClient.getProduct(fb.getProductId());
        return toResponse(fb, customer, product);
    }
    
    private FeedbackResponse toResponse(Feedback fb, CustomerDto customer, ProductDto product) {
        FeedbackResponse res = new FeedbackResponse();
        
        res.setId(fb.getId());
        res.setProductId(fb.getProductId());
        res.setProductName(product != null ? product.getName() : "Product #" + fb.getProductId());
        res.setCustomerId(fb.getCustomerId());
        res.setCustomerName(customer != null ? customer.getFullName() : "Customer #" + fb.getCustomerId());  // ✅ Set
        res.setCustomerEmail(customer != null ? customer.getEmail() : null);
        res.setComment(fb.getComment());
        res.setOverallRating(fb.getOverallRating());
        res.setCreatedAt(fb.getCreatedAt());
        
        res.setAttributeRatings(
            fb.getAttributeRatings().stream()
                .map(ar -> new FeedbackResponse.AttributeRatingDto(
                        ar.getAttributeId(),      // ✅ Only ID sent
                        ar.getRating(),           // ✅ Rating sent
                        ar.getComment()))          // ✅ Comment sent
                                                   // ❌ attributeId NOT converted to name
                .toList()
        );
        return res;
    }
}
```

### 4.2 UserServiceClient

**File:** `feedback-service/src/main/java/com/example/feedback/client/UserServiceClient.java`

```java
@Component
public class UserServiceClient {
    @Value("${user-service.url}")
    private String userServiceUrl;
    
    public CustomerDto getCustomer(Long customerId) {
        String url = userServiceUrl + "/api/customers/" + customerId;
        // Calls: http://user-service:8082/api/customers/5
        
        // Returns CustomerDto with: id, username, fullName, email, tel, status
        // ✅ fullName is retrieved here
        return restTemplate.getForObject(url, CustomerDto.class);
    }
}
```

### 4.3 ProductServiceClient

**File:** `feedback-service/src/main/java/com/example/feedback/client/ProductServiceClient.java`

```java
@Component
public class ProductServiceClient {
    @Value("${product-service.url}")
    private String productServiceUrl;
    
    public ProductDto getProduct(Long productId) {
        String url = productServiceUrl + "/api/products/" + productId;
        // Returns ProductDto with: id, name
        return restTemplate.exchange(url, HttpMethod.GET, entity, ProductDto.class).getBody();
    }
    
    // ❌ NO method to get attribute details!
    // ❌ Attribute names not fetched from product-service
}
```

---

## 5. Root Cause Analysis

### 5.1 Why Reviewer Name is Missing

**Flow:**
```
API Request: GET /api/feedbacks/{id}
    ↓
FeedbackController.getById()
    ↓
FeedbackService.getFeedbackById(id)
    ↓
FeedbackRepository.findById() → Feedback entity
    ↓
FeedbackService.toResponseWithCustomerLookup()
    ├─ customerServiceClient.getCustomer() → CustomerDto { fullName: "Nguyen Van A" }
    └─ toResponse() → res.setCustomerName("Nguyen Van A")
    ↓
FeedbackResponse { customerName: "Nguyen Van A" } ← Only this field!
    ↓
Frontend JS expects: f.reviewer
    ❌ f.reviewer is undefined/null
```

**Issue:** Backend sends `customerName`, Frontend expects `reviewer`

### 5.2 Why Attribute Names are Missing

**Flow:**
```
Database: attribute_ratings
    ├─ feedback_id: 1
    ├─ attributeId: 42    ← This is just a number!
    └─ rating: 5
    ↓
FeedbackService.toResponse() 
    └─ Only copies: attributeId, rating, comment
    ↓
AttributeRatingDto { attributeId: 42, rating: 5, comment: "Good" }
    ↓
Frontend receives JSON:
{
  "attributeRatings": [
    { "attributeId": 42, "rating": 5, "comment": "Good" }
    // ❌ No name field!
  ]
}
    ↓
Frontend JS tries: ar.attributeName
    ❌ undefined/null
```

**Issue 1:** `attributeId` is just a reference ID, not the actual name
**Issue 2:** Attribute names exist in product-service database, NOT fetched
**Issue 3:** No ProductServiceClient method to get attribute details

---

## 6. Problems Found

### 🔴 Problem 1: Reviewer Name Field Mismatch
**Severity:** HIGH  
**Location:** 
- Frontend: feedback-stats.jsp line 1030-1035
- Backend: FeedbackResponse uses `customerName` instead of `reviewer`

**Impact:** Reviewer names display as BLANK/NULL in feedback details view

**Root Cause:** Field naming inconsistency between frontend and backend

### 🔴 Problem 2: Missing Attribute Names in Response
**Severity:** HIGH  
**Location:**
- Frontend: feedback-stats.jsp line 1209-1214 expects `ar.attributeName`
- Backend: FeedbackService only sends `attributeId`

**Impact:** Attribute names display as BLANK in detail table

**Root Cause:** 
1. Attribute names stored in product-service, not in feedback-service DB
2. No method in ProductServiceClient to fetch attribute names by ID
3. FeedbackService doesn't call product-service to get attribute details

### 🟡 Problem 3: N+1 Query Problem (Performance)
**Severity:** MEDIUM  
**Location:** FeedbackService.toResponseWithCustomerLookup()

**Impact:** Slow API response when fetching multiple feedbacks
```
Fetching 100 feedbacks causes:
- 1 query to feedback DB
- 100 queries to user-service (one per feedback)
- 100 queries to product-service (one per feedback)
- Potentially 500+ queries to product-service for attribute names (if fixed)
= 600+ API calls!
```

**Root Cause:** Waterfall loading without caching

---

## 7. Recommended Fixes

### Fix 1: Add `reviewer` Field to FeedbackResponse (Quick Fix)

**Option A: Rename field**
```java
// In FeedbackResponse.java
- private String customerName;
+ private String reviewer;  // Explicit name for frontend

// In FeedbackService.toResponse()
- res.setCustomerName(customer != null ? customer.getFullName() : "Customer #" + fb.getCustomerId());
+ res.setReviewer(customer != null ? customer.getFullName() : "Customer #" + fb.getCustomerId());
```

**Option B: Add both fields** (safer for backward compatibility)
```java
private String customerName;    // Keep for compatibility
private String reviewer;         // Add for frontend

// In toResponse():
res.setCustomerName(customer != null ? customer.getFullName() : ...);
res.setReviewer(res.getCustomerName());  // Same value
```

---

### Fix 2: Add Attribute Names to Response (Required)

**Step 1:** Add field to AttributeRatingDto
```java
public static class AttributeRatingDto {
    private Long attributeId;
    private String attributeName;    // ← NEW
    private Integer rating;
    private String comment;
}
```

**Step 2:** Add method to ProductServiceClient
```java
public AttributeDto getAttribute(Long attributeId) {
    String url = productServiceUrl + "/api/attributes/" + attributeId;
    return restTemplate.getForObject(url, AttributeDto.class);
}

class AttributeDto {
    private Long id;
    private String name;
}
```

**Step 3:** Update FeedbackService.toResponse()
```java
res.setAttributeRatings(
    fb.getAttributeRatings().stream()
        .map(ar -> {
            String attrName = "Attribute #" + ar.getAttributeId();
            try {
                // Fetch attribute name (with fallback)
                AttributeDto attr = productServiceClient.getAttribute(ar.getAttributeId());
                if (attr != null) attrName = attr.getName();
            } catch (Exception e) {
                log.warn("Could not fetch attribute name: {}", ar.getAttributeId());
            }
            return new FeedbackResponse.AttributeRatingDto(
                ar.getAttributeId(),
                attrName,        // ← NEW: attribute name
                ar.getRating(),
                ar.getComment());
        })
        .toList()
);
```

---

### Fix 3: Optimize N+1 Queries (Advanced)

**Batch load customers and products:**
```java
public List<FeedbackResponse> getAllFeedbacks() {
    List<Feedback> feedbacks = feedbackRepository.findAllByOrderByIdDesc();
    
    // Collect unique IDs
    Set<Long> customerIds = feedbacks.stream()
        .map(Feedback::getCustomerId)
        .collect(toSet());
    Set<Long> productIds = feedbacks.stream()
        .map(Feedback::getProductId)
        .collect(toSet());
    
    // Batch load (requires new methods in clients)
    Map<Long, CustomerDto> customers = userServiceClient.getCustomers(customerIds);
    Map<Long, ProductDto> products = productServiceClient.getProducts(productIds);
    
    // Convert without per-item lookup
    return feedbacks.stream()
        .map(fb -> toResponse(fb, 
                customers.get(fb.getCustomerId()),
                products.get(fb.getProductId())))
        .toList();
}
```

---

## 📊 Summary Table

| Aspect | Current State | Issue | Fix |
|--------|-------|---------|-----|
| **Reviewer Name** | `customerName` field | Frontend expects `reviewer` | Add/rename to `reviewer` field |
| **Attribute Names** | Only `attributeId` sent | Frontend expects `attributeName` | Fetch from product-service + include in DTO |
| **Query Performance** | N+1 problems (per item lookup) | 100 feedbacks = 200+ API calls | Batch load with caching |
| **Attribute Details** | Not fetched at all | No API method available | Create getAttribute(id) in ProductServiceClient |
| **Data Consistency** | Depends on external services | Services might be down | Add fallback values + error handling |

---

## 🎯 Implementation Priority

1. **Priority 1 (Must Fix):** Problem 1 - Add `reviewer` field
2. **Priority 2 (Must Fix):** Problem 2 - Add attribute names to response
3. **Priority 3 (Should Fix):** Problem 3 - Optimize N+1 queries
4. **Priority 4 (Nice to Have):** Add comprehensive error handling and caching

