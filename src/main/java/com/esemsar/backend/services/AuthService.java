package com.esemsar.backend.services;

import com.esemsar.backend.dtos.requests.ChangePasswordRequest;
import com.esemsar.backend.dtos.requests.ForgotPasswordRequest;
import com.esemsar.backend.dtos.requests.LoginRequest;
import com.esemsar.backend.dtos.requests.RegisterRequest;
import com.esemsar.backend.dtos.requests.ResetPasswordRequest;
import com.esemsar.backend.dtos.responses.AuthResponse;
import com.esemsar.backend.dtos.responses.UserResponse;

public interface AuthService {
    UserResponse register(RegisterRequest request);

    void verifyEmail(String token);

    AuthResponse login(LoginRequest request);

    void forgotPassword(ForgotPasswordRequest request);

    void resetPassword(ResetPasswordRequest request);

    void changePassword(ChangePasswordRequest request);

    UserResponse me();
}
