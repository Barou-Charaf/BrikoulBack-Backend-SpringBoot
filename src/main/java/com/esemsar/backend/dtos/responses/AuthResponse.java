package com.esemsar.backend.dtos.responses;

public record AuthResponse(String accessToken, String tokenType, UserResponse user) {
}
