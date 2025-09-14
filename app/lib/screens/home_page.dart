import 'package:app/models/hall.dart';
import 'package:app/screens/hall_calender_page.dart';
import 'package:app/screens/profile_screen.dart';
import 'package:app/widgets/hall.dart';
import 'package:flutter/material.dart';

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
  final List<Hall> halls = [
    Hall(
      id: '1',
      name: 'CCF Hall',
      isBooked: false,
      imageUrl: 'assets/images/mec.jpeg',
    ),
    Hall(
      id: '2',
      name: 'Media Hall',
      isBooked: true,
      imageUrl: 'assets/images/mec2.JPG',
    ),
    Hall(
      id: '3',
      name: 'Internal Auditorium',
      isBooked: false,
      imageUrl: 'assets/images/mec3.jpg',
    ),
    // Add more halls as needed
  ];
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
      body: Column(
        children: [
          Expanded(
            child: halls.isEmpty
                ? const Center(
                    child: Text(
                      'No halls available',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
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
          ),
        ],
      ),
    );
  }
}