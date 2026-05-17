package com.esemsar.backend.services.impl;

import com.esemsar.backend.dtos.requests.ChangePasswordRequest;
import com.esemsar.backend.dtos.requests.ForgotPasswordRequest;
import com.esemsar.backend.dtos.requests.LoginRequest;
import com.esemsar.backend.dtos.requests.RegisterRequest;
import com.esemsar.backend.dtos.requests.ResetPasswordRequest;
import com.esemsar.backend.dtos.responses.AuthResponse;
import com.esemsar.backend.dtos.responses.UserResponse;
import com.esemsar.backend.entities.DriverProfile;
import com.esemsar.backend.entities.ShipperProfile;
import com.esemsar.backend.entities.User;
import com.esemsar.backend.enums.Role;
import com.esemsar.backend.exceptions.BadRequestException;
import com.esemsar.backend.exceptions.EmailAlreadyExistsException;
import com.esemsar.backend.exceptions.ResourceNotFoundException;
import com.esemsar.backend.exceptions.UnauthorizedException;
import com.esemsar.backend.mappers.UserMapper;
import com.esemsar.backend.repositories.UserRepository;
import com.esemsar.backend.services.AuthService;
import com.esemsar.backend.services.EmailVerificationService;
import com.esemsar.backend.services.JwtService;
import com.esemsar.backend.services.PasswordResetService;
import com.esemsar.backend.services.UserService;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthServiceImpl implements AuthService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final EmailVerificationService emailVerificationService;
    private final PasswordResetService passwordResetService;
    private final UserService userService;
    private final UserMapper userMapper;

    public AuthServiceImpl(
        UserRepository userRepository,
        PasswordEncoder passwordEncoder,
        AuthenticationManager authenticationManager,
        JwtService jwtService,
        EmailVerificationService emailVerificationService,
        PasswordResetService passwordResetService,
        UserService userService,
        UserMapper userMapper
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
        this.emailVerificationService = emailVerificationService;
        this.passwordResetService = passwordResetService;
        this.userService = userService;
        this.userMapper = userMapper;
    }

    @Override
    @Transactional
    public UserResponse register(RegisterRequest request) {
        if (request.role() != Role.SHIPPER && request.role() != Role.DRIVER) {
            throw new BadRequestException("Only SHIPPER or DRIVER can self-register");
        }
        if (userRepository.existsByEmail(request.email())) {
            throw new EmailAlreadyExistsException("Email already exists");
        }
        User user = User.builder()
            .firstName(request.firstName())
            .lastName(request.lastName())
            .email(request.email().toLowerCase())
            .password(passwordEncoder.encode(request.password()))
            .phone(request.phone())
            .role(request.role())
            .enabled(false)
            .emailVerified(false)
            .accountLocked(false)
            .build();
        if (request.role() == Role.DRIVER) {
            DriverProfile profile = DriverProfile.builder().user(user).available(false).build();
            user.setDriverProfile(profile);
        } else {
            ShipperProfile profile = ShipperProfile.builder().user(user).build();
            user.setShipperProfile(profile);
        }
        User saved = userRepository.save(user);
        emailVerificationService.createAndSendToken(saved);
        return userMapper.toResponse(saved);
    }

    @Override
    public void verifyEmail(String token) {
        emailVerificationService.verify(token);
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.email().toLowerCase())
            .orElseThrow(() -> new UnauthorizedException("Invalid email or password"));
        if (!user.isEmailVerified() || !user.isEnabled()) {
            throw new UnauthorizedException("Email must be verified before login");
        }
        if (user.isAccountLocked()) {
            throw new UnauthorizedException("Account is locked");
        }
        authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(request.email().toLowerCase(), request.password()));
        return new AuthResponse(jwtService.generateToken(user), "Bearer", userMapper.toResponse(user));
    }

    @Override
    public void forgotPassword(ForgotPasswordRequest request) {
        userRepository.findByEmail(request.email().toLowerCase())
            .ifPresent(passwordResetService::createAndSendToken);
    }

    @Override
    public void resetPassword(ResetPasswordRequest request) {
        passwordResetService.resetPassword(request.token(), request.newPassword());
    }

    @Override
    @Transactional
    public void changePassword(ChangePasswordRequest request) {
        User user = userService.currentUser();
        if (!passwordEncoder.matches(request.oldPassword(), user.getPassword())) {
            throw new BadRequestException("Old password is incorrect");
        }
        user.setPassword(passwordEncoder.encode(request.newPassword()));
        userRepository.save(user);
    }

    @Override
    public UserResponse me() {
        return userMapper.toResponse(userService.currentUser());
    }
}
