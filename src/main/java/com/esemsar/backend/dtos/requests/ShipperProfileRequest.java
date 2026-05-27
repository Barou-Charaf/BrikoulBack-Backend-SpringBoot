package com.esemsar.backend.dtos.requests;

public record ShipperProfileRequest(
    String firstName,
    String lastName,
    String phone,
    String profileImageUrl,
    String companyName,
    String address
) {
}
