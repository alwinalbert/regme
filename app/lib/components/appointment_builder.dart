import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/booking.dart';

Widget appointmentBuilder(BuildContext context, CalendarAppointmentDetails details) {
  final Booking booking = details.appointments.first;
    return Card(
      color: booking.status == 'approved' ? Colors.green : Colors.orange,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(Icons.event, color: Colors.white, size: 32),
        title: Text(
          booking.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          '${booking.startTime.hour.toString().padLeft(2,'0')}:${booking.startTime.minute.toString().padLeft(2,'0')} - '
          '${booking.endTime.hour.toString().padLeft(2,'0')}:${booking.endTime.minute.toString().padLeft(2,'0')}',
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

