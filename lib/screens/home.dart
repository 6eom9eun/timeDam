import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memo_re/screens/writePage.dart';
import 'package:memo_re/widgets/postbox_widget.dart';

final firestore = FirebaseFirestore.instance;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 프로필 사진 보여주는 CircleAvatar
                CircleAvatar(
                  backgroundImage: AssetImage('assets/profile_image.png'),
                  radius: 35, // 반지름 설정
                  backgroundColor: Colors.transparent,
                ),
                Text(
                  'user name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'remind your memory',
                  style: TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 15),
                buildGrid(20), // postbox_widget
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => WritePage()),
          );
        },
        child: Icon(Icons.create, size: 35), // 아이콘 크기 조정
        backgroundColor: Colors.amber[800],
        elevation: 10, // 그림자 강도
        highlightElevation: 15, // 버튼을 눌렀을 때 그림자 강도
      ),
    );
  }
}
