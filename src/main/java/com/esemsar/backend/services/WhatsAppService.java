package com.esemsar.backend.services;

import com.esemsar.backend.dtos.responses.WhatsAppContactResponse;

public interface WhatsAppService {
    WhatsAppContactResponse contactDriver(Long driverId);

    WhatsAppContactResponse contactShipper(Long offerId);
}
