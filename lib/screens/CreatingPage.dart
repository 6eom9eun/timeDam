import 'package:flutter/material.dart';
import 'package:memo_re/utils//vars.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CreatingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50], // 배경색을 노란색으로 설정
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitWaveSpinner(
              color: Color(0xFFFFCF52),
              size: 200.0,
            ),
            SizedBox(height: 20),
            Text(
              '추억 생성 중...',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            SizedBox(height: 30),
            Text(
              '소중한 추억을 담아 추억을 \n이어가는 중이에요',
              style: TextStyle(
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
