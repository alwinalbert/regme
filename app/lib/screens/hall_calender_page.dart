import 'package:app/models/Hall.dart';
import 'package:flutter/material.dart';

class HallCalenderPage extends StatefulWidget {
  final Hall hall;
  const HallCalenderPage({super.key,required this.hall});

  @override
  State<HallCalenderPage> createState() => _HallCalenderPageState();
}

class _HallCalenderPageState extends State<HallCalenderPage> {

  @override
  Widget build(BuildContext context) {
    return const Text('Hall Calender Page');
  }
}