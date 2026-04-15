package com.example.feedback.dto;

import java.util.List;

public class FeedbackCreateRequest {

    private Long productId;
    private Long customerId;
    private String comment;
    private Integer overallRating;
    private List<AttributeRatingEntry> attributeRatings;

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public Long getCustomerId() { return customerId; }
    public void setCustomerId(Long customerId) { this.customerId = customerId; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public Integer getOverallRating() { return overallRating; }
    public void setOverallRating(Integer overallRating) { this.overallRating = overallRating; }

    public List<AttributeRatingEntry> getAttributeRatings() { return attributeRatings; }
    public void setAttributeRatings(List<AttributeRatingEntry> attributeRatings) { this.attributeRatings = attributeRatings; }

    public static class AttributeRatingEntry {
        private Long attributeId;
        private Integer rating;
        private String comment;

        public Long getAttributeId() { return attributeId; }
        public void setAttributeId(Long attributeId) { this.attributeId = attributeId; }

        public Integer getRating() { return rating; }
        public void setRating(Integer rating) { this.rating = rating; }

        public String getComment() { return comment; }
        public void setComment(String comment) { this.comment = comment; }
    }
}
