package com.esemsar.backend.mappers;

import com.esemsar.backend.dtos.responses.OfferResponse;
import com.esemsar.backend.dtos.responses.OfferSummaryResponse;
import com.esemsar.backend.entities.Offer;
import org.springframework.stereotype.Component;

@Component
public class OfferMapper {
    private final ShipperMapper shipperMapper;
    private final DriverMapper driverMapper;

    public OfferMapper(ShipperMapper shipperMapper, DriverMapper driverMapper) {
        this.shipperMapper = shipperMapper;
        this.driverMapper = driverMapper;
    }

    public OfferResponse toResponse(Offer offer) {
        if (offer == null) {
            return null;
        }
        return new OfferResponse(
            offer.getId(),
            offer.getTitle(),
            offer.getDescription(),
            offer.getDepartureCity(),
            offer.getArrivalCity(),
            offer.getPickupAddress(),
            offer.getDeliveryAddress(),
            offer.getGoodsType(),
            offer.getWeightKg(),
            offer.getRequiredVehicleType(),
            offer.getProposedPrice(),
            offer.getMaxDriversToNotify(),
            offer.getStatus(),
            offer.getTransportDate(),
            shipperMapper.toResponse(offer.getShipperProfile()),
            driverMapper.toResponse(offer.getAssignedDriver()),
            offer.getCreatedAt(),
            offer.getUpdatedAt()
        );
    }

    public OfferSummaryResponse toSummary(Offer offer) {
        if (offer == null) {
            return null;
        }
        return new OfferSummaryResponse(
            offer.getId(),
            offer.getTitle(),
            offer.getDepartureCity(),
            offer.getArrivalCity(),
            offer.getGoodsType(),
            offer.getWeightKg(),
            offer.getRequiredVehicleType(),
            offer.getProposedPrice(),
            offer.getStatus(),
            offer.getTransportDate()
        );
    }
}
