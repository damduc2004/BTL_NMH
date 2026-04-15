package com.example.feedback.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.feedback.entity.Feedback;

public interface FeedbackRepository extends JpaRepository<Feedback, Long> {
    List<Feedback> findByProductId(Long productId);
    List<Feedback> findAllByOrderByIdDesc();
    List<Feedback> findByProductIdOrderByIdDesc(Long productId);
}
