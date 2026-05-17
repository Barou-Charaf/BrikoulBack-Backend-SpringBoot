package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.responses.DriverProfileResponse;
import com.esemsar.backend.dtos.responses.TruckResponse;
import com.esemsar.backend.services.AdminService;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/drivers")
public class AdminDriverController {
    private final AdminService adminService;

    public AdminDriverController(AdminService adminService) {
        this.adminService = adminService;
    }

    @GetMapping
    public Page<DriverProfileResponse> drivers(Pageable pageable) {
        return adminService.drivers(pageable);
    }

    @GetMapping("/{id}")
    public DriverProfileResponse driver(@PathVariable Long id) {
        return adminService.driver(id);
    }

    @GetMapping("/{id}/trucks")
    public List<TruckResponse> trucks(@PathVariable Long id) {
        return adminService.driverTrucks(id);
    }

    @PatchMapping("/{id}/approve")
    public DriverProfileResponse approve(@PathVariable Long id) {
        return adminService.setDriverAvailable(id, true);
    }

    @PatchMapping("/{id}/suspend")
    public DriverProfileResponse suspend(@PathVariable Long id) {
        return adminService.setDriverAvailable(id, false);
    }
}
