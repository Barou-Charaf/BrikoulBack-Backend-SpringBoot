package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.responses.WhatsAppContactResponse;
import com.esemsar.backend.services.WhatsAppService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/whatsapp")
public class WhatsAppController {
    private final WhatsAppService whatsAppService;

    public WhatsAppController(WhatsAppService whatsAppService) {
        this.whatsAppService = whatsAppService;
    }

    @GetMapping("/contact-driver/{driverId}")
    public WhatsAppContactResponse contactDriver(@PathVariable Long driverId) {
        return whatsAppService.contactDriver(driverId);
    }

    @GetMapping("/contact-shipper/{offerId}")
    public WhatsAppContactResponse contactShipper(@PathVariable Long offerId) {
        return whatsAppService.contactShipper(offerId);
    }
}
