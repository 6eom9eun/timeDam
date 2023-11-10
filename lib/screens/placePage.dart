import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memo_re/utils/vars.dart';
import 'package:memo_re/widgets/place_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlacePage extends StatefulWidget {
  const PlacePage({super.key});

  @override
  State<PlacePage> createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  String weatherDescription = '';

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
        });
      } catch (e) {
        setState(() {
          weatherDescription = 'error'; //Failed to fetch weather data
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
            padding: EdgeInsets.all(40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor(),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    weatherDescription.isEmpty ? "" : weatherDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'CafeAir',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    '추억 만들기 좋은 날씨에요.',
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
                : Center(child: Text(
                '로그인 해주세요.',
                style: TextStyle(
                    fontFamily: 'CafeAir',
                    fontWeight: FontWeight.bold,
                    fontSize: 24))),
          ),
        ],
      ),
    );
  }
}
