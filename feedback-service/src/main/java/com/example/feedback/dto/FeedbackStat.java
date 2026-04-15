package com.example.feedback.dto;

/**
 * Thống kê phản hồi của một sản phẩm.
 * Kế thừa FeedbackResponse và bổ sung tổng số phản hồi, điểm trung bình.
 */
public class FeedbackStat extends FeedbackResponse {

    private Integer totalFeedback;
    private Double averageRating;

    public FeedbackStat() {}

    public Integer getTotalFeedback() { return totalFeedback; }
    public void setTotalFeedback(Integer totalFeedback) { this.totalFeedback = totalFeedback; }

    public Double getAverageRating() { return averageRating; }
    public void setAverageRating(Double averageRating) { this.averageRating = averageRating; }
}
