package com.esemsar.backend.mappers;

import com.esemsar.backend.dtos.responses.AdminUserResponse;
import com.esemsar.backend.dtos.responses.UserResponse;
import com.esemsar.backend.entities.User;
import org.springframework.stereotype.Component;

@Component
public class UserMapper {
    public UserResponse toResponse(User user) {
        if (user == null) {
            return null;
        }
        return new UserResponse(
            user.getId(),
            user.getFirstName(),
            user.getLastName(),
            user.getEmail(),
            user.getPhone(),
            user.getRole(),
            user.isEnabled(),
            user.isEmailVerified(),
            user.isAccountLocked(),
            user.getCreatedAt()
        );
    }

    public AdminUserResponse toAdminResponse(User user) {
        if (user == null) {
            return null;
        }
        return new AdminUserResponse(
            user.getId(),
            user.getFirstName(),
            user.getLastName(),
            user.getEmail(),
            user.getPhone(),
            user.getRole(),
            user.isEnabled(),
            user.isEmailVerified(),
            user.isAccountLocked(),
            user.getCreatedAt(),
            user.getUpdatedAt()
        );
    }
}
