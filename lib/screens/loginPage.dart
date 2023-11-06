import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:memo_re/utils//vars.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memo_re/providers/loginProvider.dart';
import 'package:memo_re/screens/landingPage.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  Future<bool> permission() async {
    Map<Permission, PermissionStatus> status =
    await [Permission.location].request(); // [] 권한배열에 권한을 작성

    if (await Permission.location.isGranted) {
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    LoginProvider loginProvider = Provider.of<LoginProvider>(context, listen: true);

    // 오른쪽으로 슬라이드하면 종료 확인 알림
    return WillPopScope(
      onWillPop: () async {
        return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('정말 종료하겠습니까?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('확인'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
            ],
          ),
        )) ??
            false;
      },

      child: Scaffold(
        backgroundColor: AppColors.backColor(),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(0.0, 80.0),
                child: Image.asset(
                  "assets/main_logo.png",
                  width: 500,
                  height: 400,
                ),
              ),
              Transform.translate(
                offset: Offset(0.0, -30.0),
                child: const Text(
                  "시간담", // "memore" 텍스트 추가
                  style: TextStyle(
                    fontFamily: 'GODO',
                    fontSize: 130,
                    color: Color(0xFF333333),
                    height: 2.0,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  bool hasPermission = await permission(); // 위치 권한
                  if (hasPermission) {
                    try {
                      await loginProvider.signInWithGoogle(); // google 로그인
                      print("구글 로그인 성공");
                      if (!mounted) return; // 위치 권한 X 일 때 에러
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (route) => false);
                    } catch (e) {
                      if (e is FirebaseAuthException) {
                        print(e.message!);
                      }
                    }
                  } else {
                    print('위치 권한이 필요합니다.');
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 2, color: Color(0xFFAAAAAA)),
                  fixedSize: const Size(300, 55),
                  backgroundColor: Colors.white,
                ),
                label: const Text(
                  "Google 로그인",
                  style: TextStyle(
                    fontFamily: 'GODO',
                    fontSize: 40,
                    color: Color(0xFF333333),
                  ),
                ),
                icon: Image.asset(
                  "assets/google.png",
                  height: 30,
                  width: 30,
                ),
              ),
              OutlinedButton(
                onPressed: () async {
                  bool hasPermission = await permission(); // 위치 권한
                  if (hasPermission) {
                    try {
                      await loginProvider.signInWithAnonymous(); // 익명 로그인
                      print("익명 로그인 성공");
                      // Navigator.pushNamed(context, '/home');
                      if (!mounted) return; // 위치 권한 X 에러
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (route) => false);
                    } catch (e) {
                      if (e is FirebaseAuthException) {
                        print(e.message!);
                      }
                    }
                  } else {
                    print("위치 권한이 필요합니다."); // 위치 권한이 없는 경우 처리
                  }
                },
                style: OutlinedButton.styleFrom(
                  primary: AppColors.fontGreyColor(), // 텍스트 색상
                  side: BorderSide(color: Color(0xFFAAAAAA), width: 2.0), // 외곽선 색상과 두께
                  backgroundColor: Colors.white,
                ),
                child: const Text('익명 로그인',
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'GODO',
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

