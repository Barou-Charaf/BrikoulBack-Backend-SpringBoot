package com.esemsar.backend.dtos.responses;

import com.esemsar.backend.enums.PaymentMethod;
import com.esemsar.backend.enums.PaymentStatus;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public record PaymentResponse(
    Long id,
    BigDecimal amount,
    BigDecimal platformFee,
    PaymentStatus paymentStatus,
    PaymentMethod paymentMethod,
    Long offerId,
    LocalDateTime createdAt
) {
}
