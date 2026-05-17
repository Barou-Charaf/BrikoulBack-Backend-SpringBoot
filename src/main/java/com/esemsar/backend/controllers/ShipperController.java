package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.requests.ShipperProfileRequest;
import com.esemsar.backend.dtos.responses.ShipperProfileResponse;
import com.esemsar.backend.services.ShipperService;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/shippers")
public class ShipperController {
    private final ShipperService shipperService;

    public ShipperController(ShipperService shipperService) {
        this.shipperService = shipperService;
    }

    @GetMapping("/me")
    @PreAuthorize("hasRole('SHIPPER')")
    public ShipperProfileResponse me() {
        return shipperService.getMe();
    }

    @PutMapping("/me")
    @PreAuthorize("hasRole('SHIPPER')")
    public ShipperProfileResponse updateMe(@Valid @RequestBody ShipperProfileRequest request) {
        return shipperService.updateMe(request);
    }

    @GetMapping("/{id}")
    public ShipperProfileResponse get(@PathVariable Long id) {
        return shipperService.getById(id);
    }
}
