package com.esemsar.backend.dtos.responses;

import com.esemsar.backend.enums.NotificationType;
import java.time.LocalDateTime;

public record NotificationResponse(
    Long id,
    String title,
    String message,
    NotificationType type,
    boolean seen,
    Long offerId,
    LocalDateTime createdAt
) {
}
