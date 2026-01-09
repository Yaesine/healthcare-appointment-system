package com.healthcare.appointment.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AppointmentResponse {
    private Long id;
    private Long userId;
    private String doctorName;
    private LocalDateTime appointmentDateTime;
    private String reason;
    private String status;
    private LocalDateTime createdAt;
}

