package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.requests.DriverProfileRequest;
import com.esemsar.backend.dtos.responses.DriverProfileResponse;
import com.esemsar.backend.dtos.responses.TruckResponse;
import com.esemsar.backend.enums.VehicleType;
import com.esemsar.backend.services.DriverService;
import com.esemsar.backend.services.TruckService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/drivers")
public class DriverController {
    private final DriverService driverService;
    private final TruckService truckService;

    public DriverController(DriverService driverService, TruckService truckService) {
        this.driverService = driverService;
        this.truckService = truckService;
    }

    @GetMapping("/me")
    @PreAuthorize("hasRole('DRIVER')")
    public DriverProfileResponse me() {
        return driverService.getMe();
    }

    @PutMapping("/me")
    @PreAuthorize("hasRole('DRIVER')")
    public DriverProfileResponse updateMe(@Valid @RequestBody DriverProfileRequest request) {
        return driverService.updateMe(request);
    }

    @PatchMapping("/me/availability")
    @PreAuthorize("hasRole('DRIVER')")
    public DriverProfileResponse availability(@RequestParam boolean available) {
        return driverService.setAvailability(available);
    }

    @GetMapping
    public Page<DriverProfileResponse> list(Pageable pageable) {
        return driverService.list(pageable);
    }

    @GetMapping("/{id}")
    public DriverProfileResponse get(@PathVariable Long id) {
        return driverService.getById(id);
    }

    @GetMapping("/{id}/trucks")
    public List<TruckResponse> trucks(@PathVariable Long id) {
        driverService.getById(id);
        return truckService.byDriver(id);
    }

    @GetMapping("/search")
    public Page<DriverProfileResponse> search(
        @RequestParam(required = false) String city,
        @RequestParam(required = false) VehicleType vehicleType,
        @RequestParam(required = false) Double minCapacityKg,
        Pageable pageable
    ) {
        return driverService.search(city, vehicleType, minCapacityKg, pageable);
    }
}
