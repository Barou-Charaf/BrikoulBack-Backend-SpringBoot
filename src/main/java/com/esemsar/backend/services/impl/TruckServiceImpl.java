package com.esemsar.backend.services.impl;

import com.esemsar.backend.dtos.requests.TruckRequest;
import com.esemsar.backend.dtos.responses.TruckResponse;
import com.esemsar.backend.entities.DriverProfile;
import com.esemsar.backend.entities.Truck;
import com.esemsar.backend.exceptions.ForbiddenException;
import com.esemsar.backend.exceptions.ResourceNotFoundException;
import com.esemsar.backend.mappers.TruckMapper;
import com.esemsar.backend.repositories.TruckRepository;
import com.esemsar.backend.services.DriverService;
import com.esemsar.backend.services.TruckService;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class TruckServiceImpl implements TruckService {
    private final TruckRepository truckRepository;
    private final DriverService driverService;
    private final TruckMapper truckMapper;

    public TruckServiceImpl(TruckRepository truckRepository, DriverService driverService, TruckMapper truckMapper) {
        this.truckRepository = truckRepository;
        this.driverService = driverService;
        this.truckMapper = truckMapper;
    }

    @Override
    @Transactional
    public TruckResponse create(TruckRequest request) {
        DriverProfile driver = driverService.currentDriver();
        Truck truck = Truck.builder()
            .brand(request.brand())
            .model(request.model())
            .plateNumber(request.plateNumber())
            .vehicleType(request.vehicleType())
            .capacityKg(request.capacityKg())
            .active(Boolean.TRUE.equals(request.active()))
            .driverProfile(driver)
            .build();
        return truckMapper.toResponse(truckRepository.save(truck));
    }

    @Override
    public List<TruckResponse> myTrucks() {
        DriverProfile driver = driverService.currentDriver();
        return truckRepository.findByDriverProfileId(driver.getId()).stream().map(truckMapper::toResponse).toList();
    }

    @Override
    public TruckResponse get(Long id) {
        Truck truck = findOwned(id);
        return truckMapper.toResponse(truck);
    }

    @Override
    @Transactional
    public TruckResponse update(Long id, TruckRequest request) {
        Truck truck = findOwned(id);
        truck.setBrand(request.brand());
        truck.setModel(request.model());
        truck.setPlateNumber(request.plateNumber());
        truck.setVehicleType(request.vehicleType());
        truck.setCapacityKg(request.capacityKg());
        if (request.active() != null) {
            truck.setActive(request.active());
        }
        return truckMapper.toResponse(truckRepository.save(truck));
    }

    @Override
    public void delete(Long id) {
        truckRepository.delete(findOwned(id));
    }

    @Override
    @Transactional
    public TruckResponse setActive(Long id, boolean active) {
        Truck truck = findOwned(id);
        truck.setActive(active);
        return truckMapper.toResponse(truckRepository.save(truck));
    }

    private Truck findOwned(Long id) {
        DriverProfile driver = driverService.currentDriver();
        Truck truck = truckRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Truck not found"));
        if (!truck.getDriverProfile().getId().equals(driver.getId())) {
            throw new ForbiddenException("You can manage only your trucks");
        }
        return truck;
    }
}
