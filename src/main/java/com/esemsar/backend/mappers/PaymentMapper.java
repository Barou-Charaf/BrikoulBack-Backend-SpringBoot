package com.esemsar.backend.mappers;

import com.esemsar.backend.dtos.responses.PaymentResponse;
import com.esemsar.backend.entities.Payment;
import org.springframework.stereotype.Component;

@Component
public class PaymentMapper {
    public PaymentResponse toResponse(Payment payment) {
        if (payment == null) {
            return null;
        }
        return new PaymentResponse(
            payment.getId(),
            payment.getAmount(),
            payment.getPlatformFee(),
            payment.getPaymentStatus(),
            payment.getPaymentMethod(),
            payment.getOffer() == null ? null : payment.getOffer().getId(),
            payment.getCreatedAt()
        );
    }
}
