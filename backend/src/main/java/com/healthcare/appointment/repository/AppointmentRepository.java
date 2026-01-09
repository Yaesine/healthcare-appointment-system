package com.healthcare.appointment.repository;

import com.healthcare.appointment.model.Appointment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AppointmentRepository extends JpaRepository<Appointment, Long> {
    List<Appointment> findByUserId(Long userId);
    List<Appointment> findByUserIdAndAppointmentDateTimeAfter(Long userId, LocalDateTime dateTime);
    boolean existsByAppointmentDateTimeAndDoctorName(LocalDateTime dateTime, String doctorName);
}

