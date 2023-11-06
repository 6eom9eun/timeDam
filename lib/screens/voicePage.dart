import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:memo_re/utils/vars.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceInputPage extends StatefulWidget {
  @override
  _VoiceInputPageState createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends State<VoiceInputPage> {
  final SpeechToText speech = SpeechToText();
  bool _speechInitialized = false;
  String inputText = "";

  @override
  void initState() {
    super.initState();
    initializeSpeechRecognition();
  }

  Future<void> initializeSpeechRecognition() async {
    if (!_speechInitialized) {
      _speechInitialized = await speech.initialize(onError: (error) {
        // 에러 처리 로직
        _speechInitialized = false;
      });
      setState(() {});
      if (_speechInitialized) {
        startListening();
      }
    }
  }

  Future<void> startListening() async {
    if (speech.isListening) {
      await speech.stop();
    }

    await speech.listen(
      onResult: (result) {
        setState(() {
          inputText = result.recognizedWords;
          print(inputText); // stt 확인
        });
      },
    );
  }

  @override
  void dispose() {
    speech.stop();
    super.dispose();
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
          ],
        ),
      ),
    );
  }
}
