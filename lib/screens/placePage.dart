import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memo_re/utils/vars.dart';
import 'package:memo_re/widgets/place_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class PlacePage extends StatefulWidget {
  const PlacePage({super.key});

  @override
  State<PlacePage> createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  String weatherIcon = '';

  final Map<String, String> weatherText = {
    '01d': '날씨가 좋아요,\n추억 만들어봐요.',
    '01n': '날씨가 좋은 밤이네요,\n추억을 만드셨나요?',
    '02d': '날씨가 좋아요,\n추억 만들어봐요.',
    '01n': '날씨가 좋은 밤이네요,\n추억을 만드셨나요?',
    '03d': '하늘이 조금 흐려요,\n추억 만들어봐요.',
    '03n': '하늘이 조금 흐린 밤이네요,\n추억을 만드셨나요?.',
    '04d': '하늘이 흐려요,\n추억 만들어봐요.',
    '04n': '하늘이 흐린 밤이네요,\n추억을 만드셨나요?.',
    '09d': '비가 오고 있어요,\n좋은 추억 만들어봐요.',
    '09n': '좋은 밤이네요, 추억을 만드셨나요?.',
    '10d': '날씨가 약간 흐리네요, ',
    '10n': '밤에 구름 조금',
    '11d': '날씨가 약간 흐리네요, ',
    '11n': '밤에 구름 조금',
    '13d': '날씨가 약간 흐리네요, ',
    '13n': '밤에 구름 조금',
    '50d': '날씨가 약간 흐리네요, ',
    '50n': '밤에 구름 조금',
  };

  @override
  void initState() {
    super.initState();
    fetchWeatherDescription();
  }

  Future<void> fetchWeatherDescription() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('locations')
            .doc(user.uid)
            .get();
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          weatherIcon = data['location']['weather']['icon'] ?? '';
        });
      } catch (e) {
        setState(() {
          weatherIcon = '';
        });
      }
    } else {
      setState(() {
        weatherIcon = 'error'; //User not logged in
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backColor(),
      body: Column(
        children: [
          Container(
            height: 70,
            color: Colors.transparent,
          ),
          Padding(
            padding: EdgeInsets.all(30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (weatherIcon == '01d') // clear sky
                  Lottie.asset('assets/lottie/clear-day.json', width: 100, height: 100),
                if (weatherIcon == '01n') // clear sky
                  Lottie.asset('assets/lottie/clear-night.json', width: 100, height: 100),
                if (weatherIcon == '02d') // few clouds
                  Lottie.asset('assets/svg/partly-cloudy-day.json', width: 100, height: 100),
                if (weatherIcon == '02n') // few clouds
                  Lottie.asset('assets/svg/partly-cloudy-night.json', width: 100, height: 100),
                if (weatherIcon == '03d' || weatherIcon == '03n') // 	scattered clouds
                  Lottie.asset('assets/svg/partly-cloudy-night.json', width: 100, height: 100),
                if (weatherIcon == '04d') // broken clouds
                  Lottie.asset('assets/svg/extreme-day.json', width: 100, height: 100),
                if (weatherIcon == '04n') // broken clouds
                  Lottie.asset('assets/svg/extreme-night.json', width: 100, height: 100),
                if (weatherIcon == '09d') // shower rain
                  Lottie.asset('assets/svg/extreme-rain.json', width: 100, height: 100),
                if (weatherIcon == '09n') // shower rain
                  Lottie.asset('assets/svg/extreme-night-rain.json', width: 100, height: 100),
                if (weatherIcon == '10d') // rain
                  Lottie.asset('assets/svg/overcast-day-rain.json', width: 100, height: 100),
                if (weatherIcon == '10n') // rain
                  Lottie.asset('assets/svg/overcast-night-rain.json', width: 100, height: 100),
                if (weatherIcon == '11d') // thunderstorm
                  Lottie.asset('assets/svg/thunderstorms-extreme.json', width: 100, height: 100),
                if (weatherIcon == '11n') // thunderstorm
                  Lottie.asset('assets/svg/thunderstorms-night-extreme.json', width: 100, height: 100),
                if (weatherIcon == '13d' || weatherIcon == '13n') // snow
                  Lottie.asset('assets/svg/snow.json', width: 100, height: 100),
                if (weatherIcon == '50d' || weatherIcon == '50n') // mist
                  Lottie.asset('assets/svg/mist.json', width: 100, height: 100),
                SizedBox(width: 20),
                Expanded(
                  child: Text(weatherText[weatherIcon] ?? '',
                    softWrap: true, // 줄바꿈 활성화
                    style: TextStyle(
                      fontFamily: 'CafeAir',
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FirebaseAuth.instance.currentUser != null
                ? buildPlacesList()
                : Center(
              child: Text(
                '로그인 해주세요.',
                style: TextStyle(
                  fontFamily: 'CafeAir',
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}