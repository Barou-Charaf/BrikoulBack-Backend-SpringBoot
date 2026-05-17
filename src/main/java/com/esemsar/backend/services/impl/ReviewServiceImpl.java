package com.esemsar.backend.services.impl;

import com.esemsar.backend.dtos.requests.ReviewRequest;
import com.esemsar.backend.dtos.responses.ReviewResponse;
import com.esemsar.backend.entities.Offer;
import com.esemsar.backend.entities.Review;
import com.esemsar.backend.entities.User;
import com.esemsar.backend.enums.NotificationType;
import com.esemsar.backend.enums.OfferStatus;
import com.esemsar.backend.enums.Role;
import com.esemsar.backend.exceptions.ForbiddenException;
import com.esemsar.backend.exceptions.InvalidReviewException;
import com.esemsar.backend.exceptions.ResourceNotFoundException;
import com.esemsar.backend.mappers.ReviewMapper;
import com.esemsar.backend.repositories.OfferRepository;
import com.esemsar.backend.repositories.ReviewRepository;
import com.esemsar.backend.repositories.UserRepository;
import com.esemsar.backend.services.NotificationService;
import com.esemsar.backend.services.ReviewService;
import com.esemsar.backend.services.UserService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ReviewServiceImpl implements ReviewService {
    private final ReviewRepository reviewRepository;
    private final OfferRepository offerRepository;
    private final UserRepository userRepository;
    private final UserService userService;
    private final ReviewMapper reviewMapper;
    private final NotificationService notificationService;

    public ReviewServiceImpl(
        ReviewRepository reviewRepository,
        OfferRepository offerRepository,
        UserRepository userRepository,
        UserService userService,
        ReviewMapper reviewMapper,
        NotificationService notificationService
    ) {
        this.reviewRepository = reviewRepository;
        this.offerRepository = offerRepository;
        this.userRepository = userRepository;
        this.userService = userService;
        this.reviewMapper = reviewMapper;
        this.notificationService = notificationService;
    }

    @Override
    @Transactional
    public ReviewResponse create(ReviewRequest request) {
        User reviewer = userService.currentUser();
        User reviewed = userRepository.findById(request.reviewedUserId())
            .orElseThrow(() -> new ResourceNotFoundException("Reviewed user not found"));
        Offer offer = offerRepository.findById(request.offerId())
            .orElseThrow(() -> new ResourceNotFoundException("Offer not found"));
        validateReview(reviewer, reviewed, offer);
        if (reviewRepository.existsByReviewerIdAndReviewedUserIdAndOfferId(reviewer.getId(), reviewed.getId(), offer.getId())) {
            throw new InvalidReviewException("You already reviewed this user for this offer");
        }
        Review review = Review.builder()
            .reviewer(reviewer)
            .reviewedUser(reviewed)
            .offer(offer)
            .rating(request.rating())
            .comment(request.comment())
            .build();
        Review saved = reviewRepository.save(review);
        recalculateAverage(reviewed);
        notificationService.create(reviewed, offer, "Review received",
            reviewer.getFirstName() + " left you a review.", NotificationType.REVIEW_RECEIVED);
        return reviewMapper.toResponse(saved);
    }

    @Override
    public Page<ReviewResponse> byUser(Long userId, Pageable pageable) {
        return reviewRepository.findByReviewedUserId(userId, pageable).map(reviewMapper::toResponse);
    }

    @Override
    public Page<ReviewResponse> byOffer(Long offerId, Pageable pageable) {
        return reviewRepository.findByOfferId(offerId, pageable).map(reviewMapper::toResponse);
    }

    @Override
    public Page<ReviewResponse> myReceived(Pageable pageable) {
        return reviewRepository.findByReviewedUserIdOrderByCreatedAtDesc(userService.currentUser().getId(), pageable)
            .map(reviewMapper::toResponse);
    }

    @Override
    public Page<ReviewResponse> myWritten(Pageable pageable) {
        return reviewRepository.findByReviewerIdOrderByCreatedAtDesc(userService.currentUser().getId(), pageable)
            .map(reviewMapper::toResponse);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Review review = reviewRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Review not found"));
        User current = userService.currentUser();
        boolean admin = current.getRole() == Role.ADMIN || current.getRole() == Role.SUPER_ADMIN;
        if (!admin && !review.getReviewer().getId().equals(current.getId())) {
            throw new ForbiddenException("Only reviewer or admin can delete this review");
        }
        User reviewed = review.getReviewedUser();
        reviewRepository.delete(review);
        recalculateAverage(reviewed);
    }

    private void validateReview(User reviewer, User reviewed, Offer offer) {
        if (offer.getStatus() != OfferStatus.COMPLETED) {
            throw new InvalidReviewException("Only completed offers can be reviewed");
        }
        if (offer.getAssignedDriver() == null) {
            throw new InvalidReviewException("Offer has no assigned driver");
        }
        Long shipperUserId = offer.getShipperProfile().getUser().getId();
        Long driverUserId = offer.getAssignedDriver().getUser().getId();
        boolean shipperReviewsDriver = reviewer.getId().equals(shipperUserId) && reviewed.getId().equals(driverUserId);
        boolean driverReviewsShipper = reviewer.getId().equals(driverUserId) && reviewed.getId().equals(shipperUserId);
        if (!shipperReviewsDriver && !driverReviewsShipper) {
            throw new InvalidReviewException("Only users involved in this completed offer can review each other");
        }
    }

    private void recalculateAverage(User reviewed) {
        double average = reviewRepository.findByReviewedUserId(reviewed.getId()).stream()
            .mapToInt(Review::getRating)
            .average()
            .orElse(0);
        if (reviewed.getDriverProfile() != null) {
            reviewed.getDriverProfile().setAverageRating(average);
        }
        if (reviewed.getShipperProfile() != null) {
            reviewed.getShipperProfile().setAverageRating(average);
        }
        userRepository.save(reviewed);
    }
}
