package com.esemsar.backend.mappers;

import com.esemsar.backend.dtos.responses.ShipperProfileResponse;
import com.esemsar.backend.entities.ShipperProfile;
import org.springframework.stereotype.Component;

@Component
public class ShipperMapper {
    private final UserMapper userMapper;

    public ShipperMapper(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public ShipperProfileResponse toResponse(ShipperProfile shipper) {
        if (shipper == null) {
            return null;
        }
        return new ShipperProfileResponse(
            shipper.getId(),
            userMapper.toResponse(shipper.getUser()),
            shipper.getCompanyName(),
            shipper.getAddress(),
            shipper.getAverageRating(),
            shipper.getCompletedOffers(),
            shipper.getCreatedAt(),
            shipper.getUpdatedAt()
        );
    }
}
