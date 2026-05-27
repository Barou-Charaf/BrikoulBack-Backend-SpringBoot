package com.esemsar.backend.services;

import com.esemsar.backend.dtos.requests.TruckRequest;
import com.esemsar.backend.dtos.responses.TruckResponse;
import java.util.List;

public interface TruckService {
    TruckResponse create(TruckRequest request);

    List<TruckResponse> myTrucks();

    List<TruckResponse> byDriver(Long driverProfileId);

    TruckResponse get(Long id);

    TruckResponse update(Long id, TruckRequest request);

    void delete(Long id);

    TruckResponse setActive(Long id, boolean active);
}
