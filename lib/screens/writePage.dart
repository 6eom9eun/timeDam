import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:memo_re/providers/postProvider.dart';

// 게시물 올리기, 추억 생성 클래스
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
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();

  // 이미지를 갤러리에서 선택하는 함수
  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // 텍스트 입력을 위한 대화 상자를 표시하는 함수
  Future<void> _getText() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('추억 생성'),
          content: TextFormField(
            controller: _textController,
            decoration: InputDecoration(labelText: '추억하고 싶은 단어를 입력해주세요'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                print('입력된 텍스트: ${_textController.text}');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 파일을 Firebase에 업로드하는 함수
  Future<void> _uploadFile() async {
    if (_image == null) return;
    final String fileName = _image!.path.split('/').last;
    final String destination = 'images/$fileName';

    try {
      final Reference ref = FirebaseStorage.instance.ref(destination);
      await ref.putFile(_image!);
      final String url = await ref.getDownloadURL();

      // 이미지 URL을 상태 관리자에 저장
      Provider.of<PostProvider>(context, listen: false).imageUrl = url;
      Provider.of<PostProvider>(context, listen: false).text = _textController.text;
      print('File uploaded to Firebase Storage! URL: $url');

      // Firestore에 텍스트 데이터 저장
      await FirebaseFirestore.instance.collection('posts').add({
        'imageUrl': url,
        'text': _textController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Text and image URL saved to Firestore!');
    } catch (e) {
      print('uploadFile error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null ? Text('No image selected.') : Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getImage,
              child: Text('Pick Image from Gallery'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getText,
              child: Text('Enter Text'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadFile,
              child: Text('Upload to Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}
