package com.esemsar.backend.services.impl;

import com.esemsar.backend.dtos.responses.AdminStatisticsResponse;
import com.esemsar.backend.enums.OfferStatus;
import com.esemsar.backend.enums.Role;
import com.esemsar.backend.repositories.OfferRepository;
import com.esemsar.backend.repositories.PaymentRepository;
import com.esemsar.backend.repositories.UserRepository;
import com.esemsar.backend.services.StatisticsService;
import java.math.BigDecimal;
import org.springframework.stereotype.Service;

@Service
public class StatisticsServiceImpl implements StatisticsService {
    private final UserRepository userRepository;
    private final OfferRepository offerRepository;
    private final PaymentRepository paymentRepository;

    public StatisticsServiceImpl(UserRepository userRepository, OfferRepository offerRepository, PaymentRepository paymentRepository) {
        this.userRepository = userRepository;
        this.offerRepository = offerRepository;
        this.paymentRepository = paymentRepository;
    }

    @Override
    public AdminStatisticsResponse statistics() {
        return new AdminStatisticsResponse(
            userRepository.count(),
            userRepository.countByRole(Role.DRIVER),
            userRepository.countByRole(Role.SHIPPER),
            offerRepository.count(),
            offerRepository.countByStatus(OfferStatus.COMPLETED),
            offerRepository.countByStatus(OfferStatus.CANCELED),
            nullSafe(paymentRepository.sumAmount()),
            nullSafe(paymentRepository.sumPlatformFee())
        );
    }

    private BigDecimal nullSafe(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }
}
