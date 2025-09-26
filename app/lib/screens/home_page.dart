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
  // hardcode hall list replace it with real backend logic
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
        title: const Text('Available Halls', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        automaticallyImplyLeading: false, // Removes back button
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
      body:  isLoading
    ? const Center(child: CircularProgressIndicator())
    : halls.isEmpty
        ? const Center(child: Text('No halls available', style: TextStyle(fontSize: 18)))
        : ListView.builder(
            itemCount: halls.length,
            itemBuilder: (context, index) {
              final hall = halls[index];
              return HallCard(
                hall: hall,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HallCalenderPage(hall: hall),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}