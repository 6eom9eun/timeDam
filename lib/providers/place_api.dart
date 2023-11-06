import 'package:background_fetch/background_fetch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'dart:async';

import 'package:memo_re/models/placeModel.dart';

// 상수 정의
const coordinationUnit = 1800; // 약 50미터를 동일 좌표로 간주

// FirebaseAuth와 FirebaseFirestore 인스턴스 초기화
final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

// 백그라운드 위치 추적 설정 함수
Future<void> initLocationState() async {
  // 백그라운드 fetch 구성
  await BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 15, // 최소 간격 설정(분 단위)
      stopOnTerminate: false, // 앱 종료 시 중단 여부
      enableHeadless: true, // 헤드리스 태스크 활성화
      startOnBoot: true, // 부팅 시 시작
      requiredNetworkType: NetworkType.ANY, // 네트워크 타입 요구사항
    ),
    _onBackgroundFetch, // 백그라운드 페치 이벤트 핸들러
    _onBackgroundFetchTimeout, // 타임아웃 이벤트 핸들러
  );
}

// 위치 데이터를 Firestore에 저장하는 함수
Future<void> _saveLocation(String uid, String taskId) async {
  try {
    print("Trying to save location...");
    Position position = await getLocation(); // 현재 위치 획득
    // Firestore에 저장할 위치 데이터
    Map<String, dynamic> locationData = {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': FieldValue.serverTimestamp(), // 서버 시간 사용
      'accuracy': position.accuracy,
      'heading': position.heading,
      'speed': position.speed,
    };

    // 위치 데이터 Firestore에 저장
    await firestore.collection('users').doc(uid).collection('locations').add(locationData);
    print("Location saved for user $uid with taskId $taskId");
  } catch (e) {
    print("Failed to save location: $e");
  }
}

// 백그라운드 페치 이벤트 처리 함수
void _onBackgroundFetch(String taskId) async {
  print("[BackgroundFetch] Event received $taskId");
  final User? user = auth.currentUser;
  late String uid;
  if (user != null) {
    uid = user.uid;
  } else {
    uid = 'guest'; // 비로그인 시 'guest'로 처리
  }
  // 위치 저장 시도 및 처리
  await _saveLocation(uid, taskId).then((_) {
    print("[BackgroundFetch] Location save task completed for taskId: $taskId");
  }).catchError((e) {
    print("[BackgroundFetch] Error saving location for taskId: $taskId, Error: $e");
  });
  // 백그라운드 작업 완료 표시
  BackgroundFetch.finish(taskId);
}

// 백그라운드 페치 타임아웃 처리 함수
void _onBackgroundFetchTimeout(String taskId) async {
  print("[BackgroundFetch] TIMEOUT: $taskId");
  BackgroundFetch.finish(taskId);
}

// 헤드리스 백그라운드 작업 처리 함수
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  var taskId = task.taskId;
  var timeout = task.timeout;

  if (timeout) {
    print('[BackgroundFetch] Headless task timed-out: $taskId');
    BackgroundFetch.finish(taskId);
    return;
  }

  print("[BackgroundFetch] Headless event received $taskId");
  final User? user = auth.currentUser;
  late String uid;
  if (user != null) {
    uid = user.uid;
  } else {
    uid = 'guest';
  }

  // 헤드리스 상태에서 위치 저장 시도 및 처리
  await _saveLocation(uid, taskId).then((_) {
    print("[BackgroundFetch] Headless location save task completed for taskId: $taskId");
  }).catchError((e) {
    print("[BackgroundFetch] Headless error saving location for taskId: $taskId, Error: $e");
  });
  BackgroundFetch.finish(taskId);
}

// 현재 위치를 가져오는 함수
Future<Position> getLocation() async {
  // Geolocator 패키지를 사용하여 현재 위치 획득
  var currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation);
  return currentPosition;
}

// 카카오 로컬 API를 통해 장소 검색하는 함수
Future<List<VisitedPlaceModel>> getPlacesKakao(
    var placeNames, var latitude, var longitude) async {
  var key = '9ed0df4a106dd50636a1ad5268d420cf'; // API 키 (주의: 배포하지 않도록 함)
  var baseUrl = "https://dapi.kakao.com/v2/local/search/keyword.json";
  List<VisitedPlaceModel> responses = [];

  for (final placeName in placeNames) {
    // 검색 URL 생성
    var url = Uri.parse(
        "$baseUrl?query=$placeName&x=$longitude&y=$latitude&radius=500&sort=distance");

    final dio = Dio();

    // Dio를 사용한 HTTP GET 요청
    Future<Response<dynamic>> getHttp() async {
      final response = await dio.get(
        url.toString(),
        options: Options(
          headers: {"Authorization": "KakaoAK $key"},
        ),
      );
      return response;
    }

    // API 응답 처리
    var response = await getHttp();
    if (response.statusCode == 200) {
      var jsons = response.data['documents'];
      for (final json in jsons) {
        responses.add(VisitedPlaceModel.fromJson(json));
      }
    }
  }
  return responses;
}
