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
        String rawFilters = mistralAiService.extractFilters(request.message(), user.getRole());
        AiExtractedFilters filters = filterExtractor.parse(rawFilters);

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
            "Search completed",
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
}
