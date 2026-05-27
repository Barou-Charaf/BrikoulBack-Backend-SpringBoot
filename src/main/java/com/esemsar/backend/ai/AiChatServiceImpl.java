package com.esemsar.backend.ai;

import com.esemsar.backend.dtos.requests.AiChatRequest;
import com.esemsar.backend.dtos.responses.AiChatResponse;
import com.esemsar.backend.dtos.responses.AiExtractedFilters;
import com.esemsar.backend.dtos.responses.AiSearchResultResponse;
import com.esemsar.backend.dtos.responses.DriverProfileResponse;
import com.esemsar.backend.dtos.responses.OfferSummaryResponse;
import com.esemsar.backend.dtos.responses.WhatsAppContactResponse;
import com.esemsar.backend.entities.AiChatMessage;
import com.esemsar.backend.entities.User;
import com.esemsar.backend.enums.Role;
import com.esemsar.backend.enums.VehicleType;
import com.esemsar.backend.exceptions.AiServiceException;
import com.esemsar.backend.exceptions.ForbiddenException;
import com.esemsar.backend.repositories.AiChatMessageRepository;
import com.esemsar.backend.services.AiChatService;
import com.esemsar.backend.services.DriverService;
import com.esemsar.backend.services.MistralAiService;
import com.esemsar.backend.services.OfferService;
import com.esemsar.backend.services.UserService;
import com.esemsar.backend.services.WhatsAppService;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AiChatServiceImpl implements AiChatService {
    private final MistralAiService mistralAiService;
    private final AiFilterExtractor filterExtractor;
    private final DriverService driverService;
    private final OfferService offerService;
    private final WhatsAppService whatsAppService;
    private final UserService userService;
    private final AiChatMessageRepository chatRepository;

    public AiChatServiceImpl(
        MistralAiService mistralAiService,
        AiFilterExtractor filterExtractor,
        DriverService driverService,
        OfferService offerService,
        WhatsAppService whatsAppService,
        UserService userService,
        AiChatMessageRepository chatRepository
    ) {
        this.mistralAiService = mistralAiService;
        this.filterExtractor = filterExtractor;
        this.driverService = driverService;
        this.offerService = offerService;
        this.whatsAppService = whatsAppService;
        this.userService = userService;
        this.chatRepository = chatRepository;
    }

    @Override
    @Transactional
    public AiChatResponse chat(AiChatRequest request) {
        User user = userService.currentUser();
        if (user.getRole() != Role.SHIPPER && user.getRole() != Role.DRIVER) {
            throw new ForbiddenException("AI chat is available for shippers and drivers");
        }
        String rawFilters;
        AiExtractedFilters filters;
        try {
            rawFilters = mistralAiService.extractFilters(request.message(), user.getRole());
            filters = filterExtractor.parse(rawFilters);
        } catch (AiServiceException ex) {
            filters = fallbackFilters(request.message());
            rawFilters = "fallback-local-filter-extractor";
        }

        List<DriverProfileResponse> drivers = Collections.emptyList();
        List<WhatsAppContactResponse> driverContacts = Collections.emptyList();
        List<OfferSummaryResponse> offers = Collections.emptyList();
        if (user.getRole() == Role.SHIPPER) {
            drivers = driverService.search(filters.departureCity(), filters.vehicleType(), filters.minCapacityKg(), PageRequest.of(0, 20))
                .getContent();
            driverContacts = drivers.stream().map(driver -> whatsAppService.contactDriver(driver.id())).toList();
        } else {
            offers = offerService.search(filters.departureCity(), filters.arrivalCity(), filters.vehicleType(), filters.maxWeightKg(), PageRequest.of(0, 20))
                .getContent();
        }

        AiChatResponse response = new AiChatResponse(
            "J'ai trouvé des résultats correspondant à votre recherche.",
            filters,
            new AiSearchResultResponse(drivers, driverContacts, offers)
        );
        chatRepository.save(AiChatMessage.builder()
            .user(user)
            .userMessage(request.message())
            .aiResponse(rawFilters)
            .extractedDepartureCity(filters.departureCity())
            .extractedArrivalCity(filters.arrivalCity())
            .extractedVehicleType(filters.vehicleType())
            .extractedCapacityKg(user.getRole() == Role.SHIPPER ? filters.minCapacityKg() : filters.maxWeightKg())
            .build());
        return response;
    }

    @Override
    public List<AiChatResponse> history() {
        return chatRepository.findByUserIdOrderByCreatedAtDesc(userService.currentUser().getId()).stream()
            .map(message -> new AiChatResponse(
                message.getUserMessage(),
                new AiExtractedFilters(
                    message.getExtractedDepartureCity(),
                    message.getExtractedArrivalCity(),
                    message.getExtractedVehicleType(),
                    message.getExtractedCapacityKg(),
                    message.getExtractedCapacityKg()
                ),
                new AiSearchResultResponse(Collections.emptyList(), Collections.emptyList(), Collections.emptyList())
            ))
            .toList();
    }

    @Override
    @Transactional
    public void clearHistory() {
        chatRepository.deleteByUserId(userService.currentUser().getId());
    }

    private AiExtractedFilters fallbackFilters(String message) {
        String text = message == null ? "" : message.toLowerCase(Locale.ROOT);
        String departureCity = firstCity(text);
        String arrivalCity = secondCity(text, departureCity);
        VehicleType vehicleType = vehicleType(text);
        Double capacity = weight(text);
        return new AiExtractedFilters(departureCity, arrivalCity, vehicleType, capacity, capacity);
    }

    private String firstCity(String text) {
        for (String city : cities()) {
            if (text.contains(city.toLowerCase(Locale.ROOT))) {
                return city;
            }
        }
        return null;
    }

    private String secondCity(String text, String firstCity) {
        for (String city : cities()) {
            if (!city.equals(firstCity) && text.contains(city.toLowerCase(Locale.ROOT))) {
                return city;
            }
        }
        return null;
    }

    private VehicleType vehicleType(String text) {
        if (text.contains("moto") || text.contains("motorcycle")) return VehicleType.MOTORCYCLE;
        if (text.contains("petite fourgonnette") || text.contains("small van")) return VehicleType.SMALL_VAN;
        if (text.contains("pickup") || text.contains("pick-up")) return VehicleType.PICKUP;
        if (text.contains("fourgon") || text.contains("van")) return VehicleType.VAN;
        if (text.contains("petit camion")) return VehicleType.SMALL_TRUCK;
        if (text.contains("camion moyen")) return VehicleType.MEDIUM_TRUCK;
        if (text.contains("grand camion") || text.contains("big truck")) return VehicleType.BIG_TRUCK;
        if (text.contains("camion")) return VehicleType.MEDIUM_TRUCK;
        return null;
    }

    private Double weight(String text) {
        Matcher matcher = Pattern.compile("(\\d+(?:[\\.,]\\d+)?)\\s*(kg|kilo|kilos|tonne|tonnes|t)\\b").matcher(text);
        if (!matcher.find()) {
            return null;
        }
        double value = Double.parseDouble(matcher.group(1).replace(',', '.'));
        String unit = matcher.group(2);
        return unit.startsWith("t") ? value * 1000 : value;
    }

    private List<String> cities() {
        return List.of("Casablanca", "Rabat", "Marrakech", "Tanger", "Fes", "Agadir", "Meknes", "Oujda");
    }
}
