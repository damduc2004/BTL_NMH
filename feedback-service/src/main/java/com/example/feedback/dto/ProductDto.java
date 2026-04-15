package com.example.feedback.dto;

/**
 * DTO rut gon de nhan thong tin san pham tu product-service
 * (chi can id va name cho viec luu phan hoi)
 */
public class ProductDto {

    private Long id;
    private String name;

    public ProductDto() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
}
