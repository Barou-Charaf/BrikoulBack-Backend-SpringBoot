package com.esemsar.backend.services.impl;

import com.esemsar.backend.dtos.requests.UpdateProfileRequest;
import com.esemsar.backend.dtos.responses.UserResponse;
import com.esemsar.backend.services.ProfileService;
import com.esemsar.backend.services.UserService;
import org.springframework.stereotype.Service;

@Service
public class ProfileServiceImpl implements ProfileService {
    private final UserService userService;

    public ProfileServiceImpl(UserService userService) {
        this.userService = userService;
    }

    @Override
    public UserResponse getProfile() {
        return userService.currentUserResponse();
    }

    @Override
    public UserResponse updateProfile(UpdateProfileRequest request) {
        return userService.updateCurrentUser(request);
    }
}
