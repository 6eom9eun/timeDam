import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memo_re/mainpages/mainpage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


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
    await Future.delayed(Duration(seconds: 2)); // 2초 동안 대기
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MainPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          var tween = Tween(begin: begin, end: end);
          var fadeAnimation = animation.drive(tween);
          return FadeTransition(
            opacity: fadeAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: SpinKitPouringHourGlassRefined(
              color: Color(0xFFF4B353),
              size: 100.0,
            ),
          ),
          SpinKitPouringHourGlassRefined(
              color: Color(0xFFF4B353),
              size: 100.0,
          ),
        ],
      ),
    );
  }
}