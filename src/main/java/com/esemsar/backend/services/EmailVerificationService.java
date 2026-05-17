package com.esemsar.backend.services;

import com.esemsar.backend.entities.User;

public interface EmailVerificationService {
    void createAndSendToken(User user);

    void verify(String token);
}
