import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memo_re/mainpages/mainpage.dart';


class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    _navigateToMainPage();
  }

  _navigateToMainPage() async {
    await Future.delayed(Duration(seconds: 2)); // 3초 동안 대기
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Container(
              width: 100.0,
              height: 100.0,
              child: Image.asset('assets/image/landing.png'),
            ),
          ),
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}