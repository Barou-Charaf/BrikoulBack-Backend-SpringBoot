package com.esemsar.backend.dtos.requests;

public record DriverProfileRequest(
    String firstName,
    String lastName,
    String phone,
    String profileImageUrl,
    String currentCity,
    Boolean available
) {
}
