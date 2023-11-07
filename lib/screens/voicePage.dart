import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:memo_re/utils/vars.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'DisplayMemoryPage.dart';
import 'CreatingPage.dart'; // CreatingPage를 import

class VoiceInputPage extends StatefulWidget {
  @override
  _VoiceInputPageState createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends State<VoiceInputPage> {
  final stt.SpeechToText speech = stt.SpeechToText();
  bool _speechInitialized = false;
  String inputText = "";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: AppColors.backColor(),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 70),
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset('assets/logo.png', width: 80, height: 80),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                '추억을 말해주세요!',
                style: TextStyle(
                  fontFamily: 'Cafe',
                  fontSize: 30,
                ),
              ),
            ),
            SizedBox(height: 120),
            Stack(
              alignment: Alignment.center,
              children: [
                SpinKitWave(
                  color: Color(0xFFFFCF52),
                  size: 200.0,
                ),
              ],
            ),
            SizedBox(height: 50),
            Text(
              '음성인식 중입니다..',
              style: TextStyle(
                fontFamily: 'CafeAir',
                fontSize: 18,
                color: Color(0xff777777),
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              inputText,
              style: TextStyle(
                fontFamily: 'CafeAir',
                fontSize: 18,
                color: Color(0xff777777),
              ),
              textAlign: TextAlign.center,
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
    );
  }
}