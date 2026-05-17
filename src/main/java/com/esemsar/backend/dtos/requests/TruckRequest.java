package com.esemsar.backend.dtos.requests;

import com.esemsar.backend.enums.VehicleType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record TruckRequest(
    String brand,
    String model,
    @NotBlank String plateNumber,
    @NotNull VehicleType vehicleType,
    @Positive Double capacityKg,
    Boolean active
) {
}
