package com.esemsar.backend.dtos.responses;

import java.time.LocalDateTime;

public record ShipperProfileResponse(
    Long id,
    UserResponse user,
    String companyName,
    String address,
    double averageRating,
    int completedOffers,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {
}
