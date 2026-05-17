package com.esemsar.backend.mappers;

import com.esemsar.backend.dtos.responses.ReviewResponse;
import com.esemsar.backend.entities.Review;
import org.springframework.stereotype.Component;

@Component
public class ReviewMapper {
    private final UserMapper userMapper;

    public ReviewMapper(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public ReviewResponse toResponse(Review review) {
        if (review == null) {
            return null;
        }
        return new ReviewResponse(
            review.getId(),
            review.getRating(),
            review.getComment(),
            userMapper.toResponse(review.getReviewer()),
            userMapper.toResponse(review.getReviewedUser()),
            review.getOffer() == null ? null : review.getOffer().getId(),
            review.getCreatedAt()
        );
    }
}
