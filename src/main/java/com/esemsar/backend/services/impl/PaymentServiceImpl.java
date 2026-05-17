package com.esemsar.backend.services.impl;

import com.esemsar.backend.dtos.responses.PaymentResponse;
import com.esemsar.backend.entities.Offer;
import com.esemsar.backend.entities.Payment;
import com.esemsar.backend.enums.PaymentMethod;
import com.esemsar.backend.enums.PaymentStatus;
import com.esemsar.backend.mappers.PaymentMapper;
import com.esemsar.backend.repositories.PaymentRepository;
import com.esemsar.backend.services.PaymentService;
import java.math.BigDecimal;
import java.math.RoundingMode;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PaymentServiceImpl implements PaymentService {
    private final PaymentRepository paymentRepository;
    private final PaymentMapper paymentMapper;

    @Value("${app.payments.platform-fee-rate}")
    private BigDecimal platformFeeRate;

    public PaymentServiceImpl(PaymentRepository paymentRepository, PaymentMapper paymentMapper) {
        this.paymentRepository = paymentRepository;
        this.paymentMapper = paymentMapper;
    }

    @Override
    @Transactional
    public PaymentResponse createCompletedOfferPayment(Offer offer) {
        if (paymentRepository.existsByOfferId(offer.getId())) {
            return paymentRepository.findAll().stream()
                .filter(payment -> payment.getOffer().getId().equals(offer.getId()))
                .findFirst()
                .map(paymentMapper::toResponse)
                .orElse(null);
        }
        BigDecimal amount = offer.getProposedPrice() == null ? BigDecimal.ZERO : offer.getProposedPrice();
        Payment payment = Payment.builder()
            .offer(offer)
            .shipperProfile(offer.getShipperProfile())
            .driverProfile(offer.getAssignedDriver())
            .amount(amount)
            .platformFee(amount.multiply(platformFeeRate).setScale(2, RoundingMode.HALF_UP))
            .paymentStatus(PaymentStatus.PAID)
            .paymentMethod(PaymentMethod.CASH)
            .build();
        return paymentMapper.toResponse(paymentRepository.save(payment));
    }

    @Override
    public Page<PaymentResponse> list(Pageable pageable) {
        return paymentRepository.findAll(pageable).map(paymentMapper::toResponse);
    }
}
