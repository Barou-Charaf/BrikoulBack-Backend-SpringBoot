package com.esemsar.backend.repositories;

import com.esemsar.backend.entities.Payment;
import java.math.BigDecimal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface PaymentRepository extends JpaRepository<Payment, Long> {
    boolean existsByOfferId(Long offerId);

    @Query("select coalesce(sum(p.amount), 0) from Payment p")
    BigDecimal sumAmount();

    @Query("select coalesce(sum(p.platformFee), 0) from Payment p")
    BigDecimal sumPlatformFee();
}
