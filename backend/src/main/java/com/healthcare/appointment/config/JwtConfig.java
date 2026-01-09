package com.healthcare.appointment.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class JwtConfig {
    
    @Value("${jwt.secret:your-256-bit-secret-key-for-jwt-token-generation-must-be-at-least-256-bits}")
    private String secret;
    
    @Value("${jwt.expiration:86400000}") // 24 hours
    private long expiration;

    public String getSecret() {
        return secret;
    }

    public long getExpiration() {
        return expiration;
    }
}

