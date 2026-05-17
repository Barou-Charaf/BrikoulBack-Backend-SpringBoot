package com.esemsar.backend.services.impl;

import com.esemsar.backend.dtos.requests.UpdateProfileRequest;
import com.esemsar.backend.dtos.responses.UserResponse;
import com.esemsar.backend.entities.User;
import com.esemsar.backend.exceptions.ResourceNotFoundException;
import com.esemsar.backend.exceptions.UnauthorizedException;
import com.esemsar.backend.mappers.UserMapper;
import com.esemsar.backend.repositories.UserRepository;
import com.esemsar.backend.security.UserPrincipal;
import com.esemsar.backend.services.UserService;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    private final UserMapper userMapper;

    public UserServiceImpl(UserRepository userRepository, UserMapper userMapper) {
        this.userRepository = userRepository;
        this.userMapper = userMapper;
    }

    @Override
    public User currentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof UserPrincipal principal)) {
            throw new UnauthorizedException("Authentication required");
        }
        return getUser(principal.getId());
    }

    @Override
    public User getUser(Long id) {
        return userRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    @Override
    @Transactional
    public UserResponse updateCurrentUser(UpdateProfileRequest request) {
        User user = currentUser();
        user.setFirstName(request.firstName());
        user.setLastName(request.lastName());
        user.setPhone(request.phone());
        return userMapper.toResponse(userRepository.save(user));
    }

    @Override
    public UserResponse currentUserResponse() {
        return userMapper.toResponse(currentUser());
    }
}
