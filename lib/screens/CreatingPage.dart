import 'package:flutter/material.dart';
import 'package:memo_re/utils/vars.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CreatingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: AppColors.backColor(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitWaveSpinner(
              color: Color(0xFFFFCF52),
              size: 200.0,
            ),
            SizedBox(height: 40),
            Text(
              '  추억 생성 중...',
              style: TextStyle(
                fontFamily: 'Cafe',
                fontSize: 40,
                color: Color(0xFF333333),
              ),
            ),
            SizedBox(height: 50),
            Text(
              '소중한 추억의 발자국을 \n따라가는 중이에요',
              style: TextStyle(
                fontFamily: 'CafeAir',
                fontSize: 18,
                color: Color(0xff777777),
              ),
              textAlign: TextAlign.center,
            ),
            // SizedBox(height: 20),
            // Image.asset('assets/logo.png',width: 80, height: 80),
          ],
        ),
      ),
    );
  }
}
