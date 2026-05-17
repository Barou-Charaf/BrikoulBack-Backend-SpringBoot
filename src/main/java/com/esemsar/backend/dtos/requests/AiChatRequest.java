package com.esemsar.backend.dtos.requests;

import jakarta.validation.constraints.NotBlank;

public record AiChatRequest(@NotBlank String message) {
}
