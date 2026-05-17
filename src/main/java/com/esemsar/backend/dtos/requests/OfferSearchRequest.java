package com.esemsar.backend.dtos.requests;

import com.esemsar.backend.enums.VehicleType;

public record OfferSearchRequest(String departureCity, String arrivalCity, VehicleType vehicleType, Double maxWeightKg) {
}
