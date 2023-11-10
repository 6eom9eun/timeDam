import 'package:flutter/material.dart';
import 'package:memo_re/widgets/calendar2_widget.dart';
import 'package:provider/provider.dart';
import 'package:memo_re/providers/postProvider.dart';
import 'package:memo_re/utils/vars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<dynamic>> _events = {};
  List<dynamic> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts(_selectedDay); // 초기화할 때 오늘 날짜의 게시물을 가져옵니다.
  }

  // 이제 _fetchPosts는 특정 날짜의 게시물만 가져옵니다.
  void _fetchPosts(DateTime date) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    DateTime dateKey = DateTime(date.year, date.month, date.day);
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .collection('posts')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(dateKey))
          .where('createdAt', isLessThan: Timestamp.fromDate(dateKey.add(Duration(days: 1))))
          .get();

      List<dynamic> newEvents = [];
      for (var doc in querySnapshot.docs) {
        newEvents.add(doc.data());
      }
      if (mounted) {
        setState(() {
          _events[dateKey] = newEvents;
          _selectedEvents = newEvents;
        });
      }
    } catch (e) {
      // Handle any errors here
      print(e);
    }
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = selectedDay; // You may still want to update _focusedDay if necessary
      _selectedEvents = _events[selectedDay] ?? [];
    });
    _fetchPosts(selectedDay); // Fetch posts for the selected day
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backColor(),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 90),
            Calendar2(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              onDaySelected: (selectedDay) {
                _onDaySelected(selectedDay);
              },
            ),
            Expanded(
              child: _selectedEvents.isNotEmpty
                  ? ListView.builder(
                itemCount: _selectedEvents.length,
                itemBuilder: (context, index) {
                  final event = _selectedEvents[index];
                  return Card(
                    child: ListTile(
                      title: Text(event['text'] ?? 'No Content'),
                      subtitle: Text(
                        (event['createdAt'] as Timestamp).toDate().toString(),
                      ),
                      trailing: event['imageUrl'] != null
                          ? Image.network(
                        event['imageUrl'],
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error);
                        },
                      )
                          : null,
                    ),
                  );
                },
              )
                  : Center(
                child: Text('No events found for this day.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
