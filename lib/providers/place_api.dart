import 'dart:convert';
import 'package:background_fetch/background_fetch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

import 'dart:async';

import 'package:memo_re/models/placeModel.dart';

// FirebaseAuth 인스턴스를 초기화합니다.
final FirebaseAuth auth = FirebaseAuth.instance;

// 백그라운드 fetch를 초기화합니다.
Future<void> initLocationState() async {
  await BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 15,
      stopOnTerminate: false,
      enableHeadless: true,
      startOnBoot: true,
      requiredNetworkType: NetworkType.ANY,
    ),
    _onBackgroundFetch,
    _onBackgroundFetchTimeout,
  );
}

// 백그라운드 fetch 이벤트가 발생할 때 호출됩니다.
void _onBackgroundFetch(String taskId) async {
  // 현재 사용자를 가져옵니다.
  final User? user = auth.currentUser;
  final String uid = user?.uid ?? 'guest';

  // 현재 위치를 가져옵니다.
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  double latitude = position.latitude;
  double longitude = position.longitude;

  // 장소 이름 목록을 정의합니다.
  List<String> placeNames = ["카페", "도서관", "마트"];

  // Kakao API를 호출하여 주변 장소를 가져옵니다.
  List<VisitedPlaceModel> places = await getPlacesKakao(placeNames, latitude, longitude);

  // 결과를 처리합니다.
  for (VisitedPlaceModel place in places) {
    print('방문한 장소: ${place.name}');
    // 필요한 경우, Firebase에 저장하거나 기타 작업을 수행합니다.
  }

  // 백그라운드 작업을 마무리합니다.
  BackgroundFetch.finish(taskId);
}

// 백그라운드 fetch 작업이 타임아웃될 때 호출됩니다.
void _onBackgroundFetchTimeout(String taskId) {
  print("[BackgroundFetch] TIMEOUT: $taskId");
  BackgroundFetch.finish(taskId);
}

// headless task가 정의되어 있어야 백그라운드에서 실행됩니다.
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  var taskId = task.taskId;
  if (task.timeout) {
    print('[BackgroundFetch] Headless task timed-out: $taskId');
    BackgroundFetch.finish(taskId);
    return;
  }
  BackgroundFetch.finish(taskId);
}
// KaKao REST API

Future<List<VisitedPlaceModel>> getPlacesKakao(
    var placeNames, var latitude, var longitude) async {
  var key = '9ed0df4a106dd50636a1ad5268d420cf';
  var baseUrl = "https://dapi.kakao.com/v2/local/search/keyword.json";
  List<VisitedPlaceModel> responses = [];
  // https://developers.kakao.com/docs/latest/ko/local/dev-guide#search-by-category-request-category-group-code
  for (final placeName in placeNames) {
    var url = Uri.parse(
        "$baseUrl?query=$placeName&x=$longitude&y=$latitude&radius=500&sort=distance");

    final dio = Dio();

    Future<Response<dynamic>> getHttp() async {
      final response = await dio.get(
        url.toString(),
        options: Options(
          headers: {"Authorization": "KakaoAK $key"},
        ),
      );
      return response;
    }

    var response = await getHttp();
    if (response.statusCode == 200) {
      var jsons = response.data;
      if (jsons is! List) {
        jsons = [jsons];
      }
      for (final json in jsons) {
        if (json['documents'].length > 0) {
          for (final document in json['documents']) {
            responses.add(VisitedPlaceModel.fromJson(document));
          }
        }
      }
    }
  }
  return responses;
}