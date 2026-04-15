package com.example.product.dto;

import java.math.BigDecimal;
import java.util.List;

public class ProductCreateRequest {

    private String name;
    private BigDecimal price;
    private Integer stockQuantity;
    private Long categoryId;
    private List<FixedAttributeEntry> fixedAttributes;
    private List<ExtraAttributeEntry> extraAttributes;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public Integer getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(Integer stockQuantity) { this.stockQuantity = stockQuantity; }

    public Long getCategoryId() { return categoryId; }
    public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }

    public List<FixedAttributeEntry> getFixedAttributes() { return fixedAttributes; }
    public void setFixedAttributes(List<FixedAttributeEntry> fixedAttributes) { this.fixedAttributes = fixedAttributes; }

    public List<ExtraAttributeEntry> getExtraAttributes() { return extraAttributes; }
    public void setExtraAttributes(List<ExtraAttributeEntry> extraAttributes) { this.extraAttributes = extraAttributes; }

    public static class FixedAttributeEntry {
        private Long attributeId;
        private String value;
        public Long getAttributeId() { return attributeId; }
        public void setAttributeId(Long attributeId) { this.attributeId = attributeId; }
        public String getValue() { return value; }
        public void setValue(String value) { this.value = value; }
    }

    public static class ExtraAttributeEntry {
        private String name;
        private String value;
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getValue() { return value; }
        public void setValue(String value) { this.value = value; }
    }
}
