package com.example.feedback.dto;

/**
 * Thống kê phản hồi trên từng thuộc tính sản phẩm.
 * Kế thừa AttributeRatingDto và bổ sung thông tin thống kê tổng hợp.
 */
public class AttributeStat extends FeedbackResponse.AttributeRatingDto {

    private Integer totalRatings;
    private Double averageRating;

    public AttributeStat() {}

    public AttributeStat(Long attributeId, Integer rating, String comment,
                         Integer totalRatings, Double averageRating) {
        super(attributeId, rating, comment);
        this.totalRatings = totalRatings;
        this.averageRating = averageRating;
    }

    public Integer getTotalRatings() { return totalRatings; }
    public void setTotalRatings(Integer totalRatings) { this.totalRatings = totalRatings; }

    public Double getAverageRating() { return averageRating; }
    public void setAverageRating(Double averageRating) { this.averageRating = averageRating; }
}
