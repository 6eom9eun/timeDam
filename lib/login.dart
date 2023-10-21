import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF4B353),
        automaticallyImplyLeading: false,
        title: Text(
          '로그인',
          style: TextStyle(fontFamily: 'Gugi', fontSize: 35.0),
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
                googleLoginButton(),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text(
                    "회원가입",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFF4B353),
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
            color: Color(0xFFF4B353),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFF4B353),
          ),
        ),
        hintText: '이메일을 입력하세요.',
        labelText: '이메일 주소',
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFFF4B353),
        ),
        hintStyle: TextStyle(
          color: Color(0xFFF4B353),
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
            color: Color(0xFFF4B353),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFF4B353),
          ),
        ),
        hintText: '비밀번호를 입력하세요.',
        labelText: '비밀번호',
        labelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFFF4B353),
        ),
        hintStyle: TextStyle(
          color: Color(0xFFF4B353),
        ),
      ),
    );
  }

  ElevatedButton loginButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_key.currentState!.validate()) {
          try {
            await _auth
                .signInWithEmailAndPassword(
                email: _emailController.text,
                password: _pwdController.text)
                .then((_) => Navigator.pushNamed(context, "/landing"));
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
        primary: Color(0xFFF4B353),
      ),
    );
  }

  ElevatedButton googleLoginButton() {
    return ElevatedButton(
      onPressed: () async {
        try {
          final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
          final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final UserCredential authResult = await _auth.signInWithCredential(credential);
          final User? user = authResult.user;

          if (user != null) {
            Navigator.pushNamed(context, "/landing");
          }
        } catch (e) {
          print("Google 로그인 오류: $e");
        }
      },
      style: ElevatedButton.styleFrom(
        primary: Color(0xFFF4B353),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/google.png', // 이미지 파일 경로
            height: 24, // 이미지 높이 조정
          ),
          SizedBox(width: 8), // 로고와 텍스트 사이 여백 조정
          Text(
            "Google 로그인",
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
