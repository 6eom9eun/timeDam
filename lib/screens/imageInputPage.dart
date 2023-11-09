
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memo_re/screens/DisplayMemoryPage.dart';
import 'package:memo_re/utils/vars.dart';
import 'CreatingPage.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class PostProviderModel with ChangeNotifier {
  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  set imageUrl(String? url) {
    _imageUrl = url;
    notifyListeners();
  }
}

class imageInputPage extends StatefulWidget {
  @override
  _imageInputPageState createState() => _imageInputPageState();
}

class _imageInputPageState extends State<imageInputPage> {
  TextEditingController _textController = TextEditingController();
  final stt.SpeechToText speech = stt.SpeechToText();
  bool _speechInitialized = false;
  String inputText = "";

  File? _image;
  final picker = ImagePicker();
  bool hasImage = false; // New state variable

  @override
  void initState() {
    super.initState();
    initializeSpeechRecognition();
  }

  Future<void> initializeSpeechRecognition() async {
    if (!_speechInitialized) {
      bool available = await speech.initialize(
        onError: (val) {
          print('Error in speech initialize: $val');
          setState(() {
            _speechInitialized = false;
          });
        },
        onStatus: (val) {
          print('Speech recognition status: $val');
        },
      );
      if (available) {
        setState(() => _speechInitialized = true);
        startListening();
      } else {
        setState(() => _speechInitialized = false);
      }
    }
  }

  Future<void> startListening() async {
    if (speech.isListening) {
      await speech.stop();
      print('Stopped listening.');
    } else {
      await speech.listen(
        onResult: (result) {
          setState(() {
            inputText = result.recognizedWords;
            _textController.text = inputText; // 텍스트 입력 폼에 값 설정
          });
          print('Input text: $inputText'); // stt 확인
        },
      );
    }
  }

  @override
  void dispose() {
    speech.stop();
    super.dispose();
  }

  Future<void> sendTextToServer(String text) async {
    // CreatingPage로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatingPage(),
      ),
    );

    // 서버로 데이터를 전송하고 응답을 기다립니다.
    final response = await http.post(
      Uri.parse('http://192.168.123.109:5000'), // 플라스크 서버 주소 입력
      body: {'text': inputText},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final generatedMemory = data['memory'];
      final imageUrl = data['image_url'];

      // 데이터를 성공적으로 받아온 후 DisplayMemoryPage로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayMemoryPage(
            memory: generatedMemory,
            imageUrl: imageUrl,
          ),
        ),
      );
    } else {
      print('데이터 전송 실패: ${response.statusCode}');
    }
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        hasImage = true; // 이미지가 선택되었음을 표시
      } else {
        print('No image selected.');
        hasImage = false; // 이미지가 선택되지 않았음을 표시
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backColor(),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/logo.png', width: 80, height: 80),
                  SizedBox(height: 20),
                  Text(
                    '추억할 사진을 올려주세요!',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Cafe',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 50),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: hasImage
                        ? Image.file(_image!, fit: BoxFit.cover)
                        : Center(
                      child: Text(
                        '이미지를 선택하세요',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: getImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor(),
                      foregroundColor: Colors.black,
                    ),
                    child: Icon(Icons.image, size: 50,),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      labelText: '텍스트를 입력하세요',
                      filled: true,
                      fillColor: AppColors.primaryColor1(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      sendTextToServer(inputText);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor(),
                    ),
                    child: Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Cafe',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: SafeArea(
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}