import 'package:flutter/material.dart';
import 'package:memo_re/screens/home.dart';
import 'package:memo_re/screens/memoryPage.dart';
import 'package:memo_re/screens/myPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memo_re/widgets/appDrawer.dart';
import 'package:memo_re/utils/vars.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  List<BottomNavigationBarItem> bottomItems = [
    BottomNavigationBarItem(
      label: '홈',
      icon: Icon(Icons.home_filled, size: 30.0),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.library_books_rounded),
      label: '목록',
    ),
    BottomNavigationBarItem(
      label: '내 페이지',
      icon: Icon(Icons.account_circle, size: 30.0),
    ),
  ];

  List<Widget> pages = [
    Home(),
    MemoryPage(),
    MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,  // 이 부분을 주석 처리하거나 삭제합니다.
        backgroundColor: AppColors.primaryColor(),
        title: Text(
          '메모:re',
          style: TextStyle(fontFamily: 'Gugi', fontSize: 35.0),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await FirebaseAuth.instance
                .signOut()
                .then((_) => Navigator.pushNamed(context, "/login")),
          ),
        ],
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
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey.withOpacity(.60),
          selectedFontSize: 14,
          unselectedFontSize: 10,
          currentIndex: _selectedIndex,
          showUnselectedLabels: false,
          showSelectedLabels: false,
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
