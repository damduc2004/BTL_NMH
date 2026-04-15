package com.example.feedback.controller;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.feedback.dto.FeedbackCreateRequest;
import com.example.feedback.dto.FeedbackResponse;
import com.example.feedback.service.FeedbackService;

@RestController
@RequestMapping("/api/feedbacks")
public class FeedbackController {

    private static final Logger log = LoggerFactory.getLogger(FeedbackController.class);

    private final FeedbackService feedbackService;

    public FeedbackController(FeedbackService feedbackService) {
        this.feedbackService = feedbackService;
    }

    @GetMapping
    public List<FeedbackResponse> getAll() {
        log.info("[USER ACTION] Tai toan bo danh sach phan hoi");
        List<FeedbackResponse> list = feedbackService.getAllFeedbacks();
        log.info("[RESPONSE] Tra ve {} phan hoi", list.size());
        return list;
    }

    @GetMapping("/{id}")
    public FeedbackResponse getById(@PathVariable Long id) {
        log.info("[USER ACTION] Xem chi tiet phan hoi id={}", id);
        FeedbackResponse res = feedbackService.getFeedbackById(id);
        log.info("[RESPONSE] Tra ve phan hoi id={} | customerName='{}', productId={}",
                res.getId(), res.getCustomerName(), res.getProductId());
        return res;
    }

    @GetMapping("/product/{productId}")
    public List<FeedbackResponse> getByProduct(@PathVariable Long productId) {
        log.info("[USER ACTION] Xem phan hoi cua san pham id={}", productId);
        List<FeedbackResponse> list = feedbackService.getFeedbacksByProduct(productId);
        log.info("[RESPONSE] Tra ve {} phan hoi cho productId={}", list.size(), productId);
        return list;
    }

    @PostMapping
    public ResponseEntity<FeedbackResponse> create(@RequestBody FeedbackCreateRequest request) {
        log.info("[USER ACTION] Tao phan hoi moi | customerId={}, productId={}", request.getCustomerId(), request.getProductId());
        FeedbackResponse res = feedbackService.createFeedback(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(res);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        log.info("[ADMIN] Nguoi dung quan tri xoa phan hoi id={}", id);
        feedbackService.deleteFeedback(id);
        log.info("[ADMIN] Xoa phan hoi id={} thanh cong", id);
        return ResponseEntity.noContent().build();
    }
}
