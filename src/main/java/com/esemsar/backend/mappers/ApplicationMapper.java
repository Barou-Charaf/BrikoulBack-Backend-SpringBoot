package com.esemsar.backend.mappers;

import com.esemsar.backend.dtos.responses.OfferApplicationResponse;
import com.esemsar.backend.entities.OfferApplication;
import org.springframework.stereotype.Component;

@Component
public class ApplicationMapper {
    private final OfferMapper offerMapper;
    private final DriverMapper driverMapper;

    public ApplicationMapper(OfferMapper offerMapper, DriverMapper driverMapper) {
        this.offerMapper = offerMapper;
        this.driverMapper = driverMapper;
    }

    public OfferApplicationResponse toResponse(OfferApplication application) {
        if (application == null) {
            return null;
        }
        return new OfferApplicationResponse(
            application.getId(),
            application.getMessage(),
            application.getProposedPrice(),
            application.getStatus(),
            offerMapper.toSummary(application.getOffer()),
            driverMapper.toResponse(application.getDriverProfile()),
            application.getCreatedAt(),
            application.getUpdatedAt()
        );
    }
}
