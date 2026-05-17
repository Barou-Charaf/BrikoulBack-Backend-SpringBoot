package com.esemsar.backend.services;

import com.esemsar.backend.dtos.responses.PaymentResponse;
import com.esemsar.backend.entities.Offer;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface PaymentService {
    PaymentResponse createCompletedOfferPayment(Offer offer);

    Page<PaymentResponse> list(Pageable pageable);
}
