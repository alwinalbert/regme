import 'package:flutter/material.dart';
import '../models/hall.dart';
import '../components/booking_date_time_picker.dart';
import '../components/booking_purpose_field.dart';
import '../components/booking_form_validator.dart';
import '../components/booking_feedback_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookingFormPage extends StatefulWidget {
  final Hall hall;

  const BookingFormPage({super.key, required this.hall});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  final _purposeController = TextEditingController();

  Future<DateTime?> _pickDateTime(BuildContext context, DateTime? initialDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (date == null) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: initialDate != null
          ? TimeOfDay.fromDateTime(initialDate)
          : TimeOfDay.now(),
    );
    if (time == null) return null;
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

void _submit() async {
  if (_formKey.currentState?.validate() != true) return;

  var timeOrderError = BookingFormValidator.validateTimeOrder(_startDateTime, _endDateTime);
  if (_startDateTime == null || _endDateTime == null) {
    showDialog(
      context: context,
      builder: (_) => const BookingFeedbackDialog(
        title: 'Booking Error',
        message: 'Please select start and end times',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      ),
    );
    return;
  }
  if (timeOrderError != null) {
    showDialog(
      context: context,
      builder: (_) => BookingFeedbackDialog(
        title: 'Booking Error',
        message: timeOrderError,
        icon: Icons.error_outline,
        iconColor: Colors.red,
      ),
    );
    return;
  }

  // Send booking to backend
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    // Format time slot (e.g., "10:00-12:00")
    final startTime = "${_startDateTime!.hour.toString().padLeft(2, '0')}:${_startDateTime!.minute.toString().padLeft(2, '0')}";
    final endTime = "${_endDateTime!.hour.toString().padLeft(2, '0')}:${_endDateTime!.minute.toString().padLeft(2, '0')}";
    final timeSlot = "$startTime-$endTime";
    
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/bookings/'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'hall_id': int.parse(widget.hall.id),
        'event_name': _purposeController.text.trim(),
        'event_description': _purposeController.text.trim(),
        'date': '${_startDateTime!.year}-${_startDateTime!.month.toString().padLeft(2, '0')}-${_startDateTime!.day.toString().padLeft(2, '0')}',
        'time_slot': timeSlot,
        'request_type': 'permissions',
      }),
    );

    if (response.statusCode == 201) {
      showDialog(
        context: context,
        builder: (_) => const BookingFeedbackDialog(
          title: 'Booking Successful',
          message: 'Your booking request has been submitted for approval',
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
        ),
      ).then((_) => Navigator.pop(context));
    } else {
      throw Exception('Failed to create booking');
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (_) => BookingFeedbackDialog(
        title: 'Booking Error',
        message: 'Failed to submit booking: $e',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.hall.name}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              BookingDateTimePicker(
                label: 'Start Date & Time',
                dateTime: _startDateTime,
                onTap: () async {
                  final selected = await _pickDateTime(context, _startDateTime);
                  if (selected != null) setState(() => _startDateTime = selected);
                },
              ),
              BookingDateTimePicker(
                label: 'End Date & Time',
                dateTime: _endDateTime,
                onTap: () async {
                  final selected = await _pickDateTime(context, _endDateTime);
                  if (selected != null) setState(() => _endDateTime = selected);
                },
              ),
              const SizedBox(height: 12),
              BookingPurposeField(controller: _purposeController),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit Booking Request'),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
