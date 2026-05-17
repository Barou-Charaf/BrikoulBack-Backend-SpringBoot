package com.esemsar.backend.services;

import com.esemsar.backend.dtos.requests.ReviewRequest;
import com.esemsar.backend.dtos.responses.ReviewResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface ReviewService {
    ReviewResponse create(ReviewRequest request);

    Page<ReviewResponse> byUser(Long userId, Pageable pageable);

    Page<ReviewResponse> byOffer(Long offerId, Pageable pageable);

    Page<ReviewResponse> myReceived(Pageable pageable);

    Page<ReviewResponse> myWritten(Pageable pageable);

    void delete(Long id);
}
