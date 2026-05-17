package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.requests.OfferApplicationRequest;
import com.esemsar.backend.dtos.responses.OfferApplicationResponse;
import com.esemsar.backend.services.OfferApplicationService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class OfferApplicationController {
    private final OfferApplicationService applicationService;

    public OfferApplicationController(OfferApplicationService applicationService) {
        this.applicationService = applicationService;
    }

    @PostMapping("/api/offers/{offerId}/applications")
    @PreAuthorize("hasRole('DRIVER')")
    @ResponseStatus(HttpStatus.CREATED)
    public OfferApplicationResponse apply(@PathVariable Long offerId, @Valid @RequestBody OfferApplicationRequest request) {
        return applicationService.apply(offerId, request);
    }

    @GetMapping("/api/offers/{offerId}/applications")
    public Page<OfferApplicationResponse> byOffer(@PathVariable Long offerId, Pageable pageable) {
        return applicationService.byOffer(offerId, pageable);
    }

    @GetMapping("/api/applications/my")
    @PreAuthorize("hasRole('DRIVER')")
    public Page<OfferApplicationResponse> myApplications(Pageable pageable) {
        return applicationService.myApplications(pageable);
    }

    @PatchMapping("/api/applications/{applicationId}/accept")
    public OfferApplicationResponse accept(@PathVariable Long applicationId) {
        return applicationService.accept(applicationId);
    }

    @PatchMapping("/api/applications/{applicationId}/reject")
    public OfferApplicationResponse reject(@PathVariable Long applicationId) {
        return applicationService.reject(applicationId);
    }

    @PatchMapping("/api/applications/{applicationId}/cancel")
    @PreAuthorize("hasRole('DRIVER')")
    public OfferApplicationResponse cancel(@PathVariable Long applicationId) {
        return applicationService.cancel(applicationId);
    }
}
