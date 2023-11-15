import 'package:flutter/material.dart';
import 'package:memo_re/screens/InputPage.dart';
import 'package:memo_re/screens/ImageInputPage.dart';
import 'package:memo_re/screens/voicePage.dart';
import 'package:memo_re/utils/vars.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool showInputOptions = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backColor(),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0), // Padding for the scroll view
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', width: 80, height: 80),
                  SizedBox(height: 20),
                  Text(
                    '추억을 기록하세요!',
                    style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'Cafe'),
                  ),
                  SizedBox(height: 60),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor1(),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 7,
                          blurRadius: 7,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // To make the container wrap its content
                      children: [
                        if (!showInputOptions) ...[
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => imageInputPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor(),
                              fixedSize: Size(350, 100),
                            ),
                            child: Text(
                              '추억할 사진이 있으신가요?',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Cafe',
                                fontSize: 20,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TextInputPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor(),
                              fixedSize: Size(350, 100),
                            ),
                            child: Text(
                              '추억할 만한 사진이 없으신가요?',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Cafe',
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ],
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
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Future<void> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) {
      // 권한이 이미 있을 경우
      navigateToVoiceInputPage();
    } else {
      // 권한 요청
      status = await Permission.microphone.request();
      if (status.isGranted) {
        // 사용자가 권한을 허용했을 경우
        navigateToVoiceInputPage();
      } else {
        // 사용자가 권한을 거부했을 경우
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('마이크 권한이 필요합니다.'),
          ),
        );
      }
    }
  }

  void navigateToVoiceInputPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VoiceInputPage()),
    );
  }
}



