package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.responses.ReviewResponse;
import com.esemsar.backend.services.AdminService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/reviews")
public class AdminReviewController {
    private final AdminService adminService;

    public AdminReviewController(AdminService adminService) {
        this.adminService = adminService;
    }

    @GetMapping
    public Page<ReviewResponse> reviews(Pageable pageable) {
        return adminService.reviews(pageable);
    }

    @GetMapping("/{id}")
    public ReviewResponse review(@PathVariable Long id) {
        return adminService.review(id);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        adminService.deleteReview(id);
    }
}
