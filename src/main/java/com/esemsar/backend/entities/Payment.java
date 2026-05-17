package com.esemsar.backend.entities;

import com.esemsar.backend.enums.PaymentMethod;
import com.esemsar.backend.enums.PaymentStatus;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import jakarta.persistence.PrePersist;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Payment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private BigDecimal amount;
    private BigDecimal platformFee;

    @Enumerated(EnumType.STRING)
    private PaymentStatus paymentStatus;

    @Enumerated(EnumType.STRING)
    private PaymentMethod paymentMethod;

    private LocalDateTime createdAt;

    @OneToOne(fetch = FetchType.LAZY)
    private Offer offer;

    @ManyToOne(fetch = FetchType.LAZY)
    private ShipperProfile shipperProfile;

    @ManyToOne(fetch = FetchType.LAZY)
    private DriverProfile driverProfile;

    @PrePersist
    void prePersist() {
        createdAt = LocalDateTime.now();
    }
}
