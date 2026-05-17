package com.esemsar.backend.services;

import com.esemsar.backend.dtos.responses.DriverProfileResponse;
import com.esemsar.backend.entities.DriverProfile;
import com.esemsar.backend.entities.Offer;
import java.util.List;

public interface MatchingService {
    List<DriverProfile> findBestDrivers(Offer offer);

    List<DriverProfileResponse> getMatchingDrivers(Long offerId);

    void notifyMatchingDrivers(Long offerId);
}
