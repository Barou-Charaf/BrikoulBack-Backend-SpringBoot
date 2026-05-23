package com.esemsar.backend.dtos.requests;

public record ShipperProfileRequest(
    String firstName,
    String lastName,
    String phone,
    String companyName,
    String address
) {
}
