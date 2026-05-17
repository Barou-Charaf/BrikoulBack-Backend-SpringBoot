package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.responses.ShipperProfileResponse;
import com.esemsar.backend.services.AdminService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/shippers")
public class AdminShipperController {
    private final AdminService adminService;

    public AdminShipperController(AdminService adminService) {
        this.adminService = adminService;
    }

    @GetMapping
    public Page<ShipperProfileResponse> shippers(Pageable pageable) {
        return adminService.shippers(pageable);
    }

    @GetMapping("/{id}")
    public ShipperProfileResponse shipper(@PathVariable Long id) {
        return adminService.shipper(id);
    }

    @PatchMapping("/{id}/suspend")
    public ShipperProfileResponse suspend(@PathVariable Long id) {
        return adminService.suspendShipper(id);
    }
}
