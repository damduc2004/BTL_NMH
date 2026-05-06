package com.example.product.repository;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.product.entity.Product;

public interface ProductRepository extends JpaRepository<Product, Long> {

    Page<Product> findAllByOrderByIdDesc(Pageable pageable);

    @Query("SELECT p FROM Product p WHERE " +
           "LOWER(p.name) LIKE LOWER(CONCAT('%',:keyword,'%')) " +
           "OR LOWER(p.category.name) LIKE LOWER(CONCAT('%',:keyword,'%')) " +
           "ORDER BY p.id DESC")
    Page<Product> searchByKeyword(@Param("keyword") String keyword, Pageable pageable);

    // Giữ lại để inter-service dùng (getProductById trả về đơn lẻ)
    List<Product> findAllByOrderByIdDesc();
}
