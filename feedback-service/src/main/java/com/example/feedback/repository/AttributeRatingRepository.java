package com.example.feedback.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.feedback.entity.AttributeRating;

public interface AttributeRatingRepository extends JpaRepository<AttributeRating, Long> {
}
