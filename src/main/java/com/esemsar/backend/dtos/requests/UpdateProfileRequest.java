package com.esemsar.backend.dtos.requests;

import jakarta.validation.constraints.NotBlank;

public record UpdateProfileRequest(
    @NotBlank String firstName,
    @NotBlank String lastName,
    @NotBlank String phone,
    String profileImageUrl
) {
}
