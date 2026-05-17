package com.esemsar.backend.repositories;

import com.esemsar.backend.entities.ShipperProfile;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ShipperProfileRepository extends JpaRepository<ShipperProfile, Long> {
    Optional<ShipperProfile> findByUserId(Long userId);
}
