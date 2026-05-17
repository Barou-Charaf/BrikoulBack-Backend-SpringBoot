package com.esemsar.backend.controllers;

import com.esemsar.backend.dtos.responses.AdminUserResponse;
import com.esemsar.backend.services.AdminService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/users")
public class AdminUserController {
    private final AdminService adminService;

    public AdminUserController(AdminService adminService) {
        this.adminService = adminService;
    }

    @GetMapping
    public Page<AdminUserResponse> users(Pageable pageable) {
        return adminService.users(pageable);
    }

    @GetMapping("/{id}")
    public AdminUserResponse user(@PathVariable Long id) {
        return adminService.user(id);
    }

    @PatchMapping("/{id}/lock")
    public AdminUserResponse lock(@PathVariable Long id) {
        return adminService.setLocked(id, true);
    }

    @PatchMapping("/{id}/unlock")
    public AdminUserResponse unlock(@PathVariable Long id) {
        return adminService.setLocked(id, false);
    }

    @PatchMapping("/{id}/enable")
    public AdminUserResponse enable(@PathVariable Long id) {
        return adminService.setEnabled(id, true);
    }

    @PatchMapping("/{id}/disable")
    public AdminUserResponse disable(@PathVariable Long id) {
        return adminService.setEnabled(id, false);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        adminService.deleteUser(id);
    }
}
