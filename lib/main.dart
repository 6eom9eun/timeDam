import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memo_re/landingpage.dart';
import 'package:memo_re/mainpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/LandingPage',
      // Set this if you want your app to start on MainPage
      getPages: [
        GetPage(name: '/', page: () => LandingPage()),
        GetPage(name: '/MainPage', page: () => MainPage()),
      ],
    );
  }
}