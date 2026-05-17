package com.esemsar.backend.ai;

import com.esemsar.backend.enums.Role;
import org.springframework.stereotype.Component;

@Component
public class AiPromptBuilder {
    public String systemPrompt() {
        return """
            You are an assistant for a transport marketplace called Esemsar.
            Your job is to extract search filters from the user's message.
            If the user is a SHIPPER, extract filters to search for drivers.
            If the user is a DRIVER, extract filters to search for transport offers.
            Return only valid JSON.
            Do not invent cities, prices, capacities, or vehicle types.
            If a field is missing, return null.
            """;
    }

    public String userPrompt(String userMessage, Role role) {
        return """
            Role: %s
            Expected JSON fields:
            {
              "departureCity": null,
              "arrivalCity": null,
              "vehicleType": null,
              "minCapacityKg": null,
              "maxWeightKg": null
            }
            Message: %s
            """.formatted(role.name(), userMessage);
    }
}
