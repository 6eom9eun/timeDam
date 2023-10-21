import 'package:flutter/material.dart';
import 'package:memo_re/mainpages/homepage.dart';
import 'package:memo_re/mainpages/mylike.dart';
import 'package:memo_re/mainpages/mypage.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  List<BottomNavigationBarItem> bottomItems = [
    BottomNavigationBarItem(
      label: '홈',
      icon: Icon(Icons.home_filled, size: 30.0,),
    ),
    BottomNavigationBarItem(
      label: '라이크 누른 컨텐츠',
      icon: Icon(Icons.favorite, size: 30.0,),
    ),
    BottomNavigationBarItem(
      label: '내 페이지',
      icon: Icon(Icons.account_circle, size: 30.0,),
    ),
  ];

  List pages = [
    HomePage(),
    MyLike(),
    MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFF4B353), // 앱바의 색상 설정
        title: Text(
          '메모:re',
          style: TextStyle(fontFamily:'Gugi',fontSize: 35.0),  // 이 부분에서 fontSize를 조절합니다.
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
      bottomNavigationBar: Container(
        height: 80.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          boxShadow: [ // 선택적: 그림자 효과 추가
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 0,
              blurRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Color(0xFFF4B353),
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
      ),
      body: pages[_selectedIndex],
    );
  }
}