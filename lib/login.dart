import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xFFF4B353),
        automaticallyImplyLeading: false,
        title: Text(
          '로그인',
          style: TextStyle(fontFamily:'Gugi',fontSize: 35.0),  // 이 부분에서 fontSize를 조절합니다.
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                emailInput(),
                const SizedBox(height: 15),
                passwordInput(),
                const SizedBox(height: 15),
                loginButton(),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text(
                    "회원가입",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFF4B353), // 원하는 색상으로 변경
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField emailInput() {
    return TextFormField(
      controller: _emailController,
      autofocus: true,
      validator: (val) {
        if (val!.isEmpty) {
          return 'The input is empty.';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFF4B353), // 일반 상태의 테두리 색상 변경
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFF4B353), // 포커스 상태의 테두리 색상 변경
          ),
        ),
        hintText: '이메일을 입력하세요.',
        labelText: '이메일 주소',
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFFF4B353), // 라벨 텍스트 색상 변경
        ),
        hintStyle: TextStyle(
          color: Color(0xFFF4B353), // 힌트 텍스트 색상 변경
        ),
      ),
    );
  }

  TextFormField passwordInput() {
    return TextFormField(
      controller: _pwdController,
      obscureText: true,
      autofocus: true,
      validator: (val) {
        if (val!.isEmpty) {
          return 'The input is empty.';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFF4B353), // 일반 상태의 테두리 색상 변경
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFF4B353), // 포커스 상태의 테두리 색상 변경
          ),
        ),
        hintText: '비밀번호를 입력하세요.',
        labelText: '비밀번호',
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFFF4B353), // 라벨 텍스트 색상 변경
        ),
        hintStyle: TextStyle(
          color: Color(0xFFF4B353), // 힌트 텍스트 색상 변경
        ),
      ),
    );
  }


  ElevatedButton loginButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_key.currentState!.validate()) {
          // 여기에 작성
          try {
            await FirebaseAuth.instance
                .signInWithEmailAndPassword(
                email: _emailController.text, password: _pwdController.text)
                .then((_) => Navigator.pushNamed(context, "/"));
          } on FirebaseAuthException catch (e) {
            if (e.code == 'user-not-found') {
              debugPrint('No user found for that email.');
            } else if (e.code == 'wrong-password') {
              debugPrint('Wrong password provided for that user.');
            }
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        child: const Text(
          "로그인",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
    style: ElevatedButton.styleFrom(
      primary: Color(0xFFF4B353), // 원하는 색상으로 변경
    ),
    );
  }
}