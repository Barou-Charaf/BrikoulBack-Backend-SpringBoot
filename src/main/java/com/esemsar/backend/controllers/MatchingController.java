package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.responses.DriverProfileResponse;
import com.esemsar.backend.services.MatchingService;
import java.util.List;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/matching")
public class MatchingController {
    private final MatchingService matchingService;

    public MatchingController(MatchingService matchingService) {
        this.matchingService = matchingService;
    }

    @GetMapping("/offers/{offerId}/drivers")
    public List<DriverProfileResponse> drivers(@PathVariable Long offerId) {
        return matchingService.getMatchingDrivers(offerId);
    }

    @PostMapping("/offers/{offerId}/notify")
    public Map<String, String> notify(@PathVariable Long offerId) {
        matchingService.notifyMatchingDrivers(offerId);
        return Map.of("message", "Matching drivers notified");
    }
}
