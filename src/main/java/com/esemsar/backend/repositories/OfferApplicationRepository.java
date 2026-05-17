package com.esemsar.backend.repositories;

import com.esemsar.backend.entities.OfferApplication;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OfferApplicationRepository extends JpaRepository<OfferApplication, Long> {
    boolean existsByOfferIdAndDriverProfileId(Long offerId, Long driverProfileId);

    List<OfferApplication> findByOfferId(Long offerId);

    Page<OfferApplication> findByDriverProfileId(Long driverProfileId, Pageable pageable);
}
