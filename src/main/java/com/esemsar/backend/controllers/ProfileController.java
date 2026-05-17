package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.requests.ChangePasswordRequest;
import com.esemsar.backend.dtos.requests.UpdateProfileRequest;
import com.esemsar.backend.dtos.responses.UserResponse;
import com.esemsar.backend.services.AuthService;
import com.esemsar.backend.services.ProfileService;
import jakarta.validation.Valid;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/profile")
public class ProfileController {
    private final ProfileService profileService;
    private final AuthService authService;

    public ProfileController(ProfileService profileService, AuthService authService) {
        this.profileService = profileService;
        this.authService = authService;
    }

    @GetMapping
    public UserResponse getProfile() {
        return profileService.getProfile();
    }

    @PutMapping
    public UserResponse updateProfile(@Valid @RequestBody UpdateProfileRequest request) {
        return profileService.updateProfile(request);
    }

    @PutMapping("/change-password")
    public Map<String, String> changePassword(@Valid @RequestBody ChangePasswordRequest request) {
        authService.changePassword(request);
        return Map.of("message", "Password changed successfully");
    }
}
