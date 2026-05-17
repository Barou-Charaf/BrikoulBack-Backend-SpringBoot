package com.esemsar.backend.dtos.responses;

public record AiChatResponse(
    String message,
    AiExtractedFilters extractedFilters,
    AiSearchResultResponse results
) {
}
