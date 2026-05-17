package com.esemsar.backend.ai;

import com.esemsar.backend.dtos.responses.AiExtractedFilters;
import com.esemsar.backend.enums.VehicleType;
import com.esemsar.backend.exceptions.AiServiceException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Component;

@Component
public class AiFilterExtractor {
    private final ObjectMapper objectMapper;

    public AiFilterExtractor(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    public AiExtractedFilters parse(String rawJson) {
        try {
            String json = stripCodeFences(rawJson);
            JsonNode node = objectMapper.readTree(json);
            return new AiExtractedFilters(
                text(node, "departureCity"),
                text(node, "arrivalCity"),
                vehicleType(text(node, "vehicleType")),
                number(node, "minCapacityKg"),
                number(node, "maxWeightKg")
            );
        } catch (Exception ex) {
            throw new AiServiceException("Could not parse AI filters", ex);
        }
    }

    private String text(JsonNode node, String field) {
        JsonNode value = node.get(field);
        if (value == null || value.isNull()) {
            return null;
        }
        String text = value.asText();
        return text == null || text.isBlank() ? null : text;
    }

    private Double number(JsonNode node, String field) {
        JsonNode value = node.get(field);
        return value == null || value.isNull() ? null : value.asDouble();
    }

    private VehicleType vehicleType(String value) {
        if (value == null) {
            return null;
        }
        try {
            return VehicleType.valueOf(value.trim().toUpperCase());
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }

    private String stripCodeFences(String raw) {
        return raw == null ? "{}" : raw.replace("```json", "").replace("```", "").trim();
    }
}
