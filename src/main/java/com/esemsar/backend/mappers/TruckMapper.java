package com.esemsar.backend.mappers;

import com.esemsar.backend.dtos.responses.TruckResponse;
import com.esemsar.backend.entities.Truck;
import org.springframework.stereotype.Component;

@Component
public class TruckMapper {
    public TruckResponse toResponse(Truck truck) {
        if (truck == null) {
            return null;
        }
        return new TruckResponse(
            truck.getId(),
            truck.getBrand(),
            truck.getModel(),
            truck.getPlateNumber(),
            truck.getVehicleType(),
            truck.getCapacityKg(),
            truck.isActive(),
            truck.getDriverProfile() == null ? null : truck.getDriverProfile().getId(),
            truck.getCreatedAt(),
            truck.getUpdatedAt()
        );
    }
}
