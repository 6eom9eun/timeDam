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
import 'package:speech_to_text/speech_to_text.dart';
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
  final speech = SpeechToText();
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
                // Navigator.of(context).pop();

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
                  Uri.parse('http://192.168.123.104:5000'), // 추후 플라스크 서버 URL 입력
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

  Future<void> startListening() async {
    if (!await speech.initialize()) {
      // 음성 입력 초기화에 실패한 경우
      return;
    }

    if (speech.isListening) {
      // 이미 음성 입력 중인 경우
      await speech.stop();
    }

    final result = await speech.listen();
    if (result.finalResult != null) {
      // 음성 입력이 성공적으로 완료된 경우
      final inputText = result.finalResult;
      // TODO: 음성 입력된 텍스트를 처리하고 저장합니다.
      print('인식된 음성: $inputText'); // 음성 입력된 텍스트를 출력
      _textController.text = inputText;
    }
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
    final fileName = _image!.path.split('/').last;
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

      // Firestore에 게시물 정보들을 먼저 저장하지만 postId는 아직 모릅니다.
      DocumentReference postRef = await FirebaseFirestore.instance.collection('posts').add({
        'imageUrl': url,
        'uid': uid,
        'text': _textController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 생성된 문서 ID(postId)를 가져와서 방금 생성한 문서에 업데이트합니다.
      String postId = postRef.id;
      await postRef.update({'postId': postId});

      Provider.of<PostProvider>(context, listen: false).imageUrl = url;
      print('File uploaded to Firebase Storage and Firestore! URL: $url, UID: $uid, PostID: $postId');
    } catch (e) {
      print('uploadFile error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    var statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.backColor(),
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 배경색을 투명하게 설정
        elevation: 0, // 그림자 제거
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.all(50),
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
                  onPressed: uploadFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[800],
                  ),
                  child: Text('업로드'),
                ),
                ElevatedButton(
                  onPressed: getText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[800],
                  ),
                  child: Icon(Icons.keyboard),
                ),
                ElevatedButton(
                  onPressed: startListening, // 음성 입력 함수 호출
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[800],
                  ),
                  child: Icon(Icons.mic), // 음성 입력 버튼 추가
                ),
              ],
            ),
          ),
        ),

      ),
    );
  }
}
