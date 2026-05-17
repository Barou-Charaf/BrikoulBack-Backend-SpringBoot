package com.esemsar.backend.services.impl;

import com.esemsar.backend.dtos.requests.DriverProfileRequest;
import com.esemsar.backend.dtos.responses.DriverProfileResponse;
import com.esemsar.backend.entities.DriverProfile;
import com.esemsar.backend.entities.User;
import com.esemsar.backend.enums.Role;
import com.esemsar.backend.enums.VehicleType;
import com.esemsar.backend.exceptions.ForbiddenException;
import com.esemsar.backend.exceptions.ResourceNotFoundException;
import com.esemsar.backend.mappers.DriverMapper;
import com.esemsar.backend.repositories.DriverProfileRepository;
import com.esemsar.backend.services.DriverService;
import com.esemsar.backend.services.UserService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class DriverServiceImpl implements DriverService {
    private final DriverProfileRepository driverRepository;
    private final UserService userService;
    private final DriverMapper driverMapper;

    public DriverServiceImpl(DriverProfileRepository driverRepository, UserService userService, DriverMapper driverMapper) {
        this.driverRepository = driverRepository;
        this.userService = userService;
        this.driverMapper = driverMapper;
    }

    @Override
    public DriverProfile currentDriver() {
        User user = userService.currentUser();
        if (user.getRole() != Role.DRIVER) {
            throw new ForbiddenException("Driver role required");
        }
        return driverRepository.findByUserId(user.getId())
            .orElseThrow(() -> new ResourceNotFoundException("Driver profile not found"));
    }

    @Override
    public DriverProfileResponse getMe() {
        return driverMapper.toResponse(currentDriver());
    }

    @Override
    @Transactional
    public DriverProfileResponse updateMe(DriverProfileRequest request) {
        DriverProfile driver = currentDriver();
        driver.setCurrentCity(request.currentCity());
        if (request.available() != null) {
            driver.setAvailable(request.available());
        }
        return driverMapper.toResponse(driverRepository.save(driver));
    }

    @Override
    @Transactional
    public DriverProfileResponse setAvailability(boolean available) {
        DriverProfile driver = currentDriver();
        driver.setAvailable(available);
        return driverMapper.toResponse(driverRepository.save(driver));
    }

    @Override
    public Page<DriverProfileResponse> list(Pageable pageable) {
        return driverRepository.findAll(pageable).map(driverMapper::toResponse);
    }

    @Override
    public DriverProfileResponse getById(Long id) {
        return driverMapper.toResponse(driverRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Driver profile not found")));
    }

    @Override
    public Page<DriverProfileResponse> search(String city, VehicleType vehicleType, Double minCapacityKg, Pageable pageable) {
        return driverRepository.search(blankToNull(city), vehicleType, minCapacityKg, pageable).map(driverMapper::toResponse);
    }

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value;
    }
}
