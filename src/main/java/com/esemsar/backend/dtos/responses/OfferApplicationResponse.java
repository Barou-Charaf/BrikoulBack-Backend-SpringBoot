package com.esemsar.backend.dtos.responses;

import com.esemsar.backend.enums.ApplicationStatus;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public record OfferApplicationResponse(
    Long id,
    String message,
    BigDecimal proposedPrice,
    ApplicationStatus status,
    OfferSummaryResponse offer,
    DriverProfileResponse driver,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {
}
