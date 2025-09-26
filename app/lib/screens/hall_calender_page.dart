import 'package:app/screens/booking_form_page.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/hall.dart';
import '../models/booking.dart';
import '../components/booking_data_source.dart';
import '../components/appointment_builder.dart';
import '../components/calendar_tap_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HallCalenderPage extends StatefulWidget {
  final Hall hall;
  const HallCalenderPage({super.key, required this.hall});

  @override
  State<HallCalenderPage> createState() => _HallCalenderPageState();
}

class _HallCalenderPageState extends State<HallCalenderPage> {
  // Replace with backend data 
 List<Booking> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/bookings/?hall_id=${widget.hall.id}'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        bookings = data.map((bookingJson) {
          // Parse date and time_slot to create DateTime objects
          final date = bookingJson['date'] as String; // e.g., "2025-09-30"
          final timeSlot = bookingJson['time_slot'] as String; // e.g., "10:00-15:00"
          
          // Split the time slot
          final times = timeSlot.split('-');
          final startTimeStr = times[0]; // "10:00"
          final endTimeStr = times.length > 1 ? times[1] : startTimeStr; // "15:00"
          
          // Create DateTime objects
          final startTime = DateTime.parse('${date}T${startTimeStr}:00');
          final endTime = DateTime.parse('${date}T${endTimeStr}:00');
          
          return Booking(
            id: bookingJson['id'].toString(),
            startTime: startTime,
            endTime: endTime,
            title: bookingJson['event_name'] ?? 'No Title',
            status: bookingJson['status'] ?? 'pending',
          );
        }).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Error fetching bookings: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print('Exception while fetching bookings: $e');
  }
}
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
        onPressed: () async {
          final newBooking = await Navigator.push<Booking>(
            context,
            MaterialPageRoute(
              builder: (context) => BookingFormPage(hall: widget.hall),
            ),
          );
          if (newBooking != null) {
            setState(() {
              bookings.add(newBooking);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Booking for "${newBooking.title}" submitted!')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Book Hall'),
        backgroundColor: Colors.deepPurpleAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : Stack(
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