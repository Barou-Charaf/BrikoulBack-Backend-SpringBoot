package com.esemsar.backend.dtos.responses;

import java.time.LocalDateTime;

public record DriverProfileResponse(
    Long id,
    UserResponse user,
    String currentCity,
    boolean available,
    double averageRating,
    int completedJobs,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {
}
