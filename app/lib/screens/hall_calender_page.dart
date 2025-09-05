import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/hall.dart';
import '../models/booking.dart';

// Modular components imports
import '../components/booking_data_source.dart';
import '../components/appointment_builder.dart';
import '../components/calendar_tap_handler.dart';

class HallCalenderPage extends StatefulWidget {
  final Hall hall;
  const HallCalenderPage({super.key, required this.hall});

  @override
  State<HallCalenderPage> createState() => _HallCalenderPageState();
}

class _HallCalenderPageState extends State<HallCalenderPage> {
  // Replace with real backend data fetching
  List<Booking> bookings = [
    Booking(
      id: '1',
      startTime: DateTime.now().add(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 2)),
      title: 'Workshop',
      status: 'approved',
    ),
    Booking(
      id: '2',
      startTime: DateTime.now().add(const Duration(hours: 3)),
      endTime: DateTime.now().add(const Duration(hours: 4)),
      title: 'Seminar',
      status: 'pending',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.hall.name),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to booking form page
        },
        icon: const Icon(Icons.add),
        label: const Text('Book Hall'),
        backgroundColor: Colors.deepPurpleAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/bg.jpeg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            color: Colors.black.withOpacity(0.6),
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: SfCalendar(
              view: CalendarView.schedule,
              dataSource: BookingDataSource(bookings),
              onTap: (details) => calendarTapped(context, details),
              appointmentBuilder: appointmentBuilder,
              scheduleViewSettings: ScheduleViewSettings(
                appointmentItemHeight: 72,
                monthHeaderSettings: MonthHeaderSettings(
                  backgroundColor: Colors.deepPurpleAccent.shade200.withOpacity(0.8),
                  textAlign: TextAlign.left,
                  monthTextStyle: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                weekHeaderSettings: WeekHeaderSettings(
                  height: 40,
                  backgroundColor: Colors.deepPurpleAccent.shade100.withOpacity(0.6),
                  weekTextStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
              todayHighlightColor: Colors.deepPurpleAccent,
              todayTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}