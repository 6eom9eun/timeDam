import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:memo_re/utils/vars.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
        child: SingleChildScrollView( // Ensuring the content is scrollable
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              SpinKitWave(
                color: Color(0xFFFFCF52),
                size: 200.0,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  inputText,
                  style: TextStyle(
                    fontFamily: 'CafeAir',
                    fontSize: 18,
                    color: Color(0xff777777),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
