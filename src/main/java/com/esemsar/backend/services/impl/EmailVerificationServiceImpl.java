package com.esemsar.backend.services.impl;

import com.esemsar.backend.entities.EmailVerificationToken;
import com.esemsar.backend.entities.User;
import com.esemsar.backend.exceptions.InvalidTokenException;
import com.esemsar.backend.repositories.EmailVerificationTokenRepository;
import com.esemsar.backend.repositories.UserRepository;
import com.esemsar.backend.services.EmailVerificationService;
import java.time.LocalDateTime;
import java.util.concurrent.ThreadLocalRandom;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Slf4j
public class EmailVerificationServiceImpl implements EmailVerificationService {
    private final EmailVerificationTokenRepository tokenRepository;
    private final UserRepository userRepository;
    private final JavaMailSender mailSender;

    @Value("${app.frontend.url}")
    private String frontendUrl;

    @Value("${app.email-verification.url-template}")
    private String verificationUrlTemplate;

    public EmailVerificationServiceImpl(
        EmailVerificationTokenRepository tokenRepository,
        UserRepository userRepository,
        JavaMailSender mailSender
    ) {
        this.tokenRepository = tokenRepository;
        this.userRepository = userRepository;
        this.mailSender = mailSender;
    }

    @Override
    @Transactional
    public void createAndSendToken(User user) {
        EmailVerificationToken token = EmailVerificationToken.builder()
            .token(generateSixDigitCode())
            .expiresAt(LocalDateTime.now().plusHours(24))
            .user(user)
            .build();
        tokenRepository.save(token);
        log.info("Email verification token for {}: {}", user.getEmail(), token.getToken());
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(user.getEmail());
        message.setSubject("Verify your E-Samsar account");
        String verificationUrl = verificationUrlTemplate.replace("{token}", token.getToken());
        message.setText("Your E-Samsar verification code is: " + token.getToken()
            + "\n\nSwagger test link: " + verificationUrl
            + "\nMobile app request: POST /api/auth/verify-email with {\"token\":\"" + token.getToken() + "\"}.");
        try {
            mailSender.send(message);
        } catch (RuntimeException ex) {
            log.warn("Verification email could not be sent to {}. Keeping token valid for local testing.", user.getEmail(), ex);
        }
    }

    private String generateSixDigitCode() {
        return String.format("%06d", ThreadLocalRandom.current().nextInt(1_000_000));
    }

    @Override
    @Transactional
    public void verify(String rawToken) {
        EmailVerificationToken token = tokenRepository.findByToken(rawToken)
            .orElseThrow(() -> new InvalidTokenException("Invalid verification token"));
        if (token.isUsed() || token.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new InvalidTokenException("Verification token is expired or already used");
        }
        User user = token.getUser();
        user.setEmailVerified(true);
        user.setEnabled(true);
        token.setUsed(true);
        userRepository.save(user);
        tokenRepository.save(token);
    }
}
