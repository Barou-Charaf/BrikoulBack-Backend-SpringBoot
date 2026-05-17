package com.esemsar.backend.dtos.responses;

import java.math.BigDecimal;

public record AdminStatisticsResponse(
    long totalUsers,
    long totalDrivers,
    long totalShippers,
    long totalOffers,
    long completedOffers,
    long canceledOffers,
    BigDecimal totalIncome,
    BigDecimal platformFees
) {
}
