import 'package:flutter/material.dart';

class BookingFeedbackDialog extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color iconColor;
  final String title;
  const BookingFeedbackDialog({super.key,
  required this.title,
  required this.message,
  this.icon=Icons.info,
  this.iconColor=Colors.deepPurple,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:Row(
        children: [
          Icon(icon,color:iconColor),
          const SizedBox(width:12),
          Text(title)
        ],
        ),
        content:Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('OK'),
      ),
    ],
    );
  }
}