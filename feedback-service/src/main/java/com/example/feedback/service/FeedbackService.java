package com.example.feedback.service;

import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.feedback.client.ProductServiceClient;
import com.example.feedback.client.UserServiceClient;
import com.example.feedback.dto.CustomerDto;
import com.example.feedback.dto.FeedbackCreateRequest;
import com.example.feedback.dto.FeedbackResponse;
import com.example.feedback.dto.ProductDto;
import com.example.feedback.entity.AttributeRating;
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

    @Transactional
    public FeedbackResponse createFeedback(FeedbackCreateRequest req) {
        log.info("[USER ACTION] Tao phan hoi | productId={}, customerId={}, overallRating={}",
                req.getProductId(), req.getCustomerId(), req.getOverallRating());

        // Xac thuc san pham tu product-service
        ProductDto product = productServiceClient.getProduct(req.getProductId());
        if (product == null) {
            throw new IllegalArgumentException("Khong tim thay san pham voi id: " + req.getProductId());
        }

        // Xac thuc customer tu user-service
        CustomerDto customer = userServiceClient.getCustomer(req.getCustomerId());
        if (customer == null) {
            throw new IllegalArgumentException("Khong tim thay customer voi id: " + req.getCustomerId());
        }

        Feedback fb = new Feedback();
        fb.setProductId(req.getProductId());
        fb.setCustomerId(req.getCustomerId());
        fb.setComment(req.getComment());
        fb.setOverallRating(req.getOverallRating());

        List<AttributeRating> ratings = new ArrayList<>();
        if (req.getAttributeRatings() != null) {
            for (FeedbackCreateRequest.AttributeRatingEntry entry : req.getAttributeRatings()) {
                ratings.add(new AttributeRating(fb, entry.getAttributeId(), entry.getRating(), entry.getComment()));
            }
        }
        fb.setAttributeRatings(ratings);

        Feedback saved = feedbackRepository.save(fb);
        log.info("[DB] Luu phan hoi thanh cong | feedbackId={}, customerId={}, productId={}",
                saved.getId(), saved.getCustomerId(), saved.getProductId());

        return toResponse(saved, customer);
    }

    @Transactional(readOnly = true)
    public List<FeedbackResponse> getAllFeedbacks() {
        return feedbackRepository.findAllByOrderByIdDesc().stream()
                .map(fb -> toResponseWithCustomerLookup(fb))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<FeedbackResponse> getFeedbacksByProduct(Long productId) {
        return feedbackRepository.findByProductIdOrderByIdDesc(productId).stream()
                .map(fb -> toResponseWithCustomerLookup(fb))
                .toList();
    }

    @Transactional(readOnly = true)
    public FeedbackResponse getFeedbackById(Long id) {
        Feedback fb = feedbackRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Feedback khong ton tai voi id: " + id));
        return toResponseWithCustomerLookup(fb);
    }

    @Transactional
    public void deleteFeedback(Long id) {
        if (!feedbackRepository.existsById(id)) {
            throw new IllegalArgumentException("Feedback khong ton tai voi id: " + id);
        }
        feedbackRepository.deleteById(id);
        log.info("[DB] Da xoa phan hoi id={}", id);
    }

    private FeedbackResponse toResponseWithCustomerLookup(Feedback fb) {
        CustomerDto customer = userServiceClient.getCustomer(fb.getCustomerId());
        ProductDto product = productServiceClient.getProduct(fb.getProductId());
        return toResponse(fb, customer, product);
    }

    private FeedbackResponse toResponse(Feedback fb, CustomerDto customer) {
        ProductDto product = productServiceClient.getProduct(fb.getProductId());
        return toResponse(fb, customer, product);
    }

    private FeedbackResponse toResponse(Feedback fb, CustomerDto customer, ProductDto product) {
        FeedbackResponse res = new FeedbackResponse();
        res.setId(fb.getId());
        res.setProductId(fb.getProductId());
        res.setProductName(product != null ? product.getName() : "Product #" + fb.getProductId());
        res.setCustomerId(fb.getCustomerId());
        res.setCustomerName(customer != null ? customer.getFullName() : "Customer #" + fb.getCustomerId());
        res.setReviewer(customer != null ? customer.getFullName() : "Customer #" + fb.getCustomerId());
        res.setCustomerEmail(customer != null ? customer.getEmail() : null);
        res.setComment(fb.getComment());
        res.setOverallRating(fb.getOverallRating());
        res.setCreatedAt(fb.getCreatedAt());
        res.setAttributeRatings(
            fb.getAttributeRatings().stream()
                .map(ar -> {
                    String attributeName = null;
                    try {
                        com.example.feedback.dto.AttributeDto attrDto = productServiceClient.getAttribute(ar.getAttributeId());
                        attributeName = attrDto != null ? attrDto.getName() : "Attribute #" + ar.getAttributeId();
                    } catch (Exception e) {
                        log.warn("Failed to fetch attribute name for attributeId={}: {}", ar.getAttributeId(), e.getMessage());
                        attributeName = "Attribute #" + ar.getAttributeId();
                    }
                    return new FeedbackResponse.AttributeRatingDto(
                            ar.getAttributeId(), attributeName, ar.getRating(), ar.getComment());
                })
                .toList()
        );
        return res;
    }
}
