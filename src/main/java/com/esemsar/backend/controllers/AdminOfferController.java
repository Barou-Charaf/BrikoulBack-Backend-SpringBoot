package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.responses.OfferResponse;
import com.esemsar.backend.services.AdminService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/offers")
public class AdminOfferController {
    private final AdminService adminService;

    public AdminOfferController(AdminService adminService) {
        this.adminService = adminService;
    }

    @GetMapping
    public Page<OfferResponse> offers(Pageable pageable) {
        return adminService.offers(pageable);
    }

    @GetMapping("/{id}")
    public OfferResponse offer(@PathVariable Long id) {
        return adminService.offer(id);
    }

    @PatchMapping("/{id}/cancel")
    public OfferResponse cancel(@PathVariable Long id) {
        return adminService.cancelOffer(id);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        adminService.deleteOffer(id);
    }
}
