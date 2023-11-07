import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memo_re/utils/vars.dart';
import 'package:share_plus/share_plus.dart';

class DisplayMemoryPage extends StatelessWidget {
  final String memory;
  final String imageUrl;

  DisplayMemoryPage({required this.memory, required this.imageUrl});


  Future uploadMemoryToFirebase(String memory, String imageUrl) async {
    try {

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) { // 회원 아니면 X
        print('Error: User is not logged in');
        return;
      }

      // Firestore에 게시물 정보들을 저장
      DocumentReference postRef = await FirebaseFirestore.instance.collection('posts').add({
        'imageUrl': imageUrl,
        'uid': uid,
        'text': memory,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 생성된 문서 ID(postId)를 가져와서 방금 생성한 문서에 업데이트
      String postId = postRef.id;
      await postRef.update({'postId': postId});

      print('Memory uploaded to Firebase Firestore! Memory: $memory, ImageURL: $imageUrl, PostID: $postId');
    } catch (e) {
      print('uploadMemoryToFirebase error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor(),
        title: Text(
          '추억 생성 완료!',
          style: TextStyle(
            fontFamily: 'Cafe',
            fontSize: 30.0,
            color: Colors.black54,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(imageUrl),
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  memory,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Noto_Sans_KR',
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await uploadMemoryToFirebase(memory, imageUrl);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      } catch (e) {
                        print('Error uploading memory to Firebase: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.amber[500],
                    ),
                    child: Text(
                      '업로드',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Cafe',
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      _shareApp();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.amber[500],
                    ),
                    child: Text(
                      '공유',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Cafe',
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _shareApp() {
    Share.share('',subject: '나의 추억 공유'); // 아무 내용이 없는 빈 문자열을 전달하여 구글 앱의 공유 창 열기
  }
}