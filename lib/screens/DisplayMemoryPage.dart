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
          '생성된 추억',
          style: TextStyle(fontFamily:'Gugi',fontSize: 35.0),
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
            Text(
              memory,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}