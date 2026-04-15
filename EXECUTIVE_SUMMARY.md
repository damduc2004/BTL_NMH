# 📋 Executive Summary - Feedback Service Analysis

**Created:** 2026-04-15  
**Analyzed:** feedback-service project  
**Status:** ⚠️ CRITICAL ISSUES FOUND

---

## 🎯 Quick Summary

### Issues Found: 2 CRITICAL + 1 MEDIUM

| # | Issue | Severity | Status | Impact |
|---|-------|----------|--------|--------|
| 1 | Reviewer name undefined in API response | 🔴 CRITICAL | FOUND | Feedback details show BLANK reviewer names |
| 2 | Attribute names missing from API response | 🔴 CRITICAL | FOUND | Detail table shows BLANK attribute names |
| 3 | N+1 query problem (performance) | 🟡 MEDIUM | FOUND | Slow API response, excessive inter-service calls |

---

## 🔍 Issue Details

### Issue #1: Reviewer Name (Field Name Mismatch)

**Where:** Frontend expects `f.reviewer`, Backend sends `f.customerName`

**Files Affected:**
- ❌ Frontend: `feedback-service/src/main/webapp/WEB-INF/jsp/feedback-stats.jsp` (L1030-1035)
  ```javascript
  html += '<div class="avatar">' + esc(avatarInitial(f.reviewer)) + '</div>';
  // ❌ f.reviewer is UNDEFINED
  ```

- 🔧 Backend: `feedback-service/src/main/java/com/example/feedback/dto/FeedbackResponse.java` (L11)
  ```java
  private String customerName;  // ← Should be: reviewer
  ```

**Root Cause:** Field naming inconsistency between frontend and backend

**Current Behavior:** 
```json
{
  "customerId": 5,
  "customerName": "Nguyen Van A",   // ✅ Sent
  "reviewer": undefined             // ❌ Frontend expects this
}
```

**Visible Effect:** Reviewer names display as BLANK in feedback detail view

---

### Issue #2: Attribute Names (Missing Data)

**Where:** Frontend expects `ar.attributeName`, Backend sends only `ar.attributeId`

**Files Affected:**
- ❌ Frontend: `feedback-service/src/main/webapp/WEB-INF/jsp/feedback-stats.jsp` (L1209-1214)
  ```javascript
  ar.attributeRatings.forEach(function(ar) {
    html += '<td><b>' + esc(ar.attributeName) + '</b></td>';
    // ❌ ar.attributeName is UNDEFINED
  ```

- 🔧 Backend: `feedback-service/src/main/java/com/example/feedback/service/FeedbackService.java` (L128-135)
  ```java
  res.setAttributeRatings(
    fb.getAttributeRatings().stream()
      .map(ar -> new FeedbackResponse.AttributeRatingDto(
        ar.getAttributeId(),      // ✅ Only ID sent
        ar.getRating(),
        ar.getComment()))
      // ❌ No attribute name lookup
  ```

**Root Cause:** 
1. Attribute names stored in product-service, not in feedback-service DB
2. No ProductServiceClient method to fetch attribute details
3. FeedbackService doesn't look up attribute names during conversion

**Current Behavior:**
```json
{
  "attributeRatings": [
    {
      "attributeId": 42,                      // ✅ Sent
      "rating": 5,                            // ✅ Sent
      "comment": "Nice color",                // ✅ Sent
      "attributeName": undefined              // ❌ Not sent
    }
  ]
}
```

**Visible Effect:** Attribute detail table shows BLANK column for attribute names

---

### Issue #3: N+1 Query Problem (Performance)

**Where:** FeedbackService calls customer/product service per feedback

**Example Scenario:** Fetching 100 feedbacks with their details

```
Queries Generated:
- 1x feedbackRepository.findAll()
- 100x userServiceClient.getCustomer() [one per feedback]
- 100x productServiceClient.getProduct() [one per feedback]
= 201 requests total

If Fix #2 implemented:
- Add 100+x productServiceClient.getAttribute() for each attribute
= 300+ requests total  ❌ Unacceptable
```

**Root Cause:** Waterfall loading without batching or caching

**Visible Effect:** Slow API response, potential service strain

---

## ✅ What Works Correctly

| Field | Backend Sends | Frontend Uses | Status |
|-------|---------------|---------------|--------|
| `productName` | ✅ Yes | ✅ f.productName | ✓ OK |
| `productId` | ✅ Yes | ✅ f.productId | ✓ OK |
| `customerId` | ✅ Yes | ✅ f.customerId | ✓ OK |
| `customerEmail` | ✅ Yes | ✅ f.customerEmail | ✓ OK |
| `overallRating` | ✅ Yes | ✅ f.overallRating | ✓ OK |
| `comment` | ✅ Yes | ✅ f.comment | ✓ OK |
| `createdAt` | ✅ Yes | ✅ f.createdAt | ✓ OK |
| `attributeId` | ✅ Yes | ✅ ar.attributeId | ✓ OK |
| `rating` | ✅ Yes | ✅ ar.rating | ✓ OK |
| `comment` | ✅ Yes | ✅ ar.comment | ✓ OK |
| `customerName` | ✅ Yes | ❌ (expects reviewer) | ✗ MISMATCH |
| `reviewer` | ❌ No | ✅ (expects this) | ✗ MISSING |
| `attributeName` | ❌ No | ✅ (expects this) | ✗ MISSING |

