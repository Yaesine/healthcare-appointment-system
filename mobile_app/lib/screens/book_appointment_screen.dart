import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/appointment_provider.dart';
import '../models/appointment.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Appointment? appointment;

  const BookAppointmentScreen({super.key, this.appointment});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorNameController = TextEditingController();
  final _reasonController = TextEditingController();
  DateTime? _selectedDateTime;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      _doctorNameController.text = widget.appointment!.doctorName;
      _reasonController.text = widget.appointment!.reason ?? '';
      _selectedDateTime = widget.appointment!.appointmentDateTime;
      _selectedTime = TimeOfDay.fromDateTime(_selectedDateTime!);
    }
  }

  @override
  void dispose() {
    _doctorNameController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = picked;
      });
      _selectTime();
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        if (_selectedDateTime != null) {
          _selectedDateTime = DateTime(
            _selectedDateTime!.year,
            _selectedDateTime!.month,
            _selectedDateTime!.day,
            picked.hour,
            picked.minute,
          );
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDateTime!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment time must be in the future'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final appointmentProvider =
        Provider.of<AppointmentProvider>(context, listen: false);

    final appointment = Appointment(
      id: widget.appointment?.id,
      userId: widget.appointment?.userId ?? 0,
      doctorName: _doctorNameController.text.trim(),
      appointmentDateTime: _selectedDateTime!,
      reason: _reasonController.text.trim().isEmpty
          ? null
          : _reasonController.text.trim(),
      status: widget.appointment?.status ?? 'SCHEDULED',
    );

    bool success;
    if (widget.appointment != null && widget.appointment!.id != null) {
      success = await appointmentProvider.updateAppointment(
        widget.appointment!.id!,
        appointment,
      );
    } else {
      success = await appointmentProvider.createAppointment(appointment);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.appointment != null
              ? 'Appointment updated successfully'
              : 'Appointment booked successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appointmentProvider.error ?? 'Failed to save appointment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appointment != null
            ? 'Edit Appointment'
            : 'Book Appointment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _doctorNameController,
                decoration: const InputDecoration(
                  labelText: 'Doctor Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                  hintText: 'Enter doctor\'s name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter doctor\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date & Time',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDateTime != null
                        ? DateFormat('MMM dd, yyyy • hh:mm a')
                            .format(_selectedDateTime!)
                        : 'Select date and time',
                    style: TextStyle(
                      color: _selectedDateTime != null
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (Optional)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                  hintText: 'Enter reason for appointment',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              Consumer<AppointmentProvider>(
                builder: (context, appointmentProvider, _) {
                  return ElevatedButton(
                    onPressed: appointmentProvider.isLoading
                        ? null
                        : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: appointmentProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.appointment != null
                                ? 'Update Appointment'
                                : 'Book Appointment',
                            style: const TextStyle(fontSize: 16),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

