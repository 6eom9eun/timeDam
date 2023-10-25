import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memo_re/providers/loginProvider.dart';
import 'package:provider/provider.dart';
import 'package:memo_re/widgets/setting_widget.dart';

final firestore = FirebaseFirestore.instance;


class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<LoginProvider>(context);
    final user = userData.userInformation;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xffFBE8B8),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                children: [
                  SettingContainerText(
                    title: "이메일",
                    information: user?.email ?? "abc@def.com",
                  ),
                  SettingContainerText(
                    title: "이름",
                    information: user?.name ?? "홍길동",
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: const Column(
                children: [
                  SettingContainerText(
                    title: "1",
                  ),
                  SettingContainerText(
                    title: "2",
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: const Column(
                children: [
                  SettingContainerText(
                    title: "3",
                  ),
                  SettingContainerText(
                    title: "4",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}