import 'package:flutter/material.dart';
import 'package:memo_re/screens/mainPage.dart';
import 'package:memo_re/screens/loginPage.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainPage(),
      },
      initialRoute: '/login', //초기 라우트
      home: const LoginPage(),
      theme: ThemeData(
        fontFamily: 'CafeAir',
      ),
      onGenerateRoute: _getRoute,
    );
  }

  Route<dynamic>? _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => const LoginPage(),
      fullscreenDialog: true,
    );
  }
}