package com.esemsar.backend.websocket;

import com.esemsar.backend.enums.NotificationType;
import java.time.LocalDateTime;

public record NotificationMessage(
    Long id,
    String title,
    String message,
    NotificationType type,
    Long offerId,
    LocalDateTime createdAt
) {
}
