-- ============ USER SERVICE DATABASE SCHEMA ============

CREATE DATABASE IF NOT EXISTS user_db;
USE user_db;

-- ============ ADMIN USERS (Data Provider) ============
-- This table stores admin/staff information.
-- User-Service is a READ-ONLY Data Provider - other services call this API to get user info.
-- No passwords stored - this is purely for information retrieval.

CREATE TABLE IF NOT EXISTS admins (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    username   VARCHAR(100) NOT NULL UNIQUE,
    full_name  VARCHAR(200),
    email      VARCHAR(200),
    tel        VARCHAR(20),
    department VARCHAR(50),                    -- Department/Team (Product, Quality, Management, etc)
    status     TINYINT(1)  NOT NULL DEFAULT 1,-- 1: active, 0: inactive
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_department (department),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============ SAMPLE DATA - ADMIN USERS ============
INSERT INTO admins (username, full_name, email, tel, department, status, created_at) 
VALUES 
    ('admin', 'Administrator', 'admin@example.com', '1234567890', 'Management', 1, NOW()),
    ('manager1', 'Product Manager 1', 'manager1@example.com', '0987654321', 'Product', 1, NOW()),
    ('manager2', 'Product Manager 2', 'manager2@example.com', '0987654322', 'Product', 1, NOW()),
    ('feedback_manager', 'Feedback Manager', 'feedback_manager@example.com', '0987654323', 'Quality', 1, NOW())
ON DUPLICATE KEY UPDATE username=VALUES(username);

-- ============ NOTES ============
-- 
-- This service acts as a DATA PROVIDER for other microservices:
-- 
-- 1. product-service calls GET /users/{id}
--    → To display who created/updated each product
-- 
-- 2. feedback-service calls:
--    → GET /users/{id} to get admin info
--    → GET /customers/{id} to get customer details by ID
--    → To display "John Doe gave 5 stars" instead of "User ID 5 gave 5 stars"
-- 
-- This eliminates data duplication across services and maintains a single source of truth for user information.

