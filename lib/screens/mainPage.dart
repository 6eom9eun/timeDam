import 'package:flutter/material.dart';
import 'package:memo_re/screens/home.dart';
import 'package:memo_re/screens/memoryPage.dart';
import 'package:memo_re/screens/placePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memo_re/widgets/appDrawer.dart';
import 'package:memo_re/utils/vars.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 1;
  List<BottomNavigationBarItem> bottomItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_month),
      label: '달력',
    ),
    BottomNavigationBarItem(
      label: '추억',
      icon: Icon(Icons.home_filled, size: 30.0),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.place),
      label: '장소',
    ),
  ];

  List<Widget> pages = [
    MemoryPage(),
    Home(),
    PlacePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.black, // Drawer 아이콘과 다른 앱바 아이콘의 색상을 검정색으로 설정
        ),
      ),
      drawer: AppDrawer(),
      bottomNavigationBar: Container(
        height: 80.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 0,
              blurRadius: 5,
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.primaryColor(),
          selectedItemColor: AppColors.backColor(),
          unselectedItemColor: Colors.black87,
          selectedFontSize: 20,
          unselectedFontSize: 20,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20, // You can also set font size here
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: bottomItems,
        ),
      ),
      body: pages[_selectedIndex],
    );
  }
}
