package com.esemsar.backend.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;

@Slf4j
@Configuration
public class ImageStorageSchemaConfig {

    @Bean
    ApplicationRunner widenImageColumns(JdbcTemplate jdbcTemplate) {
        return args -> {
            widenColumn(jdbcTemplate, "users", "profile_image_url");
            widenColumn(jdbcTemplate, "truck", "image_url");
        };
    }

    private void widenColumn(JdbcTemplate jdbcTemplate, String tableName, String columnName) {
        try {
            jdbcTemplate.execute("ALTER TABLE " + tableName + " MODIFY COLUMN " + columnName + " LONGTEXT NULL");
            log.info("Ensured {}.{} can store gallery images", tableName, columnName);
        } catch (Exception exception) {
            log.warn("Could not widen {}.{} for gallery images: {}", tableName, columnName, exception.getMessage());
        }
    }
}
