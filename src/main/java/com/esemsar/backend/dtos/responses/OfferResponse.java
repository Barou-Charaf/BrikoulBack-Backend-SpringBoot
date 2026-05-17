package com.esemsar.backend.dtos.responses;

import com.esemsar.backend.enums.GoodsType;
import com.esemsar.backend.enums.OfferStatus;
import com.esemsar.backend.enums.VehicleType;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public record OfferResponse(
    Long id,
    String title,
    String description,
    String departureCity,
    String arrivalCity,
    String pickupAddress,
    String deliveryAddress,
    GoodsType goodsType,
    Double weightKg,
    VehicleType requiredVehicleType,
    BigDecimal proposedPrice,
    Integer maxDriversToNotify,
    OfferStatus status,
    LocalDateTime transportDate,
    ShipperProfileResponse shipper,
    DriverProfileResponse assignedDriver,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {
}
