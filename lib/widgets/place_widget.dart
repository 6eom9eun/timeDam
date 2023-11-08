import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memo_re/utils/vars.dart';

Widget buildPlacesList() {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('locations')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get(),
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('오류가 발생했습니다.'));
      } else if (!snapshot.hasData || !snapshot.data!.exists) {
        return Center(child: Text('장소 정보가 없습니다.'));
      } else {
        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
        List<dynamic> places = data['places'] ?? [];
        return ListView.builder(
          itemCount: places.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> place = places[index];
            String placeName = place['place_name'] ?? '이름 없음';
            return Center( // 이제 리스트 타일을 중앙에 배치합니다.
              child: Card( // 둥근 모서리의 카드 위젯을 사용합니다.
                color: AppColors.primaryColor(), // 여기에서 카드의 배경색을 설정합니다.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: ListTile(
                  title: Text(
                    placeName,
                    style: TextStyle(
                      fontFamily: 'CafeAir',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.grey[800], // 여기에서 글씨색을 설정합니다.
                    ),
                    textAlign: TextAlign.center, // 텍스트를 중앙 정렬합니다.
                  ),
                ),
              ),
            );
          },
        );
      }
    },
  );
}
