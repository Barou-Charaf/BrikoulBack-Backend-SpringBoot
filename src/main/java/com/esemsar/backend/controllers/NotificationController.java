package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.responses.NotificationResponse;
import com.esemsar.backend.services.NotificationService;
import java.util.List;
import java.util.Map;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {
    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping
    public Page<NotificationResponse> all(Pageable pageable) {
        return notificationService.all(pageable);
    }

    @GetMapping("/unread")
    public List<NotificationResponse> unread() {
        return notificationService.unread();
    }

    @PatchMapping("/{id}/read")
    public NotificationResponse read(@PathVariable Long id) {
        return notificationService.markRead(id);
    }

    @PatchMapping("/read-all")
    public Map<String, String> readAll() {
        notificationService.markAllRead();
        return Map.of("message", "Notifications marked as read");
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        notificationService.delete(id);
    }
}
