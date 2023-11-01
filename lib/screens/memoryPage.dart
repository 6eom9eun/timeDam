import 'package:flutter/material.dart';
import 'package:memo_re/widgets/calendar2_widget.dart';
import 'package:provider/provider.dart';
import 'package:memo_re/providers/postProvider.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = selectedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 90),
            Calendar2(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              onDaySelected: _onDaySelected,
            ),
          ],
        ),
      ),
    );
  }
}