import 'package:background_fetch/background_fetch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

// 모델
import 'package:memo_re/models/placeModel.dart';
import 'package:memo_re/models/weatherModel.dart';

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

// 현재 위치를 가져오는 함수
Future<Position> getLocation() async {
  // Geolocator 패키지를 사용하여 현재 위치 획득
  var currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation);
  return currentPosition;
}

// db 저장
Future<void> _saveLocation(String uid, String taskId) async {
  try {
    print("Trying to save location...");
    Position position = await getLocation(); // 현재 위치 획득

    // 날씨 정보 획득
    WeatherModel weather = await getWeather(position.latitude, position.longitude);
    Map<String, dynamic> weatherData = weather.toJson();

    // Firestore에 저장할 위치 데이터
    Map<String, dynamic> locationData = {
      'timestamp': FieldValue.serverTimestamp(), // 서버 시간
      'latitude': position.latitude,
      'longitude': position.longitude,
      'weather': weatherData, // 날씨 데이터를 위치 데이터에 포함
    };

    // 위치 데이터 Firestore에 저장 (기존 데이터 덮어쓰기)
    await firestore.collection('locations').doc(uid).set({
      'location': locationData // 위치 데이터에 날씨 데이터가 포함되어 있음
    });
    print("Location and weather saved for user $uid with taskId $taskId");

    // 노인이 좋아할만한 장소 검색 키워드
    List<String> placeKeywords = ['공원', '도서관', '경로당', '산책로'];

    // 주변 장소 검색 후 저장
    List<VisitedPlaceModel> places = await getPlacesKakao(
        placeKeywords, position.latitude, position.longitude);

    // 검색된 장소들의 리스트를 맵으로 변환
    List<Map<String, dynamic>> placesMap = places.map((place) => place.toJson()).toList();

    // Firestore에 위치 데이터 및 검색된 장소들을 저장 (기존 데이터 덮어쓰기)
    await firestore.collection('locations').doc(uid).set({
      'location': locationData, // 위치 및 날씨 데이터
      'places': placesMap,      // 검색된 장소들의 리스트 추가
    });

    print("Location, weather, and places saved for user $uid with taskId $taskId");

  } catch (e) {
    print("Failed to save location, weather, or places: $e");
  }
}


// 백그라운드 페치 이벤트가 발생했을 때 호출되는 함수
void _onBackgroundFetch(String taskId) async {
  print("[BackgroundFetch] Event received $taskId");
  final User? user = auth.currentUser;
  late String uid;
  if (user != null) {
    uid = user.uid;
  } else {
    uid = 'guest';
  }

  _saveLocation(uid, taskId);
  BackgroundFetch.finish(taskId);
}

// 백그라운드 페치 작업이 시간 내에 완료되지 않았을 때 호출되는 함수
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

  print("[BackgroundFetch] Event received $taskId");
  final User? user = auth.currentUser;
  late String uid;
  if (user != null) {
    uid = user.uid;
  } else {
    uid = 'guest';
  }
  _saveLocation(uid, taskId);

  BackgroundFetch.finish(taskId);
}

// 카카오 로컬 API를 통해 장소 검색하는 함수
Future<List<VisitedPlaceModel>> getPlacesKakao(
    var placeNames, var latitude, var longitude) async {
  var key = '9ed0df4a106dd50636a1ad5268d420cf'; // 배포 XXXXXXXXXXXXXXXXXXX
  var baseUrl = "https://dapi.kakao.com/v2/local/search/keyword.json";
  List<VisitedPlaceModel> responses = [];

  for (final placeName in placeNames) {
    // 검색 URL 생성
    var url = Uri.parse(
        "$baseUrl?query=$placeName&x=$longitude&y=$latitude&radius=500&sort=distance"); // 반경 500m, 노인 생활 반경 반영

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

Future<WeatherModel> getWeather(var latitude, var longitude) async {
  var key = '09530d1ccfae5c1d0f1d1d82d5027b94'; // 배포 XXXXXXXXXXXXXXXXXXX
  var baseUrl = "https://api.openweathermap.org/data/2.5/weather";
  var url = Uri.parse(
      '$baseUrl?lat=$latitude&lon=$longitude&appid=$key&units=metric&lang=kr');
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var json = await jsonDecode(response.body);
    return WeatherModel.fromJson(json);
  } else {
    throw Exception('${response.statusCode}');
  }
}