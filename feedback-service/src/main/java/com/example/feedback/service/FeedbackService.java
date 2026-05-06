package com.example.feedback.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.feedback.client.ProductServiceClient;
import com.example.feedback.client.UserServiceClient;
import com.example.feedback.entity.Feedback;
import com.example.feedback.repository.FeedbackRepository;

@Service
public class FeedbackService {

    private static final Logger log = LoggerFactory.getLogger(FeedbackService.class);

    private final FeedbackRepository feedbackRepository;
    private final ProductServiceClient productServiceClient;
    private final UserServiceClient userServiceClient;

    public FeedbackService(FeedbackRepository feedbackRepository,
                           ProductServiceClient productServiceClient,
                           UserServiceClient userServiceClient) {
        this.feedbackRepository = feedbackRepository;
        this.productServiceClient = productServiceClient;
        this.userServiceClient = userServiceClient;
    }

    @Transactional(readOnly = true)
    public Feedback getFeedbackById(Long id) {
        Feedback fb = feedbackRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Feedback không tồn tại: id=" + id));
        enrich(List.of(fb));
        return fb;
    }

    @Transactional(readOnly = true)
    public List<Feedback> getFeedbacksByDateRange(String fromDate, String toDate, Long productId) {
        LocalDateTime from = LocalDate.parse(fromDate).atStartOfDay();
        LocalDateTime to = LocalDate.parse(toDate).atTime(LocalTime.MAX);
        List<Feedback> list = productId != null
                ? feedbackRepository.findByProductIdAndDateRange(productId, from, to)
                : feedbackRepository.findByDateRange(from, to);
        return enrich(list);
    }

    /**
     * Enrich danh sách feedback với customerName và attributeName.
     * Cache theo id để tránh gọi inter-service trùng lặp.
     */
    private List<Feedback> enrich(List<Feedback> list) {
        Map<Long, String> customerCache  = new java.util.HashMap<>();
        Map<Long, String> attributeCache = new java.util.HashMap<>();

        for (Feedback fb : list) {
            // Customer name
            String cname = customerCache.computeIfAbsent(fb.getCustomerId(), cid -> {
                try {
                    com.example.feedback.dto.CustomerDto c = userServiceClient.getCustomer(cid);
                    return c != null && c.getFullName() != null ? c.getFullName() : null;
                } catch (Exception e) { return null; }
            });
            fb.setCustomerName(cname);

            // Attribute names
            for (com.example.feedback.entity.AttributeRating ar : fb.getAttributeRatings()) {
                String aname = attributeCache.computeIfAbsent(ar.getAttributeId(), aid -> {
                    try {
                        com.example.feedback.dto.AttributeDto a = productServiceClient.getAttribute(aid);
                        return a != null ? a.getName() : null;
                    } catch (Exception e) { return null; }
                });
                ar.setAttributeName(aname);
            }
        }
        return list;
    }

    @Transactional
    public void deleteFeedback(Long id) {
        if (!feedbackRepository.existsById(id)) {
            throw new IllegalArgumentException("Feedback không tồn tại: id=" + id);
        }
        feedbackRepository.deleteById(id);
        log.info("[DB] Đã xóa phản hồi id={}", id);
    }
}
