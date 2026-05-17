package com.esemsar.backend.mappers;

import com.esemsar.backend.dtos.responses.NotificationResponse;
import com.esemsar.backend.entities.Notification;
import org.springframework.stereotype.Component;

@Component
public class NotificationMapper {
    public NotificationResponse toResponse(Notification notification) {
        if (notification == null) {
            return null;
        }
        return new NotificationResponse(
            notification.getId(),
            notification.getTitle(),
            notification.getMessage(),
            notification.getType(),
            notification.isSeen(),
            notification.getOffer() == null ? null : notification.getOffer().getId(),
            notification.getCreatedAt()
        );
    }
}
