package com.esemsar.backend.services.impl;

import com.esemsar.backend.dtos.requests.OfferApplicationRequest;
import com.esemsar.backend.dtos.responses.OfferApplicationResponse;
import com.esemsar.backend.entities.DriverProfile;
import com.esemsar.backend.entities.Offer;
import com.esemsar.backend.entities.OfferApplication;
import com.esemsar.backend.entities.User;
import com.esemsar.backend.enums.ApplicationStatus;
import com.esemsar.backend.enums.NotificationType;
import com.esemsar.backend.enums.OfferStatus;
import com.esemsar.backend.enums.Role;
import com.esemsar.backend.exceptions.BadRequestException;
import com.esemsar.backend.exceptions.DuplicateApplicationException;
import com.esemsar.backend.exceptions.ForbiddenException;
import com.esemsar.backend.exceptions.ResourceNotFoundException;
import com.esemsar.backend.mappers.ApplicationMapper;
import com.esemsar.backend.repositories.OfferApplicationRepository;
import com.esemsar.backend.repositories.OfferRepository;
import com.esemsar.backend.services.DriverService;
import com.esemsar.backend.services.NotificationService;
import com.esemsar.backend.services.OfferApplicationService;
import com.esemsar.backend.services.UserService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OfferApplicationServiceImpl implements OfferApplicationService {
    private final OfferApplicationRepository applicationRepository;
    private final OfferRepository offerRepository;
    private final DriverService driverService;
    private final UserService userService;
    private final ApplicationMapper applicationMapper;
    private final NotificationService notificationService;

    public OfferApplicationServiceImpl(
        OfferApplicationRepository applicationRepository,
        OfferRepository offerRepository,
        DriverService driverService,
        UserService userService,
        ApplicationMapper applicationMapper,
        NotificationService notificationService
    ) {
        this.applicationRepository = applicationRepository;
        this.offerRepository = offerRepository;
        this.driverService = driverService;
        this.userService = userService;
        this.applicationMapper = applicationMapper;
        this.notificationService = notificationService;
    }

    @Override
    @Transactional
    public OfferApplicationResponse apply(Long offerId, OfferApplicationRequest request) {
        DriverProfile driver = driverService.currentDriver();
        Offer offer = offerRepository.findById(offerId)
            .orElseThrow(() -> new ResourceNotFoundException("Offer not found"));
        if (offer.getStatus() == OfferStatus.CANCELED || offer.getStatus() == OfferStatus.COMPLETED || offer.getStatus() == OfferStatus.ASSIGNED) {
            throw new BadRequestException("Driver cannot apply to canceled, completed, or assigned offers");
        }
        if (applicationRepository.existsByOfferIdAndDriverProfileId(offerId, driver.getId())) {
            throw new DuplicateApplicationException("Driver already applied to this offer");
        }
        OfferApplication application = OfferApplication.builder()
            .offer(offer)
            .driverProfile(driver)
            .message(request.message())
            .proposedPrice(request.proposedPrice())
            .status(ApplicationStatus.PENDING)
            .build();
        OfferApplication saved = applicationRepository.save(application);
        notificationService.create(
            offer.getShipperProfile().getUser(),
            offer,
            "Driver applied",
            driver.getUser().getFirstName() + " applied to your offer " + offer.getTitle() + ".",
            NotificationType.DRIVER_APPLIED
        );
        return applicationMapper.toResponse(saved);
    }

    @Override
    public Page<OfferApplicationResponse> byOffer(Long offerId, Pageable pageable) {
        Offer offer = offerRepository.findById(offerId)
            .orElseThrow(() -> new ResourceNotFoundException("Offer not found"));
        User current = userService.currentUser();
        boolean admin = current.getRole() == Role.ADMIN || current.getRole() == Role.SUPER_ADMIN;
        boolean owner = current.getRole() == Role.SHIPPER && offer.getShipperProfile().getUser().getId().equals(current.getId());
        if (!admin && !owner) {
            throw new ForbiddenException("Only owner shipper or admin can view applications");
        }
        java.util.List<OfferApplicationResponse> applications = applicationRepository.findByOfferId(offerId).stream()
            .map(applicationMapper::toResponse)
            .toList();
        return new PageImpl<>(applications, pageable, applications.size());
    }

    @Override
    public Page<OfferApplicationResponse> myApplications(Pageable pageable) {
        return applicationRepository.findByDriverProfileId(driverService.currentDriver().getId(), pageable)
            .map(applicationMapper::toResponse);
    }

    @Override
    @Transactional
    public OfferApplicationResponse accept(Long applicationId) {
        OfferApplication application = find(applicationId);
        Offer offer = application.getOffer();
        requireOfferOwner(offer);
        if (offer.getStatus() == OfferStatus.ASSIGNED || offer.getStatus() == OfferStatus.COMPLETED || offer.getStatus() == OfferStatus.CANCELED) {
            throw new BadRequestException("Offer cannot accept applications in current status");
        }
        application.setStatus(ApplicationStatus.ACCEPTED);
        offer.setAssignedDriver(application.getDriverProfile());
        offer.setStatus(OfferStatus.ASSIGNED);
        for (OfferApplication other : applicationRepository.findByOfferId(offer.getId())) {
            if (!other.getId().equals(application.getId()) && other.getStatus() == ApplicationStatus.PENDING) {
                other.setStatus(ApplicationStatus.REJECTED);
                notificationService.create(other.getDriverProfile().getUser(), offer, "Application rejected",
                    "Your application for " + offer.getTitle() + " was rejected.", NotificationType.APPLICATION_REJECTED);
            }
        }
        notificationService.create(application.getDriverProfile().getUser(), offer, "Application accepted",
            "Your application for " + offer.getTitle() + " was accepted.", NotificationType.APPLICATION_ACCEPTED);
        offerRepository.save(offer);
        return applicationMapper.toResponse(applicationRepository.save(application));
    }

    @Override
    @Transactional
    public OfferApplicationResponse reject(Long applicationId) {
        OfferApplication application = find(applicationId);
        requireOfferOwner(application.getOffer());
        application.setStatus(ApplicationStatus.REJECTED);
        notificationService.create(application.getDriverProfile().getUser(), application.getOffer(), "Application rejected",
            "Your application for " + application.getOffer().getTitle() + " was rejected.", NotificationType.APPLICATION_REJECTED);
        return applicationMapper.toResponse(applicationRepository.save(application));
    }

    @Override
    @Transactional
    public OfferApplicationResponse cancel(Long applicationId) {
        OfferApplication application = find(applicationId);
        DriverProfile driver = driverService.currentDriver();
        if (!application.getDriverProfile().getId().equals(driver.getId())) {
            throw new ForbiddenException("Only the applying driver can cancel this application");
        }
        application.setStatus(ApplicationStatus.CANCELED);
        return applicationMapper.toResponse(applicationRepository.save(application));
    }

    private OfferApplication find(Long id) {
        return applicationRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Application not found"));
    }

    private void requireOfferOwner(Offer offer) {
        User current = userService.currentUser();
        if (current.getRole() != Role.SHIPPER || !offer.getShipperProfile().getUser().getId().equals(current.getId())) {
            throw new ForbiddenException("Only the offer owner can manage applications");
        }
    }
}
