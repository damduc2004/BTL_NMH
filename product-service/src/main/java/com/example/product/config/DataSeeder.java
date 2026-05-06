package com.example.product.config;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.example.product.entity.Attribute;
import com.example.product.entity.Category;
import com.example.product.entity.Product;
import com.example.product.entity.ProductAttribute;
import com.example.product.repository.AttributeRepository;
import com.example.product.repository.CategoryRepository;
import com.example.product.repository.ProductRepository;

@Component
public class DataSeeder implements CommandLineRunner {

    private final CategoryRepository categoryRepository;
    private final AttributeRepository attributeRepository;
    private final ProductRepository productRepository;

    public DataSeeder(CategoryRepository categoryRepository,
                      AttributeRepository attributeRepository,
                      ProductRepository productRepository) {
        this.categoryRepository = categoryRepository;
        this.attributeRepository = attributeRepository;
        this.productRepository = productRepository;
    }

    @Override
    @Transactional
    public void run(String... args) {
        if (productRepository.count() > 0) {
            return;
        }

        // ===== Attributes (find-or-create) =====
        Attribute thuongHieu = save("Thuong hieu");
        Attribute mauSac     = save("Mau sac");
        Attribute dungLuong  = save("Dung luong");
        Attribute kichThuoc  = save("Kich thuoc");
        Attribute chatLieu   = save("Chat lieu");
        Attribute baoHanh    = save("Bao hanh");
        Attribute xuatXu     = save("Xuat xu");
        Attribute cauHinh    = save("Cau hinh");
        Attribute loaiSan    = save("Loai san pham");
        Attribute trongLuong = save("Trong luong");

        // ===== Categories (find-or-create) =====
        Category dienThoai = saveCategory("Dien thoai",
                new ArrayList<>(List.of(thuongHieu, mauSac, dungLuong, baoHanh, xuatXu)));
        Category mayTinh   = saveCategory("May tinh",
                new ArrayList<>(List.of(thuongHieu, mauSac, cauHinh, dungLuong, baoHanh)));
        Category thoiTrang = saveCategory("Thoi trang",
                new ArrayList<>(List.of(thuongHieu, mauSac, kichThuoc, chatLieu, xuatXu)));
        Category giaydep   = saveCategory("Giay dep",
                new ArrayList<>(List.of(thuongHieu, mauSac, kichThuoc, chatLieu)));
        Category doGiaDung = saveCategory("Do gia dung",
                new ArrayList<>(List.of(thuongHieu, loaiSan, trongLuong, baoHanh, xuatXu)));

        // ===== Sample Products =====
        // Dien thoai
        addProduct("iPhone 15 Pro Max", new BigDecimal("29990000"), 50, dienThoai,
                List.of(
                    new String[]{"Thuong hieu", "Apple"},
                    new String[]{"Mau sac", "Titan Den"},
                    new String[]{"Dung luong", "256GB"},
                    new String[]{"Bao hanh", "12 thang"},
                    new String[]{"Xuat xu", "USA"}
                ));

        addProduct("Samsung Galaxy S24 Ultra", new BigDecimal("24990000"), 75, dienThoai,
                List.of(
                    new String[]{"Thuong hieu", "Samsung"},
                    new String[]{"Mau sac", "Xanh duong"},
                    new String[]{"Dung luong", "512GB"},
                    new String[]{"Bao hanh", "24 thang"},
                    new String[]{"Xuat xu", "Han Quoc"}
                ));

        addProduct("Xiaomi 14 Ultra", new BigDecimal("18490000"), 120, dienThoai,
                List.of(
                    new String[]{"Thuong hieu", "Xiaomi"},
                    new String[]{"Mau sac", "Trang"},
                    new String[]{"Dung luong", "256GB"},
                    new String[]{"Bao hanh", "12 thang"},
                    new String[]{"Xuat xu", "Trung Quoc"}
                ));

        // May tinh
        addProduct("MacBook Air M3", new BigDecimal("32990000"), 30, mayTinh,
                List.of(
                    new String[]{"Thuong hieu", "Apple"},
                    new String[]{"Mau sac", "Bac"},
                    new String[]{"Cau hinh", "M3 8GB 256GB"},
                    new String[]{"Dung luong", "256GB SSD"},
                    new String[]{"Bao hanh", "12 thang"}
                ));

        addProduct("Dell XPS 15", new BigDecimal("38500000"), 20, mayTinh,
                List.of(
                    new String[]{"Thuong hieu", "Dell"},
                    new String[]{"Mau sac", "Den"},
                    new String[]{"Cau hinh", "Intel i7 16GB 512GB"},
                    new String[]{"Dung luong", "512GB SSD"},
                    new String[]{"Bao hanh", "24 thang"}
                ));

        // Thoi trang
        addProduct("Ao Polo Lacoste Classic", new BigDecimal("1890000"), 200, thoiTrang,
                List.of(
                    new String[]{"Thuong hieu", "Lacoste"},
                    new String[]{"Mau sac", "Do"},
                    new String[]{"Kich thuoc", "L"},
                    new String[]{"Chat lieu", "Cotton 100%"},
                    new String[]{"Xuat xu", "Phap"}
                ));

        addProduct("Quan Jean Levi's 501", new BigDecimal("1490000"), 150, thoiTrang,
                List.of(
                    new String[]{"Thuong hieu", "Levi's"},
                    new String[]{"Mau sac", "Xanh duong dam"},
                    new String[]{"Kich thuoc", "32x32"},
                    new String[]{"Chat lieu", "Denim"},
                    new String[]{"Xuat xu", "USA"}
                ));

        // Giay dep
        addProduct("Nike Air Force 1", new BigDecimal("2790000"), 100, giaydep,
                List.of(
                    new String[]{"Thuong hieu", "Nike"},
                    new String[]{"Mau sac", "Trang"},
                    new String[]{"Kich thuoc", "42"},
                    new String[]{"Chat lieu", "Da tong hop"}
                ));

        // Do gia dung
        addProduct("Noi com dien Cuckoo 1.8L", new BigDecimal("3290000"), 60, doGiaDung,
                List.of(
                    new String[]{"Thuong hieu", "Cuckoo"},
                    new String[]{"Loai san pham", "Noi com dien"},
                    new String[]{"Trong luong", "3.2 kg"},
                    new String[]{"Bao hanh", "24 thang"},
                    new String[]{"Xuat xu", "Han Quoc"}
                ));
    }

    private void addProduct(String name, BigDecimal price, int stock, Category category,
                             List<String[]> attrPairs) {
        Product p = new Product();
        p.setName(name);
        p.setPrice(price);
        p.setStockQuantity(stock);
        p.setCategory(category);

        List<ProductAttribute> pas = new ArrayList<>();
        for (String[] pair : attrPairs) {
            Attribute attr = save(pair[0]);
            pas.add(new ProductAttribute(p, attr, pair[1]));
        }
        p.setProductAttributes(pas);
        productRepository.save(p);
    }

    private Attribute save(String name) {
        return attributeRepository.findByName(name)
            .orElseGet(() -> attributeRepository.save(new Attribute(name)));
    }

    private Category saveCategory(String name, List<Attribute> attributes) {
        return categoryRepository.findByName(name).orElseGet(() -> {
            Category c = new Category(name);
            c.setAttributes(attributes);
            return categoryRepository.save(c);
        });
    }
}
