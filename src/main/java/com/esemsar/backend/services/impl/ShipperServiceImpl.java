package com.esemsar.backend.services.impl;

import com.esemsar.backend.dtos.requests.ShipperProfileRequest;
import com.esemsar.backend.dtos.responses.ShipperProfileResponse;
import com.esemsar.backend.entities.ShipperProfile;
import com.esemsar.backend.entities.User;
import com.esemsar.backend.enums.Role;
import com.esemsar.backend.exceptions.ForbiddenException;
import com.esemsar.backend.exceptions.ResourceNotFoundException;
import com.esemsar.backend.mappers.ShipperMapper;
import com.esemsar.backend.repositories.ShipperProfileRepository;
import com.esemsar.backend.services.ShipperService;
import com.esemsar.backend.services.UserService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ShipperServiceImpl implements ShipperService {
    private final ShipperProfileRepository shipperRepository;
    private final UserService userService;
    private final ShipperMapper shipperMapper;

    public ShipperServiceImpl(ShipperProfileRepository shipperRepository, UserService userService, ShipperMapper shipperMapper) {
        this.shipperRepository = shipperRepository;
        this.userService = userService;
        this.shipperMapper = shipperMapper;
    }

    @Override
    public ShipperProfile currentShipper() {
        User user = userService.currentUser();
        if (user.getRole() != Role.SHIPPER) {
            throw new ForbiddenException("Shipper role required");
        }
        return shipperRepository.findByUserId(user.getId())
            .orElseThrow(() -> new ResourceNotFoundException("Shipper profile not found"));
    }

    @Override
    public ShipperProfileResponse getMe() {
        return shipperMapper.toResponse(currentShipper());
    }

    @Override
    @Transactional
    public ShipperProfileResponse updateMe(ShipperProfileRequest request) {
        ShipperProfile shipper = currentShipper();
        shipper.setCompanyName(request.companyName());
        shipper.setAddress(request.address());
        return shipperMapper.toResponse(shipperRepository.save(shipper));
    }

    @Override
    public ShipperProfileResponse getById(Long id) {
        return shipperMapper.toResponse(shipperRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Shipper profile not found")));
    }
}
