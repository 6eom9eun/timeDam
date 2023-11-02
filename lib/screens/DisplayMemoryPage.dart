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
            fontFamily:'GODO',
            fontWeight: FontWeight.bold,
            fontSize: 50.0,
            color: Colors.black54,
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
                  fontSize: 14,
                  fontFamily: 'Noto_Sans_KR',
                  // fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 업로드 버튼이 눌렸을 때 수행할 동작을 추가
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.amber[800],
                  ),
                  child: Text('업로드'),
                ),
                SizedBox(width: 20), // 업로드 버튼과 공유 버튼 사이의 간격 조절
                ElevatedButton(
                  onPressed: () {
                    // 공유 버튼이 눌렸을 때 수행할 동작을 추가
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.amber[800],
                  ),
                  child: Text('공유'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}