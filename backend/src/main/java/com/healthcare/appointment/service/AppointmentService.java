package com.healthcare.appointment.service;

import com.healthcare.appointment.dto.AppointmentRequest;
import com.healthcare.appointment.dto.AppointmentResponse;
import com.healthcare.appointment.model.Appointment;
import com.healthcare.appointment.repository.AppointmentRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class AppointmentService {

    private final AppointmentRepository appointmentRepository;

    public AppointmentService(AppointmentRepository appointmentRepository) {
        this.appointmentRepository = appointmentRepository;
    }

    @Transactional
    public AppointmentResponse createAppointment(Long userId, AppointmentRequest request) {
        // Validate appointment time is in the future
        if (request.getAppointmentDateTime().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("Appointment time must be in the future");
        }

        // Check if doctor is already booked at this time
        if (appointmentRepository.existsByAppointmentDateTimeAndDoctorName(
                request.getAppointmentDateTime(), request.getDoctorName())) {
            throw new IllegalArgumentException("Doctor is already booked at this time");
        }

        Appointment appointment = new Appointment();
        appointment.setUserId(userId);
        appointment.setDoctorName(request.getDoctorName());
        appointment.setAppointmentDateTime(request.getAppointmentDateTime());
        appointment.setReason(request.getReason());

        appointment = appointmentRepository.save(appointment);
        return mapToResponse(appointment);
    }

    public List<AppointmentResponse> getUserAppointments(Long userId) {
        return appointmentRepository.findByUserId(userId)
                .stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public AppointmentResponse getAppointmentById(Long appointmentId, Long userId) {
        Appointment appointment = appointmentRepository.findById(appointmentId)
                .orElseThrow(() -> new RuntimeException("Appointment not found"));

        // Security: User can only access their own appointments
        if (!appointment.getUserId().equals(userId)) {
            throw new RuntimeException("Access denied: You can only access your own appointments");
        }

        return mapToResponse(appointment);
    }

    @Transactional
    public AppointmentResponse updateAppointment(Long appointmentId, Long userId, AppointmentRequest request) {
        Appointment appointment = appointmentRepository.findById(appointmentId)
                .orElseThrow(() -> new RuntimeException("Appointment not found"));

        // Security: User can only modify their own appointments
        if (!appointment.getUserId().equals(userId)) {
            throw new RuntimeException("Access denied: You can only modify your own appointments");
        }

        // Validate appointment time is in the future
        if (request.getAppointmentDateTime().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("Appointment time must be in the future");
        }

        // Check if doctor is already booked at this time (excluding current appointment)
        if (appointmentRepository.existsByAppointmentDateTimeAndDoctorName(
                request.getAppointmentDateTime(), request.getDoctorName())) {
            // Check if it's the same appointment
            Appointment existing = appointmentRepository.findByUserId(userId)
                    .stream()
                    .filter(a -> a.getAppointmentDateTime().equals(request.getAppointmentDateTime()) 
                            && a.getDoctorName().equals(request.getDoctorName()))
                    .findFirst()
                    .orElse(null);
            
            if (existing == null || !existing.getId().equals(appointmentId)) {
                throw new IllegalArgumentException("Doctor is already booked at this time");
            }
        }

        appointment.setDoctorName(request.getDoctorName());
        appointment.setAppointmentDateTime(request.getAppointmentDateTime());
        appointment.setReason(request.getReason());

        appointment = appointmentRepository.save(appointment);
        return mapToResponse(appointment);
    }

    @Transactional
    public void cancelAppointment(Long appointmentId, Long userId) {
        Appointment appointment = appointmentRepository.findById(appointmentId)
                .orElseThrow(() -> new RuntimeException("Appointment not found"));

        // Security: User can only cancel their own appointments
        if (!appointment.getUserId().equals(userId)) {
            throw new RuntimeException("Access denied: You can only cancel your own appointments");
        }

        appointment.setStatus("CANCELLED");
        appointmentRepository.save(appointment);
    }

    private AppointmentResponse mapToResponse(Appointment appointment) {
        return new AppointmentResponse(
                appointment.getId(),
                appointment.getUserId(),
                appointment.getDoctorName(),
                appointment.getAppointmentDateTime(),
                appointment.getReason(),
                appointment.getStatus(),
                appointment.getCreatedAt()
        );
    }
}

