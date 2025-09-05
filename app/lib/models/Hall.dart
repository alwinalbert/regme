class Hall {
  final String id;
  final String name;
  //final String location;
  final bool isBooked;
  final String? imageUrl;
Hall({
  required this.id,
  required this.name,
  this.isBooked = false,
  this.imageUrl,   
});
}