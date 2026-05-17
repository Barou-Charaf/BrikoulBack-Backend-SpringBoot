package com.esemsar.backend.services;

import com.esemsar.backend.dtos.requests.AdminCreateRequest;
import com.esemsar.backend.dtos.responses.AdminUserResponse;
import com.esemsar.backend.dtos.responses.DriverProfileResponse;
import com.esemsar.backend.dtos.responses.OfferResponse;
import com.esemsar.backend.dtos.responses.ReviewResponse;
import com.esemsar.backend.dtos.responses.ShipperProfileResponse;
import com.esemsar.backend.dtos.responses.TruckResponse;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface AdminService {
    Page<AdminUserResponse> users(Pageable pageable);

    AdminUserResponse user(Long id);

    AdminUserResponse setLocked(Long id, boolean locked);

    AdminUserResponse setEnabled(Long id, boolean enabled);

    void deleteUser(Long id);

    Page<DriverProfileResponse> drivers(Pageable pageable);

    DriverProfileResponse driver(Long id);

    List<TruckResponse> driverTrucks(Long id);

    DriverProfileResponse setDriverAvailable(Long id, boolean available);

    Page<ShipperProfileResponse> shippers(Pageable pageable);

    ShipperProfileResponse shipper(Long id);

    ShipperProfileResponse suspendShipper(Long id);

    Page<OfferResponse> offers(Pageable pageable);

    OfferResponse offer(Long id);

    OfferResponse cancelOffer(Long id);

    void deleteOffer(Long id);

    Page<ReviewResponse> reviews(Pageable pageable);

    ReviewResponse review(Long id);

    void deleteReview(Long id);

    Page<TruckResponse> trucks(Pageable pageable);

    TruckResponse truck(Long id);

    void deleteTruck(Long id);

    AdminUserResponse createAdmin(AdminCreateRequest request);

    Page<AdminUserResponse> admins(Pageable pageable);

    void deleteAdmin(Long id);
}