---

## 🛠️ Recommended Solution

### Priority 1: Fix Field Name (15 minutes)

**Option A: Rename field (Breaking change)**
```java
// FeedbackResponse.java
- private String customerName;
+ private String reviewer;
```

**Option B: Add alias field (Backward compatible)**
```java
// FeedbackResponse.java
private String customerName;    // Keep for compatibility
private String reviewer;         // Add new name
```

**Then update:** `FeedbackService.toResponse()` Line 126

---

### Priority 2: Add Attribute Names (30-45 minutes)

**Step 1:** Create method in ProductServiceClient
```java
public AttributeDto getAttribute(Long attributeId) {
    return restTemplate.getForObject(
        productServiceUrl + "/api/attributes/" + attributeId, 
        AttributeDto.class);
}
```

**Step 2:** Add field to AttributeRatingDto
```java
public static class AttributeRatingDto {
    private String attributeName;  // ← NEW
    ...
}
```

**Step 3:** Update FeedbackService to lookup names
```java
f.attributeRatings.stream()
  .map(ar -> {
    String name = productServiceClient
      .getAttribute(ar.getAttributeId())
      .getName();
    return new AttributeRatingDto(
      ar.getAttributeId(),
      name,           // ← NEW: attribute name
      ar.getRating(),
      ar.getComment());
  })
```

---

### Priority 3: Optimize N+1 Queries (1-2 hours)

**Batch load customers and products:**
```java
// Collect IDs
Set<Long> customerIds = feedbacks.stream()
  .map(Feedback::getCustomerId).collect(toSet());
Set<Long> productIds = feedbacks.stream()
  .map(Feedback::getProductId).collect(toSet());

// Batch fetch (requires new methods in clients)
Map<Long, CustomerDto> customers = 
  userServiceClient.getCustomers(customerIds);
Map<Long, ProductDto> products = 
  productServiceClient.getProducts(productIds);

// Convert without per-item lookup
return feedbacks.stream()
  .map(fb -> toResponse(fb, 
    customers.get(fb.getCustomerId()),
    products.get(fb.getProductId())))
```

---

## 📊 Implementation Cost Analysis

| Fix | Effort | Risk | Benefit | Priority |
|-----|--------|------|---------|----------|
| Fix field name (Option B) | 15 min | LOW | High - fixes reviewer view | P1 |
| Add attribute names | 45 min | MEDIUM | High - fixes detail table | P1 |
| Optimize N+1 queries | 2 hours | HIGH | Medium - performance only | P3 |

**Recommended:** Implement Priority 1 & 2 first (1 hour), then P3 later

---

## 🧪 Testing Strategy

### Before Fixes
```bash
curl http://localhost:8083/api/feedbacks/1
# Returns: customerName, NO reviewer, NO attributeName
```

### After Fix 1
```bash
curl http://localhost:8083/api/feedbacks/1
# Returns: reviewer field ✅, customerName still present
```

### After Fix 2
```bash
curl http://localhost:8083/api/feedbacks/1
# Returns: reviewer ✅, attributeName in each rating ✅
```

### Verification Points
- [ ] API returns `reviewer` field
- [ ] API returns `attributeName` in each attributeRating
- [ ] Frontend displays reviewer names (not blank)
- [ ] Frontend displays attribute names (not blank)
- [ ] No JavaScript console errors
- [ ] Response time acceptable (< 2s per feedback)

---

## 📁 Related Documentation

- **FEEDBACK_DATA_FLOW_ANALYSIS.md** - Detailed technical analysis with code samples
- **CODE_REFERENCE_MAP.md** - Quick reference for all key files and line numbers

---

## 📞 Questions & Clarifications

**Q: Why does backend send `customerName` instead of `reviewer`?**  
A: Different naming conventions. Backend uses domain terms (customer), frontend uses UI terms (reviewer). Should align.

**Q: Why aren't attribute names stored in feedback-service DB?**  
A: Microservices design - attribute definitions are in product-service. Feedback service only stores ID references.

**Q: Why the N+1 problem?**  
A: Architecture design - each feedback needs lookup in other services. Should be batched for production.

**Q: Can we cache the lookups?**  
A: Yes, recommended for production - add caching layer or batch loading.

---

## ✅ Conclusion

**Status:** 2 blocking issues found, 1 medium concern  
**User Impact:** HIGH - critical data not displayed  
**Recommended Action:** Implement Priority 1 & 2 fixes immediately  
**Estimated Time:** 1-1.5 hours for implementation  
**Testing Time:** 30 minutes

