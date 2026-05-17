package com.esemsar.backend.repositories;

import com.esemsar.backend.entities.Truck;
import com.esemsar.backend.enums.VehicleType;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TruckRepository extends JpaRepository<Truck, Long> {
    List<Truck> findByDriverProfileId(Long driverProfileId);

    boolean existsByDriverProfileIdAndActiveTrueAndVehicleTypeAndCapacityKgGreaterThanEqual(
        Long driverProfileId,
        VehicleType vehicleType,
        Double capacityKg
    );
}
