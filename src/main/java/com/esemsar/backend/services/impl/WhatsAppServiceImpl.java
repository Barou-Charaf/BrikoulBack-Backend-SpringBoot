package com.esemsar.backend.services.impl;

import com.esemsar.backend.dtos.responses.WhatsAppContactResponse;
import com.esemsar.backend.entities.DriverProfile;
import com.esemsar.backend.entities.Offer;
import com.esemsar.backend.exceptions.ResourceNotFoundException;
import com.esemsar.backend.repositories.DriverProfileRepository;
import com.esemsar.backend.repositories.OfferRepository;
import com.esemsar.backend.services.WhatsAppService;
import org.springframework.stereotype.Service;

@Service
public class WhatsAppServiceImpl implements WhatsAppService {
    private final DriverProfileRepository driverRepository;
    private final OfferRepository offerRepository;

    public WhatsAppServiceImpl(DriverProfileRepository driverRepository, OfferRepository offerRepository) {
        this.driverRepository = driverRepository;
        this.offerRepository = offerRepository;
    }

    @Override
    public WhatsAppContactResponse contactDriver(Long driverId) {
        DriverProfile driver = driverRepository.findById(driverId)
            .orElseThrow(() -> new ResourceNotFoundException("Driver profile not found"));
        return response(driver.getUser().getPhone());
    }

    @Override
    public WhatsAppContactResponse contactShipper(Long offerId) {
        Offer offer = offerRepository.findById(offerId)
            .orElseThrow(() -> new ResourceNotFoundException("Offer not found"));
        return response(offer.getShipperProfile().getUser().getPhone());
    }

    private WhatsAppContactResponse response(String phone) {
        String normalized = phone == null ? "" : phone.replaceAll("[^0-9]", "");
        return new WhatsAppContactResponse(phone, "https://wa.me/" + normalized);
    }
}
