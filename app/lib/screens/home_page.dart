import 'package:app/models/hall.dart';
import 'package:app/screens/booking_list_screen.dart';
import 'package:app/screens/hall_calender_page.dart';
import 'package:app/screens/profile_screen.dart';
import 'package:app/widgets/hall.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  final String username;
  final String email;
  final String role;
  const HomePage({super.key,
   required this.username,
   required this.email,
   required this.role,
   });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Hall? selectedHall;
 List<Hall> halls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHalls();
  }

  Future<void> fetchHalls() async {
    try {
      // Get the stored JWT token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/halls/'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          halls = data.map((hallJson) => Hall(
            id: hallJson['id'].toString(),
            name: hallJson['name'] ?? '',
            isBooked: hallJson['is_booked'] ?? false,
            imageUrl: hallJson['image_url'] ?? '', // Adjust field names as per your backend
          )).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // Handle error (show snackbar, etc.)
        print('Error fetching halls: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Exception while fetching halls: $e');
    }
  }
      @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Venue', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (widget.role == 'principal' || widget.role == 'admin')
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingsListScreen(role: widget.role),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    username: widget.username,
                    email: widget.email,
                    role: widget.role,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : halls.isEmpty
              ? const Center(child: Text('No halls available', style: TextStyle(fontSize: 18)))
              : Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          childAspectRatio: 1.2, // Makes rectangles instead of perfect squares
                          physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                          shrinkWrap: true, // Take only needed space
                          children: halls.map((hall) {
                            final isSelected = selectedHall?.id == hall.id;
                            
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedHall = hall;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.deepPurple : Colors.indigo,
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: isSelected 
                                    ? Border.all(color: Colors.white, width: 3.0)
                                    : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4.0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 24.0,
                                        ),
                                      if (isSelected) const SizedBox(height: 8.0),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          hall.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: selectedHall != null
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HallCalenderPage(hall: selectedHall!),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedHall != null ? Colors.deepPurple : Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: Text(
                            selectedHall != null 
                                ? 'Select Date & Time for ${selectedHall!.name}'
                                : 'Select a hall first',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
