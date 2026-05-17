package com.esemsar.backend.services.impl;

import com.esemsar.backend.dtos.requests.AdminCreateRequest;
import com.esemsar.backend.dtos.responses.AdminUserResponse;
import com.esemsar.backend.dtos.responses.DriverProfileResponse;
import com.esemsar.backend.dtos.responses.OfferResponse;
import com.esemsar.backend.dtos.responses.ReviewResponse;
import com.esemsar.backend.dtos.responses.ShipperProfileResponse;
import com.esemsar.backend.dtos.responses.TruckResponse;
import com.esemsar.backend.entities.DriverProfile;
import com.esemsar.backend.entities.Offer;
import com.esemsar.backend.entities.Review;
import com.esemsar.backend.entities.ShipperProfile;
import com.esemsar.backend.entities.Truck;
import com.esemsar.backend.entities.User;
import com.esemsar.backend.enums.OfferStatus;
import com.esemsar.backend.enums.Role;
import com.esemsar.backend.exceptions.BadRequestException;
import com.esemsar.backend.exceptions.EmailAlreadyExistsException;
import com.esemsar.backend.exceptions.ResourceNotFoundException;
import com.esemsar.backend.mappers.DriverMapper;
import com.esemsar.backend.mappers.OfferMapper;
import com.esemsar.backend.mappers.ReviewMapper;
import com.esemsar.backend.mappers.ShipperMapper;
import com.esemsar.backend.mappers.TruckMapper;
import com.esemsar.backend.mappers.UserMapper;
import com.esemsar.backend.repositories.DriverProfileRepository;
import com.esemsar.backend.repositories.OfferRepository;
import com.esemsar.backend.repositories.ReviewRepository;
import com.esemsar.backend.repositories.ShipperProfileRepository;
import com.esemsar.backend.repositories.TruckRepository;
import com.esemsar.backend.repositories.UserRepository;
import com.esemsar.backend.services.AdminService;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdminServiceImpl implements AdminService {
    private final UserRepository userRepository;
    private final DriverProfileRepository driverRepository;
    private final ShipperProfileRepository shipperRepository;
    private final OfferRepository offerRepository;
    private final ReviewRepository reviewRepository;
    private final TruckRepository truckRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserMapper userMapper;
    private final DriverMapper driverMapper;
    private final ShipperMapper shipperMapper;
    private final OfferMapper offerMapper;
    private final ReviewMapper reviewMapper;
    private final TruckMapper truckMapper;

    public AdminServiceImpl(
        UserRepository userRepository,
        DriverProfileRepository driverRepository,
        ShipperProfileRepository shipperRepository,
        OfferRepository offerRepository,
        ReviewRepository reviewRepository,
        TruckRepository truckRepository,
        PasswordEncoder passwordEncoder,
        UserMapper userMapper,
        DriverMapper driverMapper,
        ShipperMapper shipperMapper,
        OfferMapper offerMapper,
        ReviewMapper reviewMapper,
        TruckMapper truckMapper
    ) {
        this.userRepository = userRepository;
        this.driverRepository = driverRepository;
        this.shipperRepository = shipperRepository;
        this.offerRepository = offerRepository;
        this.reviewRepository = reviewRepository;
        this.truckRepository = truckRepository;
        this.passwordEncoder = passwordEncoder;
        this.userMapper = userMapper;
        this.driverMapper = driverMapper;
        this.shipperMapper = shipperMapper;
        this.offerMapper = offerMapper;
        this.reviewMapper = reviewMapper;
        this.truckMapper = truckMapper;
    }

    @Override
    public Page<AdminUserResponse> users(Pageable pageable) {
        return userRepository.findAll(pageable).map(userMapper::toAdminResponse);
    }

    @Override
    public AdminUserResponse user(Long id) {
        return userMapper.toAdminResponse(findUser(id));
    }

    @Override
    @Transactional
    public AdminUserResponse setLocked(Long id, boolean locked) {
        User user = findUser(id);
        user.setAccountLocked(locked);
        return userMapper.toAdminResponse(userRepository.save(user));
    }

    @Override
    @Transactional
    public AdminUserResponse setEnabled(Long id, boolean enabled) {
        User user = findUser(id);
        user.setEnabled(enabled);
        return userMapper.toAdminResponse(userRepository.save(user));
    }

    @Override
    public void deleteUser(Long id) {
        userRepository.delete(findUser(id));
    }

    @Override
    public Page<DriverProfileResponse> drivers(Pageable pageable) {
        return driverRepository.findAll(pageable).map(driverMapper::toResponse);
    }

    @Override
    public DriverProfileResponse driver(Long id) {
        return driverMapper.toResponse(findDriver(id));
    }

    @Override
    public List<TruckResponse> driverTrucks(Long id) {
        return truckRepository.findByDriverProfileId(id).stream().map(truckMapper::toResponse).toList();
    }

    @Override
    @Transactional
    public DriverProfileResponse setDriverAvailable(Long id, boolean available) {
        DriverProfile driver = findDriver(id);
        driver.setAvailable(available);
        driver.getUser().setAccountLocked(!available);
        return driverMapper.toResponse(driverRepository.save(driver));
    }

    @Override
    public Page<ShipperProfileResponse> shippers(Pageable pageable) {
        return shipperRepository.findAll(pageable).map(shipperMapper::toResponse);
    }

    @Override
    public ShipperProfileResponse shipper(Long id) {
        return shipperMapper.toResponse(findShipper(id));
    }

    @Override
    @Transactional
    public ShipperProfileResponse suspendShipper(Long id) {
        ShipperProfile shipper = findShipper(id);
        shipper.getUser().setAccountLocked(true);
        return shipperMapper.toResponse(shipperRepository.save(shipper));
    }

    @Override
    public Page<OfferResponse> offers(Pageable pageable) {
        return offerRepository.findAll(pageable).map(offerMapper::toResponse);
    }

    @Override
    public OfferResponse offer(Long id) {
        return offerMapper.toResponse(findOffer(id));
    }

    @Override
    @Transactional
    public OfferResponse cancelOffer(Long id) {
        Offer offer = findOffer(id);
        offer.setStatus(OfferStatus.CANCELED);
        return offerMapper.toResponse(offerRepository.save(offer));
    }

    @Override
    public void deleteOffer(Long id) {
        offerRepository.delete(findOffer(id));
    }

    @Override
    public Page<ReviewResponse> reviews(Pageable pageable) {
        return reviewRepository.findAll(pageable).map(reviewMapper::toResponse);
    }

    @Override
    public ReviewResponse review(Long id) {
        return reviewMapper.toResponse(findReview(id));
    }

    @Override
    public void deleteReview(Long id) {
        reviewRepository.delete(findReview(id));
    }

    @Override
    public Page<TruckResponse> trucks(Pageable pageable) {
        return truckRepository.findAll(pageable).map(truckMapper::toResponse);
    }

    @Override
    public TruckResponse truck(Long id) {
        return truckMapper.toResponse(findTruck(id));
    }

    @Override
    public void deleteTruck(Long id) {
        truckRepository.delete(findTruck(id));
    }

    @Override
    @Transactional
    public AdminUserResponse createAdmin(AdminCreateRequest request) {
        if (userRepository.existsByEmail(request.email().toLowerCase())) {
            throw new EmailAlreadyExistsException("Email already exists");
        }
        User admin = User.builder()
            .firstName(request.firstName())
            .lastName(request.lastName())
            .email(request.email().toLowerCase())
            .password(passwordEncoder.encode(request.password()))
            .phone(request.phone())
            .role(Role.ADMIN)
            .enabled(true)
            .emailVerified(true)
            .accountLocked(false)
            .build();
        return userMapper.toAdminResponse(userRepository.save(admin));
    }

    @Override
    public Page<AdminUserResponse> admins(Pageable pageable) {
        return userRepository.findByRole(Role.ADMIN, pageable).map(userMapper::toAdminResponse);
    }

    @Override
    public void deleteAdmin(Long id) {
        User user = findUser(id);
        if (user.getRole() != Role.ADMIN) {
            throw new BadRequestException("Only ADMIN users can be deleted from this endpoint");
        }
        userRepository.delete(user);
    }

    private User findUser(Long id) {
        return userRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    private DriverProfile findDriver(Long id) {
        return driverRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Driver profile not found"));
    }

    private ShipperProfile findShipper(Long id) {
        return shipperRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Shipper profile not found"));
    }

    private Offer findOffer(Long id) {
        return offerRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Offer not found"));
    }

    private Review findReview(Long id) {
        return reviewRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Review not found"));
    }

    private Truck findTruck(Long id) {
        return truckRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException("Truck not found"));
    }
}
