package com.esemsar.backend.repositories;

import com.esemsar.backend.entities.Review;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ReviewRepository extends JpaRepository<Review, Long> {
    Page<Review> findByReviewedUserId(Long reviewedUserId, Pageable pageable);

    Page<Review> findByOfferId(Long offerId, Pageable pageable);

    Page<Review> findByReviewedUserIdOrderByCreatedAtDesc(Long reviewedUserId, Pageable pageable);

    Page<Review> findByReviewerIdOrderByCreatedAtDesc(Long reviewerId, Pageable pageable);

    boolean existsByReviewerIdAndReviewedUserIdAndOfferId(Long reviewerId, Long reviewedUserId, Long offerId);

    List<Review> findByReviewedUserId(Long reviewedUserId);
}
