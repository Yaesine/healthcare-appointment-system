class Appointment {
  final int? id;
  final int userId;
  final String doctorName;
  final DateTime appointmentDateTime;
  final String? reason;
  final String status;
  final DateTime? createdAt;

  Appointment({
    this.id,
    required this.userId,
    required this.doctorName,
    required this.appointmentDateTime,
    this.reason,
    required this.status,
    this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as int?,
      userId: json['userId'] as int,
      doctorName: json['doctorName'] as String,
      appointmentDateTime: DateTime.parse(json['appointmentDateTime'] as String),
      reason: json['reason'] as String?,
      status: json['status'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorName': doctorName,
      'appointmentDateTime': appointmentDateTime.toIso8601String(),
      'reason': reason,
    };
  }
}

