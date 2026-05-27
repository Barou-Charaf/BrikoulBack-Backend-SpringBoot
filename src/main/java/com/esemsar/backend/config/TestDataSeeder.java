package com.esemsar.backend.config;

import com.esemsar.backend.entities.DriverProfile;
import com.esemsar.backend.entities.ShipperProfile;
import com.esemsar.backend.entities.Truck;
import com.esemsar.backend.entities.User;
import com.esemsar.backend.enums.Role;
import com.esemsar.backend.enums.VehicleType;
import com.esemsar.backend.repositories.UserRepository;
import java.util.ArrayList;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@Slf4j
public class TestDataSeeder implements CommandLineRunner {
    private static final String DRIVER_PASSWORD = "driver1234567";
    private static final String SHIPPER_PASSWORD = "shipper1234567";

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.seed-test-data:true}")
    private boolean seedTestData;

    public TestDataSeeder(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public void run(String... args) {
        if (!seedTestData) {
            log.info("Test data seeding is disabled.");
            return;
        }

        int createdDrivers = seedDrivers();
        int createdShippers = seedShippers();

        log.info("Test data seeding finished. Created drivers: {}, created shippers: {}", createdDrivers, createdShippers);
        log.info("Driver login pattern: driver1@gmail.com to driver20@gmail.com / password: {}", DRIVER_PASSWORD);
        log.info("Shipper login pattern: shipper1@gmail.com to shipper5@gmail.com / password: {}", SHIPPER_PASSWORD);
    }

    private int seedDrivers() {
        int created = 0;
        for (int i = 1; i <= 20; i++) {
            String email = "driver" + i + "@gmail.com";
            if (userRepository.existsByEmail(email)) {
                userRepository.findByEmail(email).ifPresent(user -> {
                    user.setPassword(passwordEncoder.encode(DRIVER_PASSWORD));
                    user.setEnabled(true);
                    user.setEmailVerified(true);
                    user.setAccountLocked(false);
                    userRepository.save(user);
                });
                continue;
            }

            User user = User.builder()
                .firstName("Driver")
                .lastName(String.valueOf(i))
                .email(email)
                .password(passwordEncoder.encode(DRIVER_PASSWORD))
                .phone("+212 600 100 " + String.format("%03d", i))
                .role(Role.DRIVER)
                .enabled(true)
                .emailVerified(true)
                .accountLocked(false)
                .build();

            DriverProfile profile = DriverProfile.builder()
                .user(user)
                .currentCity(cityFor(i))
                .available(true)
                .averageRating(3.5 + (i % 6) * 0.25)
                .completedJobs(i * 2)
                .trucks(new ArrayList<>())
                .build();
            user.setDriverProfile(profile);

            for (Truck truck : trucksForDriver(i, profile)) {
                profile.getTrucks().add(truck);
            }

            userRepository.save(user);
            created++;
        }
        return created;
    }

    private int seedShippers() {
        int created = 0;
        for (int i = 1; i <= 5; i++) {
            String email = "shipper" + i + "@gmail.com";
            if (userRepository.existsByEmail(email)) {
                userRepository.findByEmail(email).ifPresent(user -> {
                    user.setPassword(passwordEncoder.encode(SHIPPER_PASSWORD));
                    user.setEnabled(true);
                    user.setEmailVerified(true);
                    user.setAccountLocked(false);
                    userRepository.save(user);
                });
                continue;
            }

            User user = User.builder()
                .firstName("Shipper")
                .lastName(String.valueOf(i))
                .email(email)
                .password(passwordEncoder.encode(SHIPPER_PASSWORD))
                .phone("+212 600 200 " + String.format("%03d", i))
                .role(Role.SHIPPER)
                .enabled(true)
                .emailVerified(true)
                .accountLocked(false)
                .build();

            ShipperProfile profile = ShipperProfile.builder()
                .user(user)
                .companyName("Shipper Company " + i)
                .address(cityFor(i) + ", Morocco")
                .averageRating(4.0 + (i % 3) * 0.2)
                .completedOffers(i * 3)
                .build();
            user.setShipperProfile(profile);

            userRepository.save(user);
            created++;
        }
        return created;
    }

    private List<Truck> trucksForDriver(int driverNumber, DriverProfile profile) {
        List<Truck> trucks = new ArrayList<>();
        trucks.add(truck(profile, driverNumber, 1, vehicleFor(driverNumber), capacityFor(vehicleFor(driverNumber)), true));

        if (driverNumber <= 5) {
            trucks.add(truck(profile, driverNumber, 2, VehicleType.PICKUP, 900.0 + driverNumber * 50, true));
        }
        if (driverNumber == 2 || driverNumber == 4 || driverNumber == 5) {
            trucks.add(truck(profile, driverNumber, 3, VehicleType.MEDIUM_TRUCK, 4000.0 + driverNumber * 100, true));
        }

        return trucks;
    }

    private Truck truck(
        DriverProfile profile,
        int driverNumber,
        int truckNumber,
        VehicleType vehicleType,
        Double capacityKg,
        boolean active
    ) {
        return Truck.builder()
            .driverProfile(profile)
            .brand(brandFor(vehicleType))
            .model("Model " + driverNumber + "-" + truckNumber)
            .plateNumber("BRK-" + String.format("%02d", driverNumber) + "-" + truckNumber)
            .vehicleType(vehicleType)
            .capacityKg(capacityKg)
            .active(active)
            .build();
    }

    private String cityFor(int number) {
        String[] cities = {
            "Casablanca",
            "Rabat",
            "Marrakech",
            "Tanger",
            "Fes",
            "Agadir",
            "Meknes",
            "Oujda"
        };
        return cities[(number - 1) % cities.length];
    }

    private VehicleType vehicleFor(int number) {
        VehicleType[] types = {
            VehicleType.VAN,
            VehicleType.SMALL_VAN,
            VehicleType.PICKUP,
            VehicleType.SMALL_TRUCK,
            VehicleType.MEDIUM_TRUCK,
            VehicleType.BIG_TRUCK,
            VehicleType.MOTORCYCLE
        };
        return types[(number - 1) % types.length];
    }

    private Double capacityFor(VehicleType vehicleType) {
        return switch (vehicleType) {
            case MOTORCYCLE -> 80.0;
            case SMALL_VAN -> 600.0;
            case PICKUP -> 1000.0;
            case VAN -> 1500.0;
            case SMALL_TRUCK -> 2500.0;
            case MEDIUM_TRUCK -> 5000.0;
            case BIG_TRUCK -> 12000.0;
        };
    }

    private String brandFor(VehicleType vehicleType) {
        return switch (vehicleType) {
            case MOTORCYCLE -> "Yamaha";
            case SMALL_VAN, VAN -> "Mercedes";
            case PICKUP -> "Toyota";
            case SMALL_TRUCK, MEDIUM_TRUCK, BIG_TRUCK -> "Isuzu";
        };
    }
}
