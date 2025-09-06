import 'package:app/components/booking_form_validator.dart';
import 'package:flutter/material.dart';

class BookingPurposeField extends StatelessWidget {
  final TextEditingController controller;
  const BookingPurposeField({super.key,required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Purpose',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      validator: BookingFormValidator.validatePurpose,
    );
  }
}