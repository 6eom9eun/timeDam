import 'package:flutter/material.dart';
import 'package:memo_re/utils//vars.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SpinKitWaveSpinner(
          color: Color(0xFFFFCF52),
          size: 200.0,
        ),
      ),
    );
  }
}
