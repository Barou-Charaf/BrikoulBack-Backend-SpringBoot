package com.esemsar.backend.services;

import com.esemsar.backend.dtos.requests.OfferApplicationRequest;
import com.esemsar.backend.dtos.responses.OfferApplicationResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface OfferApplicationService {
    OfferApplicationResponse apply(Long offerId, OfferApplicationRequest request);

    Page<OfferApplicationResponse> byOffer(Long offerId, Pageable pageable);

    Page<OfferApplicationResponse> myApplications(Pageable pageable);

    OfferApplicationResponse accept(Long applicationId);

    OfferApplicationResponse reject(Long applicationId);

    OfferApplicationResponse cancel(Long applicationId);
}
