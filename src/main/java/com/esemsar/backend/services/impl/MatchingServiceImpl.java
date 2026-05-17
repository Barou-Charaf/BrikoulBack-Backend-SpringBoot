package com.esemsar.backend.services.impl;

import com.esemsar.backend.dtos.responses.DriverProfileResponse;
import com.esemsar.backend.entities.DriverProfile;
import com.esemsar.backend.entities.Offer;
import com.esemsar.backend.entities.Truck;
import com.esemsar.backend.enums.NotificationType;
import com.esemsar.backend.enums.OfferStatus;
import com.esemsar.backend.exceptions.ResourceNotFoundException;
import com.esemsar.backend.mappers.DriverMapper;
import com.esemsar.backend.repositories.DriverProfileRepository;
import com.esemsar.backend.repositories.OfferRepository;
import com.esemsar.backend.services.MatchingService;
import com.esemsar.backend.services.NotificationService;
import java.util.Comparator;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MatchingServiceImpl implements MatchingService {
    private final OfferRepository offerRepository;
    private final DriverProfileRepository driverRepository;
    private final DriverMapper driverMapper;
    private final NotificationService notificationService;

    public MatchingServiceImpl(
        OfferRepository offerRepository,
        DriverProfileRepository driverRepository,
        DriverMapper driverMapper,
        NotificationService notificationService
    ) {
        this.offerRepository = offerRepository;
        this.driverRepository = driverRepository;
        this.driverMapper = driverMapper;
        this.notificationService = notificationService;
    }

    @Override
    public List<DriverProfile> findBestDrivers(Offer offer) {
        int limit = offer.getMaxDriversToNotify() == null ? 10 : offer.getMaxDriversToNotify();
        return driverRepository.findAll().stream()
            .filter(DriverProfile::isAvailable)
            .filter(driver -> hasCompatibleTruck(driver, offer))
            .sorted(Comparator.comparingDouble((DriverProfile driver) -> score(driver, offer)).reversed())
            .limit(limit)
            .toList();
    }

    @Override
    public List<DriverProfileResponse> getMatchingDrivers(Long offerId) {
        Offer offer = offerRepository.findById(offerId)
            .orElseThrow(() -> new ResourceNotFoundException("Offer not found"));
        return findBestDrivers(offer).stream().map(driverMapper::toResponse).toList();
    }

    @Override
    @Transactional
    public void notifyMatchingDrivers(Long offerId) {
        Offer offer = offerRepository.findById(offerId)
            .orElseThrow(() -> new ResourceNotFoundException("Offer not found"));
        List<DriverProfile> drivers = findBestDrivers(offer);
        for (DriverProfile driver : drivers) {
            notificationService.create(
                driver.getUser(),
                offer,
                "New matching transport offer",
                "A new offer from " + offer.getDepartureCity() + " to " + offer.getArrivalCity() + " matches your truck.",
                NotificationType.NEW_MATCHING_OFFER
            );
        }
        if (!drivers.isEmpty() && offer.getStatus() == OfferStatus.PENDING) {
            offer.setStatus(OfferStatus.NOTIFIED);
            offerRepository.save(offer);
        }
    }

    private boolean hasCompatibleTruck(DriverProfile driver, Offer offer) {
        return driver.getTrucks().stream().anyMatch(truck ->
            truck.isActive()
                && truck.getVehicleType() == offer.getRequiredVehicleType()
                && truck.getCapacityKg() != null
                && offer.getWeightKg() != null
                && truck.getCapacityKg() >= offer.getWeightKg());
    }

    private double score(DriverProfile driver, Offer offer) {
        double score = 0;
        if (driver.getCurrentCity() != null && driver.getCurrentCity().equalsIgnoreCase(offer.getDepartureCity())) {
            score += 50;
        }
        double bestCapacityMargin = driver.getTrucks().stream()
            .filter(Truck::isActive)
            .filter(truck -> truck.getVehicleType() == offer.getRequiredVehicleType())
            .filter(truck -> truck.getCapacityKg() != null && offer.getWeightKg() != null && truck.getCapacityKg() >= offer.getWeightKg())
            .mapToDouble(truck -> truck.getCapacityKg() - offer.getWeightKg())
            .min()
            .orElse(10000);
        score += Math.max(0, 25 - (bestCapacityMargin / 100));
        score += driver.getAverageRating() * 10;
        score += Math.min(driver.getCompletedJobs(), 100) * 0.5;
        return score;
    }
}
