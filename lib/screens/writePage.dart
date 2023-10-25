import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:memo_re/utils/vars.dart';
import 'package:provider/provider.dart';
import 'package:memo_re/providers/postProvider.dart';
import 'package:http/http.dart' as http;

// 게시물 올리기, 추억 생성

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
    return showDialog(
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

                // 서버로 데이터를 전송
                final response = await http.post(
                Uri.parse('SERVER_URL'), // 추후 플라스크 서버 URL 입력
                body: {'text': inputText}, // POST 요청으로 보낼 데이터
                );

                if (response.statusCode == 200) {
                print('데이터 전송 성공: ${response.body}');
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
    final fileName = _image!.path.split('/').last;
    final destination = 'images/$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination);
      await ref.putFile(_image!);
      final url = await ref.getDownloadURL();

      Provider.of<PostProvider>(context, listen: false).imageUrl = url;
      print('File uploaded to Firebase Storage! URL: $url');
    } catch (e) {
      print('uploadFile error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor(), // 앱바의 색상 설정
        title: Text(
          '메모:re',
          style: TextStyle(fontFamily:'Gugi',fontSize: 35.0),
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
            _image == null
                ? Text('No image selected.')
                : Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
              ),
              child: Text('Pick Image from Gallery'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getText,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
              ),
              child: Text('Enter Text'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
              ),
              child: Text('Upload to Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}
