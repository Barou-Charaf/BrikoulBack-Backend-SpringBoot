package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.requests.AiChatRequest;
import com.esemsar.backend.dtos.responses.AiChatResponse;
import com.esemsar.backend.services.AiChatService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/ai")
public class AiChatController {
    private final AiChatService aiChatService;

    public AiChatController(AiChatService aiChatService) {
        this.aiChatService = aiChatService;
    }

    @PostMapping("/chat")
    public AiChatResponse chat(@Valid @RequestBody AiChatRequest request) {
        return aiChatService.chat(request);
    }

    @GetMapping("/history")
    public List<AiChatResponse> history() {
        return aiChatService.history();
    }

    @DeleteMapping("/history")
    public Map<String, String> clearHistory() {
        aiChatService.clearHistory();
        return Map.of("message", "AI history cleared");
    }
}
