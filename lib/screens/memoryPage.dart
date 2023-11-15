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
  Map<DateTime, List<dynamic>> _events = {}; // 날짜별 이벤트를 저장할 맵
  List<dynamic> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchPostsForMonth(_selectedDay); // 초기화할 때 한 달 동안의 게시물을 가져옵니다.
    _fetchPosts(_selectedDay); // 초기화할 때 오늘 날짜의 게시물을 가져옵니다.
  }

  void _fetchPostsForMonth(DateTime month) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Start of the month
    DateTime startDate = DateTime(month.year, month.month, 1).toUtc();

    // End of the month
    DateTime endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toUtc();

    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .collection('posts')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      Map<DateTime, List<dynamic>> events = {};

      for (var doc in querySnapshot.docs) {
        DateTime postDate = (doc['createdAt'] as Timestamp).toDate();
        DateTime postDateUtc = DateTime.utc(postDate.year, postDate.month, postDate.day);

        if (events[postDateUtc] == null) {
          events[postDateUtc] = [];
        }
        events[postDateUtc]!.add(doc.data());
      }

      if (mounted) {
        setState(() {
          _events = events; // Update events for the entire month
        });
      }
    } catch (e) {
      print(e);
    }
  }


  void _fetchPosts(DateTime date) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    DateTime startDate = DateTime(date.year, date.month, date.day).toUtc();
    DateTime endDate = DateTime(date.year, date.month, date.day, 23, 59, 59).toUtc();

    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .collection('posts')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      List<dynamic> newEvents = [];
      for (var doc in querySnapshot.docs) {
        newEvents.add(doc.data());
      }

      if (mounted) {
        setState(() {
          _events[_selectedDay] = newEvents; // Update events for the selected date
          _selectedEvents = newEvents;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = selectedDay;
      _selectedEvents = _events[selectedDay] ?? [];
    });
    _fetchPosts(selectedDay); // Fetch posts only for the selected date
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
              onDaySelected: _onDaySelected,
              eventLoader: _getEventsForDay, // 이벤트 로더 추가
            ),
            Expanded(
              child: _selectedEvents.isNotEmpty
                  ? ListView.builder(
                itemCount: _selectedEvents.length,
                itemBuilder: (context, index) {
                  final event = _selectedEvents[index];
                  return Card(
                    child: Container(
                      color: AppColors.primaryColor(),
                      child: ListTile(
                        title: Text(
                          event['text'] ?? 'No Content',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          (event['createdAt'] as Timestamp).toDate().toString(),
                        ),
                        trailing: event['imageUrl'] != null
                            ? Image.network(
                          event['imageUrl'],
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error);
                          },
                        )
                            : null,
                        onTap: () {
                          _showPostDialog(event);
                        },
                      ),
                    ),
                  );
                },
              )
                  : Center(
                child: Text('기록된 추억이 없습니다.'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostDialog(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.backColor(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (post['createdAt'] as Timestamp).toDate().toString(),
                        style: TextStyle(fontSize: 14),
                      ),
                      if (post['imageUrl'] != null)
                        Image.network(
                          post['imageUrl'],
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error);
                          },
                        ),
                      SingleChildScrollView(
                        child: Text(
                          post['text'] ?? 'No Content',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: AppColors.primaryColor(),
                  ),
                  child: Text('닫기'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final events = _events[day] ?? [];
    print("Events for $day: $events"); // 로깅
    return events;  }
}
