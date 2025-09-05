class Booking{
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String title;
  final String status;
  
  Booking({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.title,
    this.status = 'approved',
  });
}