package com.esemsar.backend.dtos.responses;

import com.esemsar.backend.enums.Role;
import java.time.LocalDateTime;

public record UserResponse(
    Long id,
    String firstName,
    String lastName,
    String email,
    String phone,
    Role role,
    boolean enabled,
    boolean emailVerified,
    boolean accountLocked,
    LocalDateTime createdAt
) {
}
