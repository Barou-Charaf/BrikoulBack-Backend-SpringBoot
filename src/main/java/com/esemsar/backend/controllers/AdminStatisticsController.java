package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.responses.AdminStatisticsResponse;
import com.esemsar.backend.dtos.responses.PaymentResponse;
import com.esemsar.backend.services.PaymentService;
import com.esemsar.backend.services.StatisticsService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin")
public class AdminStatisticsController {
    private final StatisticsService statisticsService;
    private final PaymentService paymentService;

    public AdminStatisticsController(StatisticsService statisticsService, PaymentService paymentService) {
        this.statisticsService = statisticsService;
        this.paymentService = paymentService;
    }

    @GetMapping("/statistics")
    public AdminStatisticsResponse statistics() {
        return statisticsService.statistics();
    }

    @GetMapping("/statistics/users")
    public AdminStatisticsResponse userStatistics() {
        return statisticsService.statistics();
    }

    @GetMapping("/statistics/offers")
    public AdminStatisticsResponse offerStatistics() {
        return statisticsService.statistics();
    }

    @GetMapping("/statistics/income")
    public AdminStatisticsResponse incomeStatistics() {
        return statisticsService.statistics();
    }

    @GetMapping("/payments")
    public Page<PaymentResponse> payments(Pageable pageable) {
        return paymentService.list(pageable);
    }
}
