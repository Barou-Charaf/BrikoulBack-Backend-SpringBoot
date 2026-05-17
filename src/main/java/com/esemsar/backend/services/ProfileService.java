package com.esemsar.backend.services;

import com.esemsar.backend.dtos.requests.UpdateProfileRequest;
import com.esemsar.backend.dtos.responses.UserResponse;

public interface ProfileService {
    UserResponse getProfile();

    UserResponse updateProfile(UpdateProfileRequest request);
}
