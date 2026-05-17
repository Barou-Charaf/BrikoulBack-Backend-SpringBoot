package com.esemsar.backend.repositories;

import com.esemsar.backend.entities.Offer;
import com.esemsar.backend.enums.OfferStatus;
import com.esemsar.backend.enums.VehicleType;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface OfferRepository extends JpaRepository<Offer, Long> {
    Page<Offer> findByShipperProfileId(Long shipperProfileId, Pageable pageable);

    Page<Offer> findByStatusIn(List<OfferStatus> statuses, Pageable pageable);

    long countByStatus(OfferStatus status);

    @Query("""
        select o from Offer o
        where (:departureCity is null or lower(o.departureCity) = lower(:departureCity))
          and (:arrivalCity is null or lower(o.arrivalCity) = lower(:arrivalCity))
          and (:vehicleType is null or o.requiredVehicleType = :vehicleType)
          and (:maxWeightKg is null or o.weightKg <= :maxWeightKg)
          and o.status in :statuses
        """)
    Page<Offer> search(@Param("departureCity") String departureCity,
                       @Param("arrivalCity") String arrivalCity,
                       @Param("vehicleType") VehicleType vehicleType,
                       @Param("maxWeightKg") Double maxWeightKg,
                       @Param("statuses") List<OfferStatus> statuses,
                       Pageable pageable);
}
