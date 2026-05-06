package com.example.feedback.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.feedback.entity.Feedback;

public interface FeedbackRepository extends JpaRepository<Feedback, Long> {

    @Query("SELECT f FROM Feedback f WHERE f.createdAt BETWEEN :from AND :to ORDER BY f.createdAt DESC")
    List<Feedback> findByDateRange(@Param("from") LocalDateTime from, @Param("to") LocalDateTime to);

    @Query("SELECT f FROM Feedback f WHERE f.productId = :productId AND f.createdAt BETWEEN :from AND :to ORDER BY f.createdAt DESC")
    List<Feedback> findByProductIdAndDateRange(@Param("productId") Long productId,
                                               @Param("from") LocalDateTime from,
                                               @Param("to") LocalDateTime to);
}
