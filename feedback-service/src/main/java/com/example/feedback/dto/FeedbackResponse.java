package com.example.feedback.dto;

import java.time.LocalDateTime;
import java.util.List;

public class FeedbackResponse {

    private Long id;
    private Long productId;
    private String productName;
    private Long customerId;
    private String customerName;
    private String reviewer;  // Alias for customerName
    private String customerEmail;
    private String comment;
    private Integer overallRating;
    private LocalDateTime createdAt;
    private List<AttributeRatingDto> attributeRatings;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getReviewer() { return reviewer; }
    public void setReviewer(String reviewer) { this.reviewer = reviewer; }

    public String getCustomerEmail() { return customerEmail; }
    public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public Integer getOverallRating() { return overallRating; }
    public void setOverallRating(Integer overallRating) { this.overallRating = overallRating; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public List<AttributeRatingDto> getAttributeRatings() { return attributeRatings; }
    public void setAttributeRatings(List<AttributeRatingDto> attributeRatings) { this.attributeRatings = attributeRatings; }

    public static class AttributeRatingDto {
        private Long attributeId;
        private String attributeName;  // NEW: attribute name from product service
        private Integer rating;
        private String comment;

        public AttributeRatingDto() {}

        public AttributeRatingDto(Long attributeId, Integer rating, String comment) {
            this.attributeId = attributeId;
            this.rating = rating;
            this.comment = comment;
        }

        public AttributeRatingDto(Long attributeId, String attributeName, Integer rating, String comment) {
            this.attributeId = attributeId;
            this.attributeName = attributeName;
            this.rating = rating;
            this.comment = comment;
        }

        public Long getAttributeId() { return attributeId; }
        public void setAttributeId(Long attributeId) { this.attributeId = attributeId; }

        public String getAttributeName() { return attributeName; }
        public void setAttributeName(String attributeName) { this.attributeName = attributeName; }

        public Integer getRating() { return rating; }
        public void setRating(Integer rating) { this.rating = rating; }

        public String getComment() { return comment; }
        public void setComment(String comment) { this.comment = comment; }
    }
}
