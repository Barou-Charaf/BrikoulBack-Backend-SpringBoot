package com.esemsar.backend.services.impl;

import com.esemsar.backend.dtos.requests.OfferRequest;
import com.esemsar.backend.dtos.responses.OfferResponse;
import com.esemsar.backend.dtos.responses.OfferSummaryResponse;
import com.esemsar.backend.entities.Offer;
import com.esemsar.backend.entities.User;
import com.esemsar.backend.enums.NotificationType;
import com.esemsar.backend.enums.OfferStatus;
import com.esemsar.backend.enums.Role;
import com.esemsar.backend.enums.VehicleType;
import com.esemsar.backend.exceptions.ForbiddenException;
import com.esemsar.backend.exceptions.OfferAlreadyAssignedException;
import com.esemsar.backend.exceptions.ResourceNotFoundException;
import com.esemsar.backend.mappers.OfferMapper;
import com.esemsar.backend.repositories.OfferRepository;
import com.esemsar.backend.services.MatchingService;
import com.esemsar.backend.services.NotificationService;
import com.esemsar.backend.services.OfferService;
import com.esemsar.backend.services.PaymentService;
import com.esemsar.backend.services.ShipperService;
import com.esemsar.backend.services.UserService;
import java.util.List;
import org.springframework.context.annotation.Lazy;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OfferServiceImpl implements OfferService {
    private final OfferRepository offerRepository;
    private final ShipperService shipperService;
    private final UserService userService;
    private final OfferMapper offerMapper;
    private final MatchingService matchingService;
    private final PaymentService paymentService;
    private final NotificationService notificationService;

    public OfferServiceImpl(
        OfferRepository offerRepository,
        ShipperService shipperService,
        UserService userService,
        OfferMapper offerMapper,
        @Lazy MatchingService matchingService,
        PaymentService paymentService,
        NotificationService notificationService
    ) {
        this.offerRepository = offerRepository;
        this.shipperService = shipperService;
        this.userService = userService;
        this.offerMapper = offerMapper;
        this.matchingService = matchingService;
        this.paymentService = paymentService;
        this.notificationService = notificationService;
    }

    @Override
    public Offer getEntity(Long id) {
        return offerRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Offer not found"));
    }

    @Override
    @Transactional
    public OfferResponse create(OfferRequest request) {
        Offer offer = Offer.builder()
            .title(request.title())
            .description(request.description())
            .departureCity(request.departureCity())
            .arrivalCity(request.arrivalCity())
            .pickupAddress(request.pickupAddress())
            .deliveryAddress(request.deliveryAddress())
            .goodsType(request.goodsType())
            .weightKg(request.weightKg())
            .requiredVehicleType(request.requiredVehicleType())
            .proposedPrice(request.proposedPrice())
            .maxDriversToNotify(request.maxDriversToNotify() == null ? 10 : request.maxDriversToNotify())
            .transportDate(request.transportDate())
            .status(OfferStatus.PENDING)
            .shipperProfile(shipperService.currentShipper())
            .build();
        Offer saved = offerRepository.save(offer);
        matchingService.notifyMatchingDrivers(saved.getId());
        return offerMapper.toResponse(getEntity(saved.getId()));
    }

    @Override
    public Page<OfferSummaryResponse> myOffers(Pageable pageable) {
        return offerRepository.findByShipperProfileId(shipperService.currentShipper().getId(), pageable).map(offerMapper::toSummary);
    }

    @Override
    public OfferResponse get(Long id) {
        return offerMapper.toResponse(getEntity(id));
    }

    @Override
    @Transactional
    public OfferResponse update(Long id, OfferRequest request) {
        Offer offer = getEntity(id);
        requireOwner(offer);
        if (List.of(OfferStatus.ASSIGNED, OfferStatus.IN_PROGRESS, OfferStatus.COMPLETED, OfferStatus.CANCELED).contains(offer.getStatus())) {
            throw new OfferAlreadyAssignedException("Offer cannot be updated after assignment, completion, or cancellation");
        }
        applyRequest(offer, request);
        return offerMapper.toResponse(offerRepository.save(offer));
    }

    @Override
    public void delete(Long id) {
        Offer offer = getEntity(id);
        requireOwnerOrAdmin(offer);
        offerRepository.delete(offer);
    }

    @Override
    @Transactional
    public OfferResponse cancel(Long id) {
        Offer offer = getEntity(id);
        requireOwnerOrAdmin(offer);
        offer.setStatus(OfferStatus.CANCELED);
        offer.getApplications().forEach(application -> {
            if (application.getDriverProfile() != null) {
                notificationService.create(application.getDriverProfile().getUser(), offer, "Offer canceled",
                    "The offer " + offer.getTitle() + " has been canceled.", NotificationType.OFFER_CANCELED);
            }
        });
        return offerMapper.toResponse(offerRepository.save(offer));
    }

    @Override
    @Transactional
    public OfferResponse start(Long id) {
        Offer offer = getEntity(id);
        User current = userService.currentUser();
        boolean owner = current.getRole() == Role.SHIPPER && offer.getShipperProfile().getUser().getId().equals(current.getId());
        boolean assignedDriver = current.getRole() == Role.DRIVER
            && offer.getAssignedDriver() != null
            && offer.getAssignedDriver().getUser().getId().equals(current.getId());
        if (!owner && !assignedDriver) {
            throw new ForbiddenException("Only owner shipper or assigned driver can start this offer");
        }
        offer.setStatus(OfferStatus.IN_PROGRESS);
        return offerMapper.toResponse(offerRepository.save(offer));
    }

    @Override
    @Transactional
    public OfferResponse complete(Long id) {
        Offer offer = getEntity(id);
        requireOwnerOrAdmin(offer);
        offer.setStatus(OfferStatus.COMPLETED);
        if (offer.getAssignedDriver() != null) {
            offer.getAssignedDriver().setCompletedJobs(offer.getAssignedDriver().getCompletedJobs() + 1);
        }
        offer.getShipperProfile().setCompletedOffers(offer.getShipperProfile().getCompletedOffers() + 1);
        Offer saved = offerRepository.save(offer);
        paymentService.createCompletedOfferPayment(saved);
        if (offer.getAssignedDriver() != null) {
            notificationService.create(offer.getAssignedDriver().getUser(), offer, "Offer completed",
                "The offer " + offer.getTitle() + " has been marked completed.", NotificationType.OFFER_COMPLETED);
        }
        return offerMapper.toResponse(saved);
    }

    @Override
    public Page<OfferSummaryResponse> list(Pageable pageable) {
        return offerRepository.findAll(pageable).map(offerMapper::toSummary);
    }

    @Override
    public Page<OfferSummaryResponse> search(String departureCity, String arrivalCity, VehicleType vehicleType, Double maxWeightKg, Pageable pageable) {
        return offerRepository.search(blankToNull(departureCity), blankToNull(arrivalCity), vehicleType, maxWeightKg,
            List.of(OfferStatus.PENDING, OfferStatus.NOTIFIED), pageable).map(offerMapper::toSummary);
    }

    @Override
    public Page<OfferSummaryResponse> available(Pageable pageable) {
        return offerRepository.findByStatusIn(List.of(OfferStatus.PENDING, OfferStatus.NOTIFIED), pageable).map(offerMapper::toSummary);
    }

    private void applyRequest(Offer offer, OfferRequest request) {
        offer.setTitle(request.title());
        offer.setDescription(request.description());
        offer.setDepartureCity(request.departureCity());
        offer.setArrivalCity(request.arrivalCity());
        offer.setPickupAddress(request.pickupAddress());
        offer.setDeliveryAddress(request.deliveryAddress());
        offer.setGoodsType(request.goodsType());
        offer.setWeightKg(request.weightKg());
        offer.setRequiredVehicleType(request.requiredVehicleType());
        offer.setProposedPrice(request.proposedPrice());
        offer.setMaxDriversToNotify(request.maxDriversToNotify());
        offer.setTransportDate(request.transportDate());
    }

    private void requireOwner(Offer offer) {
        User current = userService.currentUser();
        if (current.getRole() != Role.SHIPPER || !offer.getShipperProfile().getUser().getId().equals(current.getId())) {
            throw new ForbiddenException("Only the owner shipper can manage this offer");
        }
    }

    private void requireOwnerOrAdmin(Offer offer) {
        User current = userService.currentUser();
        boolean admin = current.getRole() == Role.ADMIN || current.getRole() == Role.SUPER_ADMIN;
        boolean owner = current.getRole() == Role.SHIPPER && offer.getShipperProfile().getUser().getId().equals(current.getId());
        if (!admin && !owner) {
            throw new ForbiddenException("Only the owner shipper or admin can manage this offer");
        }
    }

    private String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value;
    }
}
