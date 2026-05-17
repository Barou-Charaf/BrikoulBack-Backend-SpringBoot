package com.esemsar.backend.dtos.responses;

import com.esemsar.backend.enums.VehicleType;

public record AiExtractedFilters(
    String departureCity,
    String arrivalCity,
    VehicleType vehicleType,
    Double minCapacityKg,
    Double maxWeightKg
) {
}
