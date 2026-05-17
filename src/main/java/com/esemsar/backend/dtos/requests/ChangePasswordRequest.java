package com.esemsar.backend.dtos.requests;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ChangePasswordRequest(@NotBlank String oldPassword, @Size(min = 8) @NotBlank String newPassword) {
}
