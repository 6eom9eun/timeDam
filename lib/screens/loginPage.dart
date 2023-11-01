import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:memo_re/providers/loginProvider.dart';
import 'package:memo_re/utils//vars.dart';
import 'package:memo_re/screens/landingPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
              const SizedBox(height: 100.0),
              Image.asset(
                "assets/main_logo.png",
                width: 500,
                height: 300,
              ),
              const Text(
                "MEMO:re", // "memore" 텍스트 추가
                style: TextStyle(
                  fontFamily: 'Gugi',
                  fontWeight: FontWeight.bold,
                  fontSize: 60,
                  color: Color(0xFF333333),
                  height: 2.0,
                ),
              ),
              const SizedBox(height: 30.0),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.push(context, CupertinoPageRoute(builder: (context) => LandingPage()));
                  try {
                    await loginProvider.signInWithGoogle(); // 구글 로그인
                    print("구글 로그인 성공");
                    if (!mounted) return; // 없을 때
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  } catch (e) {
                    if (e is FirebaseAuthException) {
                      print(e.message!);
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 2, color: Color(0xFF333333)),
                  fixedSize: const Size(300, 55),
                  backgroundColor: Colors.white,
                ),
                label: const Text(
                  "Google 로그인",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LandingPage()));
                  try {
                    await loginProvider.signInWithAnonymous(); // 익명 로그인
                    print("Anonymous Login Success!!");
                    if (!mounted) return; // 없을 때
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  } catch (e) {
                    if (e is FirebaseAuthException) {
                      print(e.message!);
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  primary: AppColors.fontGreyColor(), // 텍스트 색상
                  side: BorderSide(color: Color(0xFF333333), width: 2.0), // 외곽선 색상과 두께
                  backgroundColor: Colors.white,
                ),
                child: const Text('익명 로그인',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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

