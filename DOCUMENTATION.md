# 📚 DOCUMENTATION - Microservices Project

**Project:** Product & Feedback Management System  
**Architecture:** Microservices + MVC Pattern  
**Created:** 2026-04-15

---

## 📑 Table of Contents

1. [System Overview](#1-system-overview)
2. [Architecture](#2-architecture)
3. [Services & Modules](#3-services--modules)
4. [Database Design](#4-database-design)
5. [Code Reference & Data Flow](#5-code-reference--data-flow)
6. [Known Issues & Fixes](#6-known-issues--fixes)
7. [Quick Start](#7-quick-start)

---

## 1. System Overview

### 1.1 Project Purpose

A microservices-based system for managing products and viewing feedback with an admin panel.

**Key Features:**
- Admin panel to manage products and their attributes
- Feedback viewing and analytics system
- API Gateway for centralized routing
- Microservices architecture with independent databases

### 1.2 Tech Stack

- **Language:** Java
- **Framework:** Spring Boot, Spring Cloud Gateway
- **Data:** MySQL, JPA/Hibernate
- **Frontend:** JSP
- **Build:** Maven
- **Containerization:** Docker, Docker Compose

---

## 2. Architecture

### 2.1 Microservices Architecture Overview

```
Client (Browser)
      │
      ▼
┌─────────────────────┐
│   API Gateway       │  
│   (port 8080)       │  Spring Cloud Gateway
└────────┬────────────┘
         │ Route by path
    ┌────┼────┐
    ▼    ▼    ▼
┌────────────────┐  ┌──────────────┐  ┌───────────────┐
│ product-service│  │ feedback-svc │  │ user-service  │
│   (8081)       │  │   (8082)     │  │   (8083)      │
└────────┬───────┘  └──────┬───────┘  └───────┬───────┘
         │                 │                  │
    ┌────▼──────┐  ┌───────▼──────┐  ┌────────▼─────┐
    │ product_db│  │ feedback_db  │  │  users_db    │
    │ (MySQL)   │  │  (MySQL)     │  │  (MySQL)     │
    └───────────┘  └──────────────┘  └──────────────┘
```

**Advantages:**
- Independent deployment and scaling
- Separate databases per service (Database per Service pattern)
- Fault isolation - service failure doesn't affect others
- Teams can work on services independently
- Each service has its own tech stack (if needed)

### 2.2 Layered Architecture (Per Service)

Each service follows **MVC/Layered Architecture**:

```
HTTP Request
      │
      ▼
┌───────────────────┐
│   CONTROLLER      │  ← REST Endpoints (@RestController)
│  (V = View)       │
└────────┬──────────┘
         │
      ▼
┌───────────────────┐
│   SERVICE         │  ← Business Logic
│  (C = Controller) │  ← Validation, Rules, Orchestration
└────────┬──────────┘
         │
      ▼
┌───────────────────┐
│  REPOSITORY       │  ← Data Access (Spring Data JPA)
│  (M = Model)      │
└────────┬──────────┘
         │
      ▼
┌───────────────────┐
│    DATABASE       │
│    (MySQL)        │
└───────────────────┘
```

**Layer Responsibilities:**
| Layer | Purpose | Examples |
|-------|---------|----------|
| Controller | Handle HTTP requests, call services, return responses | ProductController, FeedbackController |
| Service | Business logic, validation, inter-service calls | ProductService, FeedbackService |
| Repository | Database access via JPA queries | ProductRepository, FeedbackRepository |
| Entity | Database table mapping | Product, Feedback, User |
| DTO | Data transfer objects (separate from Entity) | ProductResponse, FeedbackCreateRequest |

---

## 3. Services & Modules

### 3.1 Product Management

**Location:** product-service

**Features:**
- Full-text search for products
- Add new products with fixed & extra attributes
- Update product information
- Delete products (cascade)
- Inventory management
- Category classification
- Attribute management

**Admin Only Operations:**
- Add/Edit/Delete products
- Manage attributes
- View product feedback statistics

**API Endpoints:**
```
GET    /api/products              → List all products
GET    /api/products/{id}         → Get product details
POST   /api/products              → Create new product
PUT    /api/products/{id}         → Update product
DELETE /api/products/{id}         → Delete product
GET    /api/products/search       → Search products

GET    /api/categories            → List categories
GET    /api/attributes            → List attributes
```

### 3.2 Feedback Management

**Location:** feedback-service

**Features:**
- View feedback on products
- Rate overall product (1-5 stars)
- Rate individual product attributes (1-5 stars)
- Comment and analytics on product & attributes
- Product ratings visualization
- Inter-service communication with product service

**Admin Operations:**
- View all feedbacks
- View feedback per product
- Analytics on ratings & comments

**API Endpoints:**
```
GET    /api/feedbacks              → List all feedbacks
GET    /api/feedbacks/{id}         → Get feedback details
GET    /api/feedbacks/product/{id} → Get feedbacks for product
POST   /api/feedbacks              → Create new feedback
DELETE /api/feedbacks/{id}         → Delete feedback
```

### 3.3 API Gateway

**Location:** api-gateway (port 8080)

**Purpose:**
- Single entry point for all requests
- Route requests to appropriate microservice
- Handle cross-cutting concerns (logging, security)
- Load balancing ready

**Routing Rules:**
```
/api/products/**     → product-service:8081
/api/feedbacks/**    → feedback-service:8082
/api/users/**        → user-service:8083
/                    → product-service:8081 (default)
```

---

## 4. Database Design

### 4.1 Product Database (product_db)

```sql
-- Admin Users table
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,        -- BCrypt hash
    full_name VARCHAR(200),
    email VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories table
CREATE TABLE categories (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Attributes table
CREATE TABLE attributes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Category-Attribute relationship (N:N)
CREATE TABLE category_attributes (
    category_id BIGINT NOT NULL,
    attribute_id BIGINT NOT NULL,
    PRIMARY KEY (category_id, attribute_id),
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    FOREIGN KEY (attribute_id) REFERENCES attributes(id) ON DELETE CASCADE
);

-- Products table
CREATE TABLE products (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(19,2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    category_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
    INDEX idx_category (category_id),
    INDEX idx_name (name)
);

-- Product-Attribute relationship (N:N)
CREATE TABLE product_attributes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,
    attribute_id BIGINT NOT NULL,
    attr_value VARCHAR(255),
    UNIQUE (product_id, attribute_id),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (attribute_id) REFERENCES attributes(id) ON DELETE CASCADE
);
```

### 4.2 Feedback Database (feedback_db)

```sql
-- Feedbacks table
CREATE TABLE feedbacks (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,            -- Reference to product-service
    product_name VARCHAR(255) NOT NULL,
    reviewer_name VARCHAR(255),            -- Reviewer name (from customer)
    comment VARCHAR(1000),
    overall_rating INT NOT NULL,           -- 1-5
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_overall_rating CHECK (overall_rating BETWEEN 1 AND 5),
    INDEX idx_product (product_id),
    INDEX idx_created (created_at DESC)
);

-- Attribute Ratings table (1:N with Feedbacks)
CREATE TABLE attribute_ratings (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    feedback_id BIGINT NOT NULL,
    attribute_name VARCHAR(255) NOT NULL,
    rating INT NOT NULL,                   -- 1-5
    comment VARCHAR(500),
    FOREIGN KEY (feedback_id) REFERENCES feedbacks(id) ON DELETE CASCADE,
    CONSTRAINT chk_attr_rating CHECK (rating BETWEEN 1 AND 5),
    INDEX idx_feedback (feedback_id)
);
```

**Key Design Notes:**
- Each service has its own database (Database per Service pattern)
- No direct foreign keys between services (only value references)
- Inter-service communication via HTTP REST APIs
- Feedback service stores product_name & reviewer_name copies (denormalization for resilience)

---

## 5. Code Reference & Data Flow

### 5.1 Backend Code Structure

**Key Files by Service:**

| Component | File Path | Purpose |
|-----------|-----------|---------|
| Product Controller | `product-service/src/.../ProductController.java` | REST endpoints for products |
| Product Service | `product-service/src/.../ProductService.java` | Business logic |
| Product Repository | `product-service/src/.../ProductRepository.java` | Database queries |
| Feedback Controller | `feedback-service/src/.../FeedbackController.java` | REST endpoints |
| Feedback Service | `feedback-service/src/.../FeedbackService.java` | Business logic |
| Feedback Response DTO | `feedback-service/src/.../FeedbackResponse.java` | API response structure |
| Product Service Client | `feedback-service/src/.../ProductServiceClient.java` | HTTP calls to product-service |


### 5.2 Sample Data Flow: Get Feedback Details

```
Request: GET /api/feedbacks/1 (via feedback-stats.jsp)
            ↓
        FeedbackController.getById(1)
            ↓
        FeedbackService.getFeedbackById(1)
            │
            ├─ Query: feedbackRepository.findById(1)
            │  └─ Database: SELECT * FROM feedbacks WHERE id=1
            │     Returns: Feedback { id:1, productId:101, userId:5 }
            │
            ├─ Call: userServiceClient.getUser(5)
            │  └─ HTTP: GET http://user-service:8083/api/users/5
            │     Returns: UserDto { id:5, fullName:"Nguyen Van A", email:"..." }
            │
            ├─ Call: productServiceClient.getProduct(101)
            │  └─ HTTP: GET http://product-service:8081/api/products/101
            │     Returns: ProductDto { id:101, name:"Samsung Phone" }
            │
            └─ Convert to FeedbackResponse (toResponse method)
                ├─ Set customerName ← userDto.fullName ✅
                ├─ Set productName ← productDto.name ✅
                ├─ Map attribute ratings (with IDs)
                └─ Return JSON response
            ↓
        Return JSON:
        {
          "id": 1,
          "productId": 101,
          "productName": "Samsung Phone",
          "userId": 5,
          "customerName": "Nguyen Van A",
          "attributeRatings": [
            { "attributeId": 1, "rating": 5, "comment": "Nice" }
          ]
        }
            ↓
        Frontend processes response in feedback-stats.jsp
```

---

## 6. Known Issues & Fixes

### 6.1 Critical Issues Found

#### Issue #1: Reviewer Name Field Missing
**Problem:** Frontend expects `f.reviewer` but backend sends `f.customerName`

**Location:** 
- Backend: `feedback-service/src/.../FeedbackResponse.java` (Line 11)
- Frontend: `feedback-service/src/main/webapp/WEB-INF/jsp/feedback-stats.jsp` (Line 1030-1035)

**Fix:**
```java
// In FeedbackResponse.java - Rename field:
private String reviewer;        // Changed from: customerName

// In FeedbackService.java - Update setter:
res.setReviewer(customerDto.getFullName());
```

#### Issue #2: Attribute Names Not Included
**Problem:** Frontend expects `ar.attributeName` but backend only sends `ar.attributeId`

**Location:**
- Backend: `feedback-service/src/.../FeedbackService.java` (Line 128-135)
- Frontend: `feedback-service/src/main/webapp/WEB-INF/jsp/feedback-stats.jsp` (Line 1209-1214)

**Fix:** Need to fetch attribute names from product-service and include in response

```java
// In FeedbackResponse.AttributeRatingDto:
private String attributeName;   // Add this field

// In FeedbackService.toResponse():
// Fetch attribute details from product-service
String attributeName = productServiceClient.getAttribute(attributeId).getName();
attributeDto.setAttributeName(attributeName);
```

#### Issue #3: N+1 Query Problem
**Problem:** Multiple service calls causing performance degradation

**Solution:** 
- Implement caching for frequently accessed attributes
- Consider batch API calls to product-service
- Add circuit breaker pattern for resilience

---

## 7. Quick Start

### 7.1 Prerequisites
- Java 11+
- Maven 3.6+
- MySQL 5.7+
- Docker (optional)

### 7.2 Running Locally

**Step 1: Start MySQL Databases**
```bash
# Start all containers
docker-compose up -d

# Or create databases manually
mysql -u root < schema/mk_dir.sql
```

**Step 2: Build Project**
```bash
mvn clean package
```

**Step 3: Start Services**
```bash
# Terminal 1: product-service
cd product-service
mvn spring-boot:run

# Terminal 2: feedback-service
cd feedback-service
mvn spring-boot:run

# Terminal 3: user-service (if exists)
cd user-service
mvn spring-boot:run

# Terminal 4: api-gateway
cd api-gateway
mvn spring-boot:run
```

**Step 4: Access Application**
- Main Application: http://localhost:8080
- API Gateway: http://localhost:8080
- Product Service: http://localhost:8081
- Feedback Service: http://localhost:8082

### 7.3 Default Credentials

**Admin Account:**
- Username: `admin`
- Password: `admin123`

### 7.4 Using Docker Compose

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f [service-name]
```

---

## 📞 Support

For issues or questions, refer to:
- Code Reference Map for detailed file locations
- Database schema in `/schema` directory
- Individual service README files
- GitHub repository: https://github.com/damduc2004/BTL_NMH.git

---

**Last Updated:** 2026-04-15  
**Version:** 1.0
