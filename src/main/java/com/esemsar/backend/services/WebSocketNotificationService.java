package com.esemsar.backend.services;

import com.esemsar.backend.entities.Notification;

public interface WebSocketNotificationService {
    void push(Notification notification);
}
