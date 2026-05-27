package com.esemsar.backend.services.impl;

import com.esemsar.backend.entities.PasswordResetToken;
import com.esemsar.backend.entities.User;
import com.esemsar.backend.exceptions.InvalidTokenException;
import com.esemsar.backend.repositories.PasswordResetTokenRepository;
import com.esemsar.backend.repositories.UserRepository;
import com.esemsar.backend.services.PasswordResetService;
import java.time.LocalDateTime;
import java.util.concurrent.ThreadLocalRandom;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Slf4j
public class PasswordResetServiceImpl implements PasswordResetService {
    private final PasswordResetTokenRepository tokenRepository;
    private final UserRepository userRepository;
    private final JavaMailSender mailSender;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.frontend.url}")
    private String frontendUrl;

    public PasswordResetServiceImpl(
        PasswordResetTokenRepository tokenRepository,
        UserRepository userRepository,
        JavaMailSender mailSender,
        PasswordEncoder passwordEncoder
    ) {
        this.tokenRepository = tokenRepository;
        this.userRepository = userRepository;
        this.mailSender = mailSender;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public void createAndSendToken(User user) {
        PasswordResetToken token = PasswordResetToken.builder()
            .token(generateSixDigitCode())
            .expiresAt(LocalDateTime.now().plusHours(1))
            .user(user)
            .build();
        tokenRepository.save(token);
        log.info("Password reset token for {}: {}", user.getEmail(), token.getToken());
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(user.getEmail());
        message.setSubject("Reset your E-Samsar password");
        message.setText("Your E-Samsar password reset code is: " + token.getToken()
            + "\n\nSwagger test link: " + frontendUrl + "/reset-password?token=" + token.getToken()
            + "\nMobile app request: POST /api/auth/reset-password with the code and your new password.");
        try {
            mailSender.send(message);
        } catch (RuntimeException ex) {
            log.warn("Password reset email could not be sent to {}. Keeping token valid for local testing.", user.getEmail(), ex);
        }
    }

    private String generateSixDigitCode() {
        return String.format("%06d", ThreadLocalRandom.current().nextInt(1_000_000));
    }

    @Override
    @Transactional
    public void resetPassword(String rawToken, String newPassword) {
        PasswordResetToken token = tokenRepository.findByToken(rawToken)
            .orElseThrow(() -> new InvalidTokenException("Invalid reset token"));
        if (token.isUsed() || token.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new InvalidTokenException("Reset token is expired or already used");
        }
        User user = token.getUser();
        user.setPassword(passwordEncoder.encode(newPassword));
        token.setUsed(true);
        userRepository.save(user);
        tokenRepository.save(token);
    }
}
