package com.example.product.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.product.entity.Product;

public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findAllByOrderByIdDesc();

    @Query("SELECT p FROM Product p WHERE " +
           "(:keyword IS NULL OR LOWER(p.name) LIKE LOWER(CONCAT('%',:keyword,'%'))) " +
           "OR (:keyword IS NOT NULL AND LOWER(p.category.name) LIKE LOWER(CONCAT('%',:keyword,'%'))) " +
           "ORDER BY p.id DESC")
    List<Product> searchByKeyword(@Param("keyword") String keyword);
}
