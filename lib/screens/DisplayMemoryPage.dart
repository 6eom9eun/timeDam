import 'package:flutter/material.dart';
import 'package:memo_re/utils/vars.dart';


class DisplayMemoryPage extends StatelessWidget {
  final String memory;
  final String imageUrl;

  DisplayMemoryPage({required this.memory, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor(), // 앱바의 색상 설정
        title: Text(
          '추억 생성 완료!',
          style: TextStyle(
              fontFamily:'Noto_Sans_KR',
              fontWeight: FontWeight.bold,
              fontSize: 32.0,
              color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(imageUrl),
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20), // 좌우 여백 조절
              child: Text(
                memory,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'S-Core',
                  // fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}