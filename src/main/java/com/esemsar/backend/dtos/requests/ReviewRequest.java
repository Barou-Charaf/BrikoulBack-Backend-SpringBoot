package com.esemsar.backend.dtos.requests;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record ReviewRequest(
    @NotNull Long offerId,
    @NotNull Long reviewedUserId,
    @Min(1) @Max(5) int rating,
    String comment
) {
}
