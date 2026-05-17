package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.requests.AdminCreateRequest;
import com.esemsar.backend.dtos.responses.AdminUserResponse;
import com.esemsar.backend.services.AdminService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/super-admin/admins")
public class SuperAdminController {
    private final AdminService adminService;

    public SuperAdminController(AdminService adminService) {
        this.adminService = adminService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public AdminUserResponse create(@Valid @RequestBody AdminCreateRequest request) {
        return adminService.createAdmin(request);
    }

    @GetMapping
    public Page<AdminUserResponse> admins(Pageable pageable) {
        return adminService.admins(pageable);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        adminService.deleteAdmin(id);
    }
}
