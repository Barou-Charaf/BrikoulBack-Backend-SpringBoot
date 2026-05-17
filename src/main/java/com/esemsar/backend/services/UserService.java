package com.esemsar.backend.services;

import com.esemsar.backend.dtos.requests.UpdateProfileRequest;
import com.esemsar.backend.dtos.responses.UserResponse;
import com.esemsar.backend.entities.User;

public interface UserService {
    User currentUser();

    User getUser(Long id);

    UserResponse updateCurrentUser(UpdateProfileRequest request);

    UserResponse currentUserResponse();
}
