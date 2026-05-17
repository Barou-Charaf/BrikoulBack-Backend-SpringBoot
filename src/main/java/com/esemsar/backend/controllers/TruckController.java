package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.requests.TruckRequest;
import com.esemsar.backend.dtos.responses.TruckResponse;
import com.esemsar.backend.services.TruckService;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/trucks")
@PreAuthorize("hasRole('DRIVER')")
public class TruckController {
    private final TruckService truckService;

    public TruckController(TruckService truckService) {
        this.truckService = truckService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public TruckResponse create(@Valid @RequestBody TruckRequest request) {
        return truckService.create(request);
    }

    @GetMapping("/me")
    public List<TruckResponse> myTrucks() {
        return truckService.myTrucks();
    }

    @GetMapping("/{id}")
    public TruckResponse get(@PathVariable Long id) {
        return truckService.get(id);
    }

    @PutMapping("/{id}")
    public TruckResponse update(@PathVariable Long id, @Valid @RequestBody TruckRequest request) {
        return truckService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        truckService.delete(id);
    }

    @PatchMapping("/{id}/activate")
    public TruckResponse activate(@PathVariable Long id) {
        return truckService.setActive(id, true);
    }

    @PatchMapping("/{id}/deactivate")
    public TruckResponse deactivate(@PathVariable Long id) {
        return truckService.setActive(id, false);
    }
}
