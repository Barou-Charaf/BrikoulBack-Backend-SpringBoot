package com.esemsar.backend.dtos.requests;

import com.esemsar.backend.enums.GoodsType;
import com.esemsar.backend.enums.VehicleType;
import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public record OfferRequest(
    @NotBlank String title,
    String description,
    @NotBlank String departureCity,
    @NotBlank String arrivalCity,
    String pickupAddress,
    String deliveryAddress,
    GoodsType goodsType,
    @Positive Double weightKg,
    @NotNull VehicleType requiredVehicleType,
    @Positive BigDecimal proposedPrice,
    @Min(1) @Max(50) Integer maxDriversToNotify,
    @Future LocalDateTime transportDate
) {
}
