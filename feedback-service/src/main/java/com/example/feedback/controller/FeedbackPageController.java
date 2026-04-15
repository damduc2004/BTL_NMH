package com.example.feedback.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class FeedbackPageController {

    @GetMapping("/feedback/stats")
    public String showFeedbackStatsPage() {
        return "feedback-stats";
    }
}
