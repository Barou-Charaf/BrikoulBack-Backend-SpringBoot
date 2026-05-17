package com.esemsar.backend.services;

import com.esemsar.backend.dtos.requests.ShipperProfileRequest;
import com.esemsar.backend.dtos.responses.ShipperProfileResponse;
import com.esemsar.backend.entities.ShipperProfile;

public interface ShipperService {
    ShipperProfile currentShipper();

    ShipperProfileResponse getMe();

    ShipperProfileResponse updateMe(ShipperProfileRequest request);

    ShipperProfileResponse getById(Long id);
}
