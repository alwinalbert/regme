import 'package:flutter/material.dart';

class BookingDateTimePicker extends StatelessWidget {
  final String label;
  final DateTime? dateTime;
  final VoidCallback onTap;
  const BookingDateTimePicker({super.key,
  required this.label,
   required this.dateTime,
    required this.onTap
    });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(dateTime ==null? label:'$label: ${dateTime.toString()}'),
      trailing: Icon(Icons.calendar_today),
      onTap: onTap,
    );
  }
}