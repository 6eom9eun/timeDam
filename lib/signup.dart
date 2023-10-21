import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  String? _gender;
  int? _age;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4B353),
        title: const Text(
          '회원가입',
          style: TextStyle(fontFamily: 'Gugi', fontSize: 35.0),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  nameInput(),
                  const SizedBox(height: 15),
                  emailInput(),
                  const SizedBox(height: 15),
                  passwordInput(),
                  const SizedBox(height: 15),
                  genderInput(),
                  const SizedBox(height: 15),
                  birthYearInput(),
                  if (_age != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        '나이: $_age세',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 15),
                  submitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField nameInput() {
    return TextFormField(
      controller: _nameController,
      validator: (val) => val!.isEmpty ? '이름을 입력해주세요.' : null,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: '이름을 입력하세요.',
        labelText: '이름',
        labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      keyboardType: TextInputType.text, // 키보드 입력 모드 설정
    );
  }

  TextFormField emailInput() {
    return TextFormField(
      controller: _emailController,
      validator: (val) => val!.isEmpty ? '이메일을 입력해주세요.' : null,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: '이메일 주소를 입력하세요.',
        labelText: '이메일 주소',
        labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  TextFormField passwordInput() {
    return TextFormField(
      controller: _pwdController,
      obscureText: true,
      validator: (val) => val!.isEmpty ? '비밀번호를 입력해주세요.' : null,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: '비밀번호를 입력하세요.',
        labelText: '비밀번호',
        labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  DropdownButtonFormField<String> genderInput() {
    return DropdownButtonFormField<String>(
      value: _gender,
      onChanged: (String? newValue) {
        setState(() {
          _gender = newValue!;
        });
      },
      items: <String>['남성', '여성', '선호하지 않음']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '성별',
        labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      validator: (val) => val == null ? '성별을 선택해주세요.' : null,
    );
  }

  TextFormField birthYearInput() {
    return TextFormField(
      controller: _birthYearController,
      keyboardType: TextInputType.number,
      validator: (val) {
        if (val!.isEmpty) {
          return '출생년도를 입력해주세요.';
        }
        int? year = int.tryParse(val);
        if (year == null || year > DateTime.now().year || year < 1900) {
          return '유효한 출생년도를 입력해주세요.';
        }
        return null;
      },
      onChanged: (val) {
        setState(() {
          if (val.isNotEmpty) {
            int? year = int.tryParse(val);
            if (year != null && year <= DateTime.now().year && year >= 1900) {
              _age = DateTime.now().year - year;
            } else {
              _age = null;
            }
          } else {
            _age = null;
          }
        });
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: '출생년도를 입력하세요.',
        labelText: '출생년도',
        labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }


  ElevatedButton submitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_key.currentState!.validate()) {
          try {
            UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _emailController.text,
              password: _pwdController.text,
            );

            User? user = credential.user;

            // Firestore에 사용자 정보를 저장합니다. 이름과 출생년도를 저장합니다.
            await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
              'name': _nameController.text,
              'gender': _gender,
              'birthYear': int.tryParse(_birthYearController.text),
            });

            Navigator.pushNamed(context, "/");
          } on FirebaseAuthException catch (e) {
            if (e.code == 'weak-password') {
              print('The password provided is too weak.');
            } else if (e.code == 'email-already-in-use') {
              print('The account already exists for that email.');
            }
          } catch (e) {
            print(e.toString());
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        child: const Text(
          "회원가입",
          style: TextStyle(fontSize: 18),
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: const Color(0xFFF4B353),
      ),
    );
  }
}
