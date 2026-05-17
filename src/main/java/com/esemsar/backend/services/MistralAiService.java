package com.esemsar.backend.services;

import com.esemsar.backend.enums.Role;

public interface MistralAiService {
    String extractFilters(String userMessage, Role role);
}
