package com.esemsar.backend.services;

import com.esemsar.backend.dtos.requests.OfferRequest;
import com.esemsar.backend.dtos.responses.OfferResponse;
import com.esemsar.backend.dtos.responses.OfferSummaryResponse;
import com.esemsar.backend.entities.Offer;
import com.esemsar.backend.enums.VehicleType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface OfferService {
    Offer getEntity(Long id);

    OfferResponse create(OfferRequest request);

    Page<OfferSummaryResponse> myOffers(Pageable pageable);

    OfferResponse get(Long id);

    OfferResponse update(Long id, OfferRequest request);

    void delete(Long id);

    OfferResponse cancel(Long id);

    OfferResponse start(Long id);

    OfferResponse complete(Long id);

    Page<OfferSummaryResponse> list(Pageable pageable);

    Page<OfferSummaryResponse> search(String departureCity, String arrivalCity, VehicleType vehicleType, Double maxWeightKg, Pageable pageable);

    Page<OfferSummaryResponse> available(Pageable pageable);
}
