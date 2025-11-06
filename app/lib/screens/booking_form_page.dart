import 'package:flutter/material.dart';
import '../models/hall.dart';
import '../components/booking_date_time_picker.dart';
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
  final _eventTitleController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _guestDetailsController = TextEditingController();

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
    _eventTitleController.dispose();
    _eventDescriptionController.dispose();
    _guestDetailsController.dispose();
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
          'event_name': _eventTitleController.text.trim(),
          'event_description': _eventDescriptionController.text.trim(),
          'date': '${_startDateTime!.year}-${_startDateTime!.month.toString().padLeft(2, '0')}-${_startDateTime!.day.toString().padLeft(2, '0')}',
          'time_slot': timeSlot,
          'request_type': 'permissions',
          'guest_details': _guestDetailsController.text.trim(),
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: isRequired
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter $label';
                    }
                    return null;
                  }
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Details',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: 'Event Title',
                controller: _eventTitleController,
                hintText: 'Title of the event',
                isRequired: true,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'Event Description',
                controller: _eventDescriptionController,
                hintText: 'Detailed Description of event',
                maxLines: 4,
                isRequired: true,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'Guest Details',
                controller: _guestDetailsController,
                hintText: 'Guest Details',
                maxLines: 3,
                isRequired: false,
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Submit Booking Request',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}