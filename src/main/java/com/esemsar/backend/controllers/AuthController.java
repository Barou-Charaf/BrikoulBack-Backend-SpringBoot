package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.requests.ChangePasswordRequest;
import com.esemsar.backend.dtos.requests.ForgotPasswordRequest;
import com.esemsar.backend.dtos.requests.LoginRequest;
import com.esemsar.backend.dtos.requests.RegisterRequest;
import com.esemsar.backend.dtos.requests.ResetPasswordRequest;
import com.esemsar.backend.dtos.requests.VerifyEmailRequest;
import com.esemsar.backend.dtos.responses.AuthResponse;
import com.esemsar.backend.dtos.responses.UserResponse;
import com.esemsar.backend.services.AuthService;
import jakarta.validation.Valid;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public UserResponse register(@Valid @RequestBody RegisterRequest request) {
        return authService.register(request);
    }

    @GetMapping("/verify-email")
    public Map<String, String> verifyEmail(@RequestParam String token) {
        authService.verifyEmail(token);
        return Map.of("message", "Email verified successfully");
    }

    @PostMapping("/verify-email")
    public Map<String, String> verifyEmailFromMobile(@Valid @RequestBody VerifyEmailRequest request) {
        authService.verifyEmail(request.token());
        return Map.of("message", "Email verified successfully");
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/forgot-password")
    public Map<String, String> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        authService.forgotPassword(request);
        return Map.of("message", "If the email exists, a reset link has been sent");
    }

    @PostMapping("/reset-password")
    public Map<String, String> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request);
        return Map.of("message", "Password reset successfully");
    }

    @PostMapping("/change-password")
    public Map<String, String> changePassword(@Valid @RequestBody ChangePasswordRequest request) {
        authService.changePassword(request);
        return Map.of("message", "Password changed successfully");
    }

    @GetMapping("/me")
    public UserResponse me() {
        return authService.me();
    }
}
