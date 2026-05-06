package com.example.feedback.controller;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.feedback.entity.Feedback;
import com.example.feedback.service.FeedbackService;

@RestController
@RequestMapping("/api/feedbacks")
public class FeedbackController {

    private static final Logger log = LoggerFactory.getLogger(FeedbackController.class);

    private final FeedbackService feedbackService;

    public FeedbackController(FeedbackService feedbackService) {
        this.feedbackService = feedbackService;
    }

    @GetMapping("/{id}")
    public Feedback getById(@PathVariable Long id) {
        log.info("GET /api/feedbacks/{}", id);
        return feedbackService.getFeedbackById(id);
    }

    /**
     * Lọc feedback theo khoảng thời gian.
     * Ví dụ: GET /api/feedbacks/range?from=2025-01-01&to=2025-12-31
     *        GET /api/feedbacks/range?from=2025-01-01&to=2025-12-31&productId=3
     */
    @GetMapping("/range")
    public List<Feedback> getByDateRange(
            @RequestParam String from,
            @RequestParam String to,
            @RequestParam(required = false) Long productId) {
        log.info("GET /api/feedbacks/range from={} to={} productId={}", from, to, productId);
        return feedbackService.getFeedbacksByDateRange(from, to, productId);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        log.info("[ADMIN] DELETE /api/feedbacks/{}", id);
        feedbackService.deleteFeedback(id);
        return ResponseEntity.noContent().build();
    }
}
