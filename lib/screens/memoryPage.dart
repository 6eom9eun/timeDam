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
      backgroundColor: Colors.yellow[50],
      body: Center(
        child: Column(
          children: [
            Calendar2(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              onDaySelected: _onDaySelected,
            ),

            // 이거 post 보여지는 거 위젯화 필요.
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Consumer<PostProvider>(
                  builder: (context, postProvider, child) {
                    return Column(
                      children: [
                        if (postProvider.imageUrl != null)
                          Container(
                            width: double.infinity,
                            height: 200,
                            child: Image.network(
                              postProvider.imageUrl!,
                              fit: BoxFit.fill,
                            ),
                          )
                        else
                          Text('No image selected.'),
                        SizedBox(height: 20), // 이미지와 텍스트 사이의 간격
                        if (postProvider.text != null && postProvider.text!.isNotEmpty)
                          Text(
                            postProvider.text!,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )
                        else
                          Text('No text available.')
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}