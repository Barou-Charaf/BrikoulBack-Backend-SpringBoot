package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.requests.OfferRequest;
import com.esemsar.backend.dtos.responses.OfferResponse;
import com.esemsar.backend.dtos.responses.OfferSummaryResponse;
import com.esemsar.backend.enums.VehicleType;
import com.esemsar.backend.services.OfferService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/offers")
public class OfferController {
    private final OfferService offerService;

    public OfferController(OfferService offerService) {
        this.offerService = offerService;
    }

    @PostMapping
    @PreAuthorize("hasRole('SHIPPER')")
    @ResponseStatus(HttpStatus.CREATED)
    public OfferResponse create(@Valid @RequestBody OfferRequest request) {
        return offerService.create(request);
    }

    @GetMapping("/my")
    @PreAuthorize("hasRole('SHIPPER')")
    public Page<OfferSummaryResponse> myOffers(Pageable pageable) {
        return offerService.myOffers(pageable);
    }

    @GetMapping("/{id}")
    public OfferResponse get(@PathVariable Long id) {
        return offerService.get(id);
    }

    @PutMapping("/{id}")
    public OfferResponse update(@PathVariable Long id, @Valid @RequestBody OfferRequest request) {
        return offerService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        offerService.delete(id);
    }

    @PatchMapping("/{id}/cancel")
    public OfferResponse cancel(@PathVariable Long id) {
        return offerService.cancel(id);
    }

    @PatchMapping("/{id}/start")
    public OfferResponse start(@PathVariable Long id) {
        return offerService.start(id);
    }

    @PatchMapping("/{id}/complete")
    public OfferResponse complete(@PathVariable Long id) {
        return offerService.complete(id);
    }

    @GetMapping
    public Page<OfferSummaryResponse> list(Pageable pageable) {
        return offerService.list(pageable);
    }

    @GetMapping("/search")
    public Page<OfferSummaryResponse> search(
        @RequestParam(required = false) String departureCity,
        @RequestParam(required = false) String arrivalCity,
        @RequestParam(required = false) VehicleType vehicleType,
        @RequestParam(required = false) Double maxWeightKg,
        Pageable pageable
    ) {
        return offerService.search(departureCity, arrivalCity, vehicleType, maxWeightKg, pageable);
    }

    @GetMapping("/available")
    public Page<OfferSummaryResponse> available(Pageable pageable) {
        return offerService.available(pageable);
    }
}
