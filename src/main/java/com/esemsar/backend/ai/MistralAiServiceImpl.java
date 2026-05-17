package com.esemsar.backend.ai;

import com.esemsar.backend.enums.Role;
import com.esemsar.backend.exceptions.AiServiceException;
import com.esemsar.backend.services.MistralAiService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class MistralAiServiceImpl implements MistralAiService {
    private final ObjectMapper objectMapper;
    private final AiPromptBuilder promptBuilder;
    private final HttpClient httpClient = HttpClient.newHttpClient();

    @Value("${app.mistral.api-key}")
    private String apiKey;

    @Value("${app.mistral.model}")
    private String model;

    public MistralAiServiceImpl(ObjectMapper objectMapper, AiPromptBuilder promptBuilder) {
        this.objectMapper = objectMapper;
        this.promptBuilder = promptBuilder;
    }

    @Override
    public String extractFilters(String userMessage, Role role) {
        if (apiKey == null || apiKey.isBlank()) {
            throw new AiServiceException("MISTRAL_API_KEY is not configured");
        }
        try {
            Map<String, Object> payload = Map.of(
                "model", model,
                "temperature", 0,
                "messages", List.of(
                    Map.of("role", "system", "content", promptBuilder.systemPrompt()),
                    Map.of("role", "user", "content", promptBuilder.userPrompt(userMessage, role))
                )
            );
            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://api.mistral.ai/v1/chat/completions"))
                .header("Authorization", "Bearer " + apiKey)
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(objectMapper.writeValueAsString(payload)))
                .build();
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() >= 400) {
                throw new AiServiceException("Mistral API error: HTTP " + response.statusCode());
            }
            JsonNode root = objectMapper.readTree(response.body());
            return root.path("choices").path(0).path("message").path("content").asText("{}");
        } catch (AiServiceException ex) {
            throw ex;
        } catch (Exception ex) {
            throw new AiServiceException("Mistral API call failed", ex);
        }
    }
}
