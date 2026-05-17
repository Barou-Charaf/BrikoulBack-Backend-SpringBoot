package com.esemsar.backend.services;

import com.esemsar.backend.dtos.requests.DriverProfileRequest;
import com.esemsar.backend.dtos.responses.DriverProfileResponse;
import com.esemsar.backend.entities.DriverProfile;
import com.esemsar.backend.enums.VehicleType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface DriverService {
    DriverProfile currentDriver();

    DriverProfileResponse getMe();

    DriverProfileResponse updateMe(DriverProfileRequest request);

    DriverProfileResponse setAvailability(boolean available);

    Page<DriverProfileResponse> list(Pageable pageable);

    DriverProfileResponse getById(Long id);

    Page<DriverProfileResponse> search(String city, VehicleType vehicleType, Double minCapacityKg, Pageable pageable);
}
