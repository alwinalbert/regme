import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/booking.dart';

void calendarTapped(BuildContext context, CalendarTapDetails details) {
  if (details.targetElement == CalendarElement.appointment) {
    final Booking booking = details.appointments!.first;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Wrap(
          children: [
            Text(
              booking.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Start: ${booking.startTime}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text('End: ${booking.endTime}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Status: ${booking.status}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
                style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
