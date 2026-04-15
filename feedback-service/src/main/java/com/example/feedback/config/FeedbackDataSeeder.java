package com.example.feedback.config;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import com.example.feedback.entity.AttributeRating;
import com.example.feedback.entity.Feedback;
import com.example.feedback.repository.FeedbackRepository;

@Component
public class FeedbackDataSeeder implements CommandLineRunner {

    private final FeedbackRepository feedbackRepository;

    public FeedbackDataSeeder(FeedbackRepository feedbackRepository) {
        this.feedbackRepository = feedbackRepository;
    }

    @Override
    @Transactional
    public void run(String... args) {
        if (feedbackRepository.count() > 0) {
            return;
        }

        // Customer IDs khop voi user-service DataSeeder:
        // admin=1, manager1=2, customer1=3, customer2=4, customer3=5
        // Attribute IDs tu product-service DataSeeder (theo thu tu tao):
        // 1=Thuong hieu, 2=Mau sac, 3=Dung luong, 4=Kich thuoc, 5=Chat lieu
        // 6=Bao hanh, 7=Xuat xu, 8=Cau hinh, 9=Loai san pham, 10=Trong luong

        addFeedback(1L, 3L, 5,
                "San pham tuyet voi, camera sieu net, hieu nang manh me.",
                LocalDateTime.now().minusDays(10),
                List.of(
                    ar(1L, 5, "Apple luon chat luong hang dau"),
                    ar(2L, 5, "Mau titan den rat sang trong"),
                    ar(3L, 4, "256GB du dung nhung gia hoi cao"),
                    ar(6L, 5, "Ho tro bao hanh rat nhiet tinh"),
                    ar(7L, 5, "Hang chinh hang USA")
                ));

        addFeedback(1L, 4L, 4,
                "May dep, pin kha lau nhung gia qua cao so voi thi truong.",
                LocalDateTime.now().minusDays(7),
                List.of(
                    ar(1L, 5, "Apple - thuong hieu so 1"),
                    ar(2L, 4, "Mau dep nhung de ban tay"),
                    ar(3L, 4, "Du dung cho cong viec"),
                    ar(6L, 4, "Bao hanh on, co the cai thien them")
                ));

        addFeedback(2L, 5L, 5,
                "Man hinh sac net, but S Pen rat tien loi, cam hung viet tay dinh nhat.",
                LocalDateTime.now().minusDays(5),
                List.of(
                    ar(1L, 5, "Samsung chat luong cao cap"),
                    ar(2L, 4, "Mau xanh dep nhung kho phoi do"),
                    ar(3L, 5, "512GB la qua du"),
                    ar(6L, 5, "Bao hanh 24 thang rat an tam"),
                    ar(7L, 5, "Han Quoc chinh hang")
                ));

        addFeedback(2L, 3L, 3,
                "May tot nhung pin hao nhanh khi dung nhieu, hoi nong may.",
                LocalDateTime.now().minusDays(3),
                List.of(
                    ar(1L, 4, "Samsung co the tin tuong"),
                    ar(2L, 5, "Rat dep"),
                    ar(3L, 5, "512GB xuyen suot"),
                    ar(6L, 3, "Qua trinh bao hanh kha lau")
                ));

        addFeedback(3L, 4L, 4,
                "Camera Leica sieu xin, gia hop ly, pin cuc khoe. Rat xung dang mua.",
                LocalDateTime.now().minusDays(8),
                List.of(
                    ar(1L, 4, "Xiaomi ngay cang chat luong hon"),
                    ar(2L, 5, "Mau trang sang"),
                    ar(3L, 4, "256GB vua phai"),
                    ar(7L, 3, "Made in China nhung chat luong on")
                ));

        addFeedback(4L, 5L, 5,
                "Chip M3 manh khong tuong, pin 18 tieng, man hinh Retina dep mat. Mua ngay!",
                LocalDateTime.now().minusDays(6),
                List.of(
                    ar(1L, 5, "Apple MacBook luon la best"),
                    ar(2L, 5, "Mau bac sang trong, chuyen nghiep"),
                    ar(8L, 5, "M3 xu ly moi thu ro rang"),
                    ar(3L, 4, "256GB SSD hoi it, nen nang cap"),
                    ar(6L, 5, "Apple Care rat tot")
                ));

        addFeedback(5L, 3L, 4,
                "Thiet ke dep, loa to, man hinh 4K OLED sac net. Pin trung binh khoang 8 tieng.",
                LocalDateTime.now().minusDays(4),
                List.of(
                    ar(1L, 4, "Dell XPS dong san pham cao cap"),
                    ar(2L, 4, "Mau den lich su"),
                    ar(8L, 5, "i7 16GB chay tron tru"),
                    ar(3L, 5, "512GB SSD nhanh"),
                    ar(6L, 4, "Bao hanh 24 thang ok")
                ));

        addFeedback(6L, 4L, 5,
                "Vai mem, thoang mat, mau giu ben sau nhieu lan giat. Rat dang tien.",
                LocalDateTime.now().minusDays(9),
                List.of(
                    ar(1L, 5, "Lacoste hang hieu dang tin"),
                    ar(2L, 5, "Mau do tuoi dep, khong bac"),
                    ar(4L, 4, "Size L vua voi, nen chon dung size"),
                    ar(5L, 5, "Cotton 100% rat thoai mai"),
                    ar(7L, 5, "Phap chinh hang")
                ));

        addFeedback(8L, 5L, 4,
                "Giay dep, de bam tot, phu hop nhieu phong cach. Kha ben sau thoi gian dai.",
                LocalDateTime.now().minusDays(2),
                List.of(
                    ar(1L, 5, "Nike luon chat luong"),
                    ar(2L, 5, "Trang tien loi phoi do"),
                    ar(4L, 4, "Size 42 vua khop, khong can break in nhieu"),
                    ar(5L, 4, "Da tong hop tot nhung non hon da that")
                ));

        addFeedback(9L, 3L, 5,
                "Noi com ngon, giua nhiet rat tot, giao dien de dung cho nguoi gia. Rat hai long.",
                LocalDateTime.now().minusDays(1),
                List.of(
                    ar(1L, 5, "Cuckoo noi tieng ve noi com chat luong"),
                    ar(9L, 5, "Noi com dien da nang, co chuc nang hat thom"),
                    ar(10L, 4, "3.2kg hoi nang nhung chap nhan duoc"),
                    ar(6L, 5, "24 thang bao hanh toan quoc"),
                    ar(7L, 5, "Han Quoc hang chinh hang")
                ));
    }

    private void addFeedback(Long productId, Long customerId,
                              int overall, String comment, LocalDateTime createdAt,
                              List<AttributeRating> attrRatings) {
        Feedback fb = new Feedback();
        fb.setProductId(productId);
        fb.setCustomerId(customerId);
        fb.setOverallRating(overall);
        fb.setComment(comment);
        fb.setCreatedAt(createdAt);

        for (AttributeRating ar : attrRatings) {
            ar.setFeedback(fb);
        }
        fb.setAttributeRatings(attrRatings);
        feedbackRepository.save(fb);
    }

    private AttributeRating ar(Long attributeId, int rating, String comment) {
        return new AttributeRating(null, attributeId, rating, comment);
    }
}
