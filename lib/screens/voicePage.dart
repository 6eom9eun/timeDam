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
  String inputText = "";

  @override
  void initState() {
    super.initState();
    initializeSpeechRecognition();
    startListening();
  }

  Future<void> initializeSpeechRecognition() async {
    if (await speech.initialize()) {
      setState(() {});
    }
  }

  Future<void> startListening() async {
    if (speech.isListening) {
      await speech.stop();
    }

    bool available = await speech.initialize();
    if (available) {
      await speech.listen(
        onResult: (result) {
          if (result.finalResult != null) {
            setState(() {
              inputText = result.finalResult as String;
            });
          }
        },
      );
    }
  }

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
          ],
        ),
      ),
    );
  }
}
