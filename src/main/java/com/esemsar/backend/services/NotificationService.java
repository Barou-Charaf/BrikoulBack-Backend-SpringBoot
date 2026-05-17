package com.esemsar.backend.services;

import com.esemsar.backend.dtos.responses.NotificationResponse;
import com.esemsar.backend.entities.Notification;
import com.esemsar.backend.entities.Offer;
import com.esemsar.backend.entities.User;
import com.esemsar.backend.enums.NotificationType;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface NotificationService {
    Notification create(User recipient, Offer offer, String title, String message, NotificationType type);

    Page<NotificationResponse> all(Pageable pageable);

    List<NotificationResponse> unread();

    NotificationResponse markRead(Long id);

    void markAllRead();

    void delete(Long id);
}
