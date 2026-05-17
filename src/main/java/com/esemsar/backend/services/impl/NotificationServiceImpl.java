package com.esemsar.backend.services.impl;

import com.esemsar.backend.dtos.responses.NotificationResponse;
import com.esemsar.backend.entities.Notification;
import com.esemsar.backend.entities.Offer;
import com.esemsar.backend.entities.User;
import com.esemsar.backend.enums.NotificationType;
import com.esemsar.backend.exceptions.ForbiddenException;
import com.esemsar.backend.exceptions.ResourceNotFoundException;
import com.esemsar.backend.mappers.NotificationMapper;
import com.esemsar.backend.repositories.NotificationRepository;
import com.esemsar.backend.services.NotificationService;
import com.esemsar.backend.services.UserService;
import com.esemsar.backend.services.WebSocketNotificationService;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class NotificationServiceImpl implements NotificationService {
    private final NotificationRepository notificationRepository;
    private final NotificationMapper notificationMapper;
    private final UserService userService;
    private final WebSocketNotificationService webSocketNotificationService;

    public NotificationServiceImpl(
        NotificationRepository notificationRepository,
        NotificationMapper notificationMapper,
        UserService userService,
        WebSocketNotificationService webSocketNotificationService
    ) {
        this.notificationRepository = notificationRepository;
        this.notificationMapper = notificationMapper;
        this.userService = userService;
        this.webSocketNotificationService = webSocketNotificationService;
    }

    @Override
    @Transactional
    public Notification create(User recipient, Offer offer, String title, String message, NotificationType type) {
        Notification notification = Notification.builder()
            .recipient(recipient)
            .offer(offer)
            .title(title)
            .message(message)
            .type(type)
            .seen(false)
            .build();
        Notification saved = notificationRepository.save(notification);
        webSocketNotificationService.push(saved);
        return saved;
    }

    @Override
    public Page<NotificationResponse> all(Pageable pageable) {
        return notificationRepository.findByRecipientIdOrderByCreatedAtDesc(userService.currentUser().getId(), pageable)
            .map(notificationMapper::toResponse);
    }

    @Override
    public List<NotificationResponse> unread() {
        return notificationRepository.findByRecipientIdAndSeenFalse(userService.currentUser().getId())
            .stream().map(notificationMapper::toResponse).toList();
    }

    @Override
    @Transactional
    public NotificationResponse markRead(Long id) {
        Notification notification = owned(id);
        notification.setSeen(true);
        return notificationMapper.toResponse(notificationRepository.save(notification));
    }

    @Override
    @Transactional
    public void markAllRead() {
        List<Notification> notifications = notificationRepository.findByRecipientIdAndSeenFalse(userService.currentUser().getId());
        notifications.forEach(notification -> notification.setSeen(true));
        notificationRepository.saveAll(notifications);
    }

    @Override
    public void delete(Long id) {
        notificationRepository.delete(owned(id));
    }

    private Notification owned(Long id) {
        User user = userService.currentUser();
        Notification notification = notificationRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Notification not found"));
        if (!notification.getRecipient().getId().equals(user.getId())) {
            throw new ForbiddenException("You can manage only your notifications");
        }
        return notification;
    }
}
