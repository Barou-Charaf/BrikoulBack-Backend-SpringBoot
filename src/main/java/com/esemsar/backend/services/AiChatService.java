package com.esemsar.backend.services;

import com.esemsar.backend.dtos.requests.AiChatRequest;
import com.esemsar.backend.dtos.responses.AiChatResponse;
import java.util.List;

public interface AiChatService {
    AiChatResponse chat(AiChatRequest request);

    List<AiChatResponse> history();

    void clearHistory();
}
