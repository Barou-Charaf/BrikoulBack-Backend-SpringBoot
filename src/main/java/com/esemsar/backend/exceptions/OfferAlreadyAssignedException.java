package com.esemsar.backend.exceptions;

public class OfferAlreadyAssignedException extends RuntimeException {
    public OfferAlreadyAssignedException(String message) {
        super(message);
    }
}
