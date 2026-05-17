package com.esemsar.backend.dtos.responses;

import java.util.List;

public record AiSearchResultResponse(
    List<DriverProfileResponse> drivers,
    List<WhatsAppContactResponse> driverWhatsAppContacts,
    List<OfferSummaryResponse> offers
) {
}
