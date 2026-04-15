package com.example.product.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ProductPageServlet {

    @GetMapping("/products/add")
    public String showAddProductPage() {
        return "add-product";
    }
}
