package com.esemsar.backend.dtos.requests;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ResetPasswordRequest(@NotBlank String token, @Size(min = 8) @NotBlank String newPassword) {
}
