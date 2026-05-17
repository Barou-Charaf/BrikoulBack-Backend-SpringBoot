package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.requests.ReviewRequest;
import com.esemsar.backend.dtos.responses.ReviewResponse;
import com.esemsar.backend.services.ReviewService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/reviews")
public class ReviewController {
    private final ReviewService reviewService;

    public ReviewController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ReviewResponse create(@Valid @RequestBody ReviewRequest request) {
        return reviewService.create(request);
    }

    @GetMapping("/user/{userId}")
    public Page<ReviewResponse> byUser(@PathVariable Long userId, Pageable pageable) {
        return reviewService.byUser(userId, pageable);
    }

    @GetMapping("/offer/{offerId}")
    public Page<ReviewResponse> byOffer(@PathVariable Long offerId, Pageable pageable) {
        return reviewService.byOffer(offerId, pageable);
    }

    @GetMapping("/my-received")
    public Page<ReviewResponse> myReceived(Pageable pageable) {
        return reviewService.myReceived(pageable);
    }

    @GetMapping("/my-written")
    public Page<ReviewResponse> myWritten(Pageable pageable) {
        return reviewService.myWritten(pageable);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        reviewService.delete(id);
    }
}
