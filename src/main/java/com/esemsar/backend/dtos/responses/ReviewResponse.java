package com.esemsar.backend.dtos.responses;

import java.time.LocalDateTime;

public record ReviewResponse(
    Long id,
    int rating,
    String comment,
    UserResponse reviewer,
    UserResponse reviewedUser,
    Long offerId,
    LocalDateTime createdAt
) {
}
