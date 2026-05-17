package com.esemsar.backend.mappers;

import com.esemsar.backend.dtos.responses.DriverProfileResponse;
import com.esemsar.backend.entities.DriverProfile;
import org.springframework.stereotype.Component;

@Component
public class DriverMapper {
    private final UserMapper userMapper;

    public DriverMapper(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public DriverProfileResponse toResponse(DriverProfile driver) {
        if (driver == null) {
            return null;
        }
        return new DriverProfileResponse(
            driver.getId(),
            userMapper.toResponse(driver.getUser()),
            driver.getCurrentCity(),
            driver.isAvailable(),
            driver.getAverageRating(),
            driver.getCompletedJobs(),
            driver.getCreatedAt(),
            driver.getUpdatedAt()
        );
    }
}
