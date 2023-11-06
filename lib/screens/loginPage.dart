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
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0.0, 70.0),
                  child: Image.asset(
                    "assets/main_logo.png",
                    width: 350,
                    height: 300,
                  ),
                ),
                Transform.translate(
                  offset: Offset(0.0, -40.0),
                  child: const Text(
                    "기억담",
                    style: TextStyle(
                      fontFamily: 'GODO',
                      fontSize: 130,
                      color: Color(0xFF333333),
                      height: 2.0,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0.0, -80.0),
                  child: Container(
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 2.0,
                          ),
                        ),
                        labelText: 'ID',
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0.0, -70.0),
                  child: Container(
                    width: 300,
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 2.0,
                          ),
                        ),
                        labelText: 'Password',
                      ),
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0.0, -30.0),
                  child: ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                      primary: Colors.amber[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      "로그인",
                      style: TextStyle(
                        fontSize: 22, // 버튼 텍스트 크기 조정
                        color: Colors.black87, // 버튼 텍스트 색상 조정
                        fontFamily: 'Cafe',
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(0.0, 0.0),
                        child: InkWell(
                          onTap: () async {
                            bool hasPermission = await permission();
                            if (hasPermission) {
                              try {
                                await loginProvider.signInWithGoogle();
                                print("구글 로그인 성공");
                                if (!mounted) return;
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
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 2.0,
                                color: Color(0xFFAAAAAA),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset(
                                "assets/google.png",
                                height: 30,
                                width: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Transform.translate(
                        offset: Offset(0.0, 0.0),
                        child: InkWell(
                          onTap: () async {
                            bool hasPermission = await permission();
                            if (hasPermission) {
                              try {
                                await loginProvider.signInWithAnonymous();
                                print("익명 로그인 성공");
                                if (!mounted) return;
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/home', (route) => false);
                              } catch (e) {
                                if (e is FirebaseAuthException) {
                                  print(e.message!);
                                }
                              }
                            } else {
                              print("위치 권한이 필요합니다.");
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 2.0,
                                color: Color(0xFFAAAAAA),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                "익명",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Cafe',
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
