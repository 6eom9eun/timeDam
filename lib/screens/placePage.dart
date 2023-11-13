import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memo_re/utils/vars.dart';
import 'package:memo_re/widgets/place_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlacePage extends StatefulWidget {
  const PlacePage({super.key});

  @override
  State<PlacePage> createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  String weatherDescription = '';
  String weatherIcon = '';

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
          weatherDescription =
              data['location']['weather']['description'] ?? 'No description';
          weatherIcon = data['location']['weather']['icon'] ?? '';
        });
      } catch (e) {
        setState(() {
          weatherDescription = 'error'; //Failed to fetch weather data
          weatherIcon = '';

        });
      }
    } else {
      setState(() {
        weatherDescription = 'error'; //User not logged in
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
                if (weatherIcon == '01d')
                  SvgPicture.asset('assets/svg/clear-day.svg', width: 80, height: 80),
                if (weatherIcon == '01n')
                  SvgPicture.asset('assets/svg/clear-night.svg', width: 80, height: 80),
                if (weatherIcon == '02d')
                  SvgPicture.asset('assets/svg/partly-cloudy-day.svg', width: 80, height: 80),
                if (weatherIcon == '02n')
                  SvgPicture.asset('assets/svg/partly-cloudy-night.svg', width: 80, height: 80),
                if (weatherIcon == '03d' || weatherIcon == '03n')
                  SvgPicture.asset('assets/svg/partly-cloudy-night.svg', width: 80, height: 80),
                if (weatherIcon == '04d')
                  SvgPicture.asset('assets/svg/extreme-day.svg', width: 80, height: 80),
                if (weatherIcon == '04n')
                  SvgPicture.asset('assets/svg/extreme-night.svg', width: 80, height: 80),
                if (weatherIcon == '09d')
                  SvgPicture.asset('assets/svg/extreme-rain.svg', width: 80, height: 80),
                if (weatherIcon == '09n')
                  SvgPicture.asset('assets/svg/extreme-night-rain.svg', width: 80, height: 80),
                if (weatherIcon == '10d')
                  SvgPicture.asset('assets/svg/overcast-day-rain.svg', width: 80, height: 80),
                if (weatherIcon == '10n')
                  SvgPicture.asset('assets/svg/overcast-night-rain.svg', width: 80, height: 80),
                if (weatherIcon == '11d')
                  SvgPicture.asset('assets/svg/thunderstorms-extreme.svg', width: 80, height: 80),
                if (weatherIcon == '11n')
                  SvgPicture.asset('assets/svg/thunderstorms-night-extreme.svg', width: 80, height: 80),
                if (weatherIcon == '13d' || weatherIcon == '13n')
                  SvgPicture.asset('assets/svg/snow.svg', width: 80, height: 80),
                if (weatherIcon == '50d' || weatherIcon == '50n')
                  SvgPicture.asset('assets/svg/mist.svg', width: 80, height: 80),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    weatherDescription.isEmpty
                        ? "날씨 정보 없음"
                        : weatherDescription,
                    style: TextStyle(
                      fontFamily: 'CafeAir',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}