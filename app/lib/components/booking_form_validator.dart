class BookingFormValidator {
  static String? validatePurpose(String? value) {
    if (value == null || value.isEmpty) {
      return 'purpose is required';
    }
    return null;
  }
  static String? validateTimeOrder(DateTime? startTime, DateTime? endTime) {
    if (startTime == null || endTime == null)
      {
        return 'Start and end times are required';
        }
    if (endTime.isBefore(startTime)) {
      return 'End time must be after start time';
    }
    return null;
  }
}
    