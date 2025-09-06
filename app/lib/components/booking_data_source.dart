import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/booking.dart';
import 'package:flutter/material.dart';


class BookingDataSource extends CalendarDataSource {
  BookingDataSource(List<Booking> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => (appointments![index] as Booking).startTime;

  @override
  DateTime getEndTime(int index) => (appointments![index] as Booking).endTime;

  @override
  String getSubject(int index) => (appointments![index] as Booking).title;

  @override
  Color getColor(int index) =>
      (appointments![index] as Booking).status == 'approved' ? Colors.green : Colors.orange;

  @override
  bool isAllDay(int index) => false;
}