package com.esemsar.backend.dtos.requests;

import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;

public record OfferApplicationRequest(String message, @Positive BigDecimal proposedPrice) {
}
