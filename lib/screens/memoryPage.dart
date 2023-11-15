import 'package:flutter/material.dart';
import 'package:memo_re/widgets/calendar2_widget.dart';
import 'package:provider/provider.dart';
import 'package:memo_re/providers/memoryProvider.dart'; // MemoryProvider import
import 'package:memo_re/utils/vars.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    Provider.of<MemoryProvider>(context, listen: false).fetchPostsForMonth(_selectedDay);
    Provider.of<MemoryProvider>(context, listen: false).fetchPosts(_selectedDay);
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = selectedDay;
    });
    Provider.of<MemoryProvider>(context, listen: false).fetchPosts(selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MemoryProvider>(context);
    final _events = provider.events;
    final _selectedEvents = _events[_selectedDay] ?? [];

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
              eventLoader: (day) => _getEventsForDay(day, _events), // 이벤트 로더 수정
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
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '기록된 추억이 없어요.',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  SizedBox(height: 10,),
                  Image.asset(
                    'assets/logo.png', // 이미지 파일 경로
                    width: 80, // 이미지 크기 조정
                    height: 80,
                  ),
                ],
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

  List<dynamic> _getEventsForDay(DateTime day, Map<DateTime, List<dynamic>> events) {
    return events[day] ?? [];
  }
}
