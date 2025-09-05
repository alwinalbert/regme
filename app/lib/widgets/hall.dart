import 'package:app/models/Hall.dart';
import 'package:flutter/material.dart';

class HallCard extends StatelessWidget {
  const HallCard({super.key,
  required this.hall,
  required this.onTap,});

  final Hall hall;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8,horizontal:16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child:InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap:onTap,
        child:Container(
          padding: const EdgeInsets.all(12),
          child:Row(
            children:[
              ClipRRect(
                borderRadius:BorderRadius.circular(15),
                child:hall.imageUrl!=null && hall.imageUrl!.isNotEmpty
                  ?Image.asset(
                    hall.imageUrl!,
                    width:80,
                    height:80,
                    fit:BoxFit.cover,
                  )
                  :Container(
                    width:80,
                    height:80,
                    color:Colors.grey,
                    child:Icon(Icons.image_not_supported),
                  ),
              ),
              const SizedBox(width:16),
              Expanded(
                child:Column(
                  crossAxisAlignment:CrossAxisAlignment.start,
                  children:[
                    Text(
                      hall.name,
                      style:TextStyle(
                        fontSize:20,
                        fontWeight:FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height:8),
                    Text(
                      hall.isBooked ? 'Booked' : 'Available',
                      style:TextStyle(
                        color:hall.isBooked ? Colors.red : Colors.green,
                        fontWeight:FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon( Icons.arrow_forward_ios, size:18, color:Colors.black54), 
            ],
          ),
        ),
      ),
    );
  }
}