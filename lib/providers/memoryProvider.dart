import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MemoryProvider with ChangeNotifier {
  Map<DateTime, List<dynamic>> _events = {};

  // 월별 게시물 가져오기
  void fetchPostsForMonth(DateTime month) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // 월의 시작과 끝
    DateTime startDate = DateTime(month.year, month.month, 1).toUtc();
    DateTime endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59).toUtc();

    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .collection('posts')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      Map<DateTime, List<dynamic>> events = {};

      for (var doc in querySnapshot.docs) {
        DateTime postDate = (doc['createdAt'] as Timestamp).toDate();
        DateTime postDateUtc = DateTime.utc(postDate.year, postDate.month, postDate.day);

        if (events[postDateUtc] == null) {
          events[postDateUtc] = [];
        }
        events[postDateUtc]!.add(doc.data());
      }

      _events = events; // 월별 이벤트 업데이트
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  // 특정 날짜의 게시물 가져오기
  void fetchPosts(DateTime date) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    DateTime startDate = DateTime(date.year, date.month, date.day).toUtc();
    DateTime endDate = DateTime(date.year, date.month, date.day, 23, 59, 59).toUtc();

    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .collection('posts')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      List<dynamic> newEvents = [];
      for (var doc in querySnapshot.docs) {
        newEvents.add(doc.data());
      }

      _events[date] = newEvents; // 선택된 날짜의 이벤트 업데이트
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Map<DateTime, List<dynamic>> get events => _events;
}
