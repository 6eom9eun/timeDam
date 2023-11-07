import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memo_re/utils/vars.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class DisplayMemoryPage extends StatelessWidget {
  final String memory;
  final String imageUrl;

  // 텍스트와 이미지 URL을 받아 객체를 초기화
  DisplayMemoryPage({required this.memory, required this.imageUrl});

  // 이미지 파일을 인터넷에서 다운로드, 로컬 디바이스에 저장
  Future<File> _downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(path.join(documentDirectory.path, 'imagename.jpg')); // 이미지 파일의 경로를 지정합니다.

    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

  // 사용자의 추억과 이미지를 Firebase에 업로드
  Future uploadMemoryToFirebase(String memory, String imageUrl) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    // 로그인 확인
    if (user == null) {
      print('Error: User is not logged in');
      return;
    }

    final imageFile = await _downloadImage(imageUrl); // 이미지 다운

    final uid = user.uid; // 사용자 uid

    // 파일 X 에러
    if (!await imageFile.exists()) {
      print('Error: Image file does not exist.');
      return;
    }

    // Firebase Storage에 저장될 파일의 이름
    final fileName = 'images/${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef = FirebaseStorage.instance.ref().child(fileName);

    try {
      // 파일을 Firebase Storage에 업로드, 모니터링
      final uploadTask = storageRef.putFile(imageFile);

      uploadTask.snapshotEvents.listen(
            (TaskSnapshot snapshot) {
          print('Task state: ${snapshot.state}');
          print('Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
        },
        onError: (e) {
          print(uploadTask.snapshot);

          // 권한 오류가 발생한 경우 메시지를 출력
          if (e.code == 'permission-denied') {
            print('User does not have permission to upload to this reference.');
          }
        },
      );

      // 업로드가 완료될 때까지 대기
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // 업로드된 이미지의 URL과 함께 Firestore에 업로드
      final postRef = FirebaseFirestore.instance.collection('posts').doc();
      await postRef.set({
        'imageUrl': downloadUrl,
        'uid': uid,
        'text': memory,
        'createdAt': FieldValue.serverTimestamp(),
        'postId': postRef.id,
      });

      print('Memory uploaded to Firebase Firestore and Storage! Memory: $memory, ImageURL: $downloadUrl');
    } catch (e) {
      print('uploadMemoryToFirebase error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor(), // 앱바의 색상 설정
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(imageUrl),
            SizedBox(height: 15),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20), // 좌우 여백 조절
              child: Text(
                memory,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Noto_Sans_KR',
                  // fontWeight: FontWeight.bold,
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
                      Navigator.of(context).pop(); //피드 창으로 이동
                    } catch (e) {
                      print('Error uploading memory to Firebase: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.amber[500],
                  ),
                  child: Text('업로드',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Cafe',
                      color: Colors.black54,
                    ),
                  ),
                ),
                SizedBox(width: 20), // 업로드 버튼과 공유 버튼 사이의 간격 조절
                ElevatedButton(
                  onPressed: () {
                    _shareApp();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.amber[500],
                  ),
                  child: Text('공유',
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
    );
  }
  void _shareApp() {
    Share.share('',subject: '나의 추억 공유'); // 아무 내용이 없는 빈 문자열을 전달하여 구글 앱의 공유 창 열기
  }
}