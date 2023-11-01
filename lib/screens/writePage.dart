import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:memo_re/utils/vars.dart';
import 'package:provider/provider.dart';
import 'package:memo_re/providers/postProvider.dart';
import 'package:http/http.dart' as http;
import 'DisplayMemoryPage.dart';
import 'package:memo_re/screens/CreatingPage.dart';

// 게시물 올리기, 추억 생성
String generatedMemory = "";
String image_url = "";

class PostProviderModel with ChangeNotifier {
  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  set imageUrl(String? url) {
    _imageUrl = url;
    notifyListeners();
  }
}

class WritePage extends StatefulWidget {
  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  File? _image;
  final picker = ImagePicker();
  TextEditingController _textController = TextEditingController();


  Future getText() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('추억 생성'),
          content: TextFormField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: '추억하고 싶은 단어를 입력해주세요',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () async {
                final inputText = _textController.text;
                print('입력된 텍스트: $inputText');
                Navigator.of(context).pop();

                // LandingPage로 이동하여 로딩 화면을 표시
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatingPage(),
                    fullscreenDialog: true, // 전체 화면 다이얼로그로 엽니다.
                  ),
                );

                // 서버로 데이터를 전송하고 응답을 기다립니다.
                final response = await http.post(
                  Uri.parse('http://192.168.123.108:5000'), // 추후 플라스크 서버 URL 입력
                  body: {'text': inputText}, // POST 요청으로 보낼 데이터
                );

                if (response.statusCode == 200) {
                  final data = json.decode(response.body);
                  generatedMemory = data['memory'];
                  image_url = data['image_url'];

                  // 데이터를 성공적으로 받아온 후 DisplayMemoryPage로 이동
                  Navigator.of(context).pop(); // 로딩 화면 닫기
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DisplayMemoryPage(
                            memory: generatedMemory,
                            imageUrl: image_url,
                          ),
                    ),
                  );
                } else {
                  print('데이터 전송 실패: ${response.statusCode}');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    if (_image == null) return;
    final fileName = _image!
        .path
        .split('/')
        .last;
    final destination = 'images/$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination);
      await ref.putFile(_image!);
      final url = await ref.getDownloadURL();

      // 현재 로그인한 사용자의 UID 가져오기
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) { // 회원 아니면 X
        print('Error: User is not logged in');
        return;
      }

      // Firestore에 게시물 정보들을 저장
      await FirebaseFirestore.instance.collection('posts').add({
        'imageUrl': url,
        'uid': uid,
        'text': _textController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Provider
          .of<PostProvider>(context, listen: false)
          .imageUrl = url;
      print(
          'File uploaded to Firebase Storage and Firestore! URL: $url, UID: $uid');
    } catch (e) {
      print('uploadFile error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(200.0), // 앱바의 높이
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFCF52), // 앱바의 배경 색상 설정
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(150), // 앱바의 하단 모서리를 둥글게 설정
              ),
            ),
            child: Align(
              alignment: Alignment(-0.6, 0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 70),
                    Text(
                      '당신의 추억은\n무엇인가요?',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '저희에게 추억을 알려주세요 !',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _image == null
                    ? Text('이미지를 업로드 해주세요.')
                    : Container(
                  width: 200, // 원하는 너비로 설정
                  height: 200, // 원하는 높이로 설정
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover, // 이미지가 컨테이너를 채우도록 설정
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: getImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[800],
                  ),
                  child: Text('이미지 고르기'),
                ),
                ElevatedButton(
                  onPressed: getText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[800],
                  ),
                  child: Text('텍스트 입력'),
                ),
                ElevatedButton(
                  onPressed: uploadFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[800],
                  ),
                  child: Text('업로드'),

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
