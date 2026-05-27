package com.esemsar.backend.dtos.responses;

import com.esemsar.backend.enums.VehicleType;
import java.time.LocalDateTime;

public record TruckResponse(
    Long id,
    String brand,
    String model,
    String imageUrl,
    String plateNumber,
    VehicleType vehicleType,
    Double capacityKg,
    boolean active,
    Long driverProfileId,
    LocalDateTime createdAt,
    LocalDateTime updatedAt
) {
}
