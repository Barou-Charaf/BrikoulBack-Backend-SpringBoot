package com.esemsar.backend.repositories;

import com.esemsar.backend.entities.DriverProfile;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface DriverProfileRepository extends JpaRepository<DriverProfile, Long> {
    Optional<DriverProfile> findByUserId(Long userId);

    @Query("""
        select distinct d from DriverProfile d
        left join d.trucks t
        where (:city is null or lower(d.currentCity) = lower(:city))
          and (:vehicleType is null or t.vehicleType = :vehicleType)
          and (:minCapacityKg is null or t.capacityKg >= :minCapacityKg)
          and (:vehicleType is null or t.active = true)
        """)
    Page<DriverProfile> search(@Param("city") String city,
                               @Param("vehicleType") com.esemsar.backend.enums.VehicleType vehicleType,
                               @Param("minCapacityKg") Double minCapacityKg,
                               Pageable pageable);

    long countByAvailableTrue();
}
