package com.esemsar.backend.dtos.responses;

import com.esemsar.backend.enums.GoodsType;
import com.esemsar.backend.enums.OfferStatus;
import com.esemsar.backend.enums.VehicleType;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public record OfferSummaryResponse(
    Long id,
    String title,
    String departureCity,
    String arrivalCity,
    GoodsType goodsType,
    Double weightKg,
    VehicleType requiredVehicleType,
    BigDecimal proposedPrice,
    OfferStatus status,
    LocalDateTime transportDate
) {
}
