package com.esemsar.backend.services;

import com.esemsar.backend.entities.User;

public interface PasswordResetService {
    void createAndSendToken(User user);

    void resetPassword(String token, String newPassword);
}
