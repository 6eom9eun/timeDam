import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
              onPressed: () {
                // 여기서 입력된 텍스트를 처리할 수 있음
                print('입력된 텍스트: ${_textController.text}');
                Navigator.of(context).pop();
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
      print('File uploaded to Firebase Storage!');
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
              child: Text('Pick Image from Gallery'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getText,
              child: Text('Enter Text'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadFile,
              child: Text('Upload to Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}
