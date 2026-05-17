package com.esemsar.backend.services.impl;

import com.esemsar.backend.entities.Notification;
import com.esemsar.backend.services.WebSocketNotificationService;
import com.esemsar.backend.websocket.NotificationMessage;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Service
public class WebSocketNotificationServiceImpl implements WebSocketNotificationService {
    private final SimpMessagingTemplate messagingTemplate;

    public WebSocketNotificationServiceImpl(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    @Override
    public void push(Notification notification) {
        NotificationMessage message = new NotificationMessage(
            notification.getId(),
            notification.getTitle(),
            notification.getMessage(),
            notification.getType(),
            notification.getOffer() == null ? null : notification.getOffer().getId(),
            notification.getCreatedAt()
        );
        messagingTemplate.convertAndSendToUser(
            notification.getRecipient().getEmail(),
            "/queue/notifications",
            message
        );
    }
}
