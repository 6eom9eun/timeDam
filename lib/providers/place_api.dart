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
  int status = await BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 15, // 백그라운드 페치가 발생 최소 간격, 최소 15분, 그 이상 유료
      stopOnTerminate: false,   // false로 설정하면 앱 종료 후에도 계속 작동
      enableHeadless: true,     // 'Headless' 작업을 활성화 : 앱이 포그라운드나 백그라운드 상태가 아닐 때도 작업을 수행
      startOnBoot: true,        // 장치가 부팅될 때 백그라운드 페치를 시작할지 여부를 설정
      requiredNetworkType: NetworkType.ANY, // 백그라운드 작업 네트워크 타입 설정 : ANY는 모든 네트워크
      requiresBatteryNotLow: false,          // 배터리가 낮지 않아야 하는지 여부를 설정 : false이면 배터리 상태와 관계 X
      requiresCharging: false,               // 충전 중일 때만 백그라운드 페치 작동 : false이면 충전 상태와 관계 X
      requiresStorageNotLow: false,          // 저장공간이 낮지 않아야 하는지 여부 : false이면 저장공간 상태와 관계 X
      requiresDeviceIdle: false,             // 장치가 유휴 상태일 때만 백그라운드 작업을 수행 : false이면 장치 상태와 관계 X
    ),
    _onBackgroundFetch,
    _onBackgroundFetchTimeout,
  );
}

// 위치 데이터를 Firestore에 저장하는 함수
Future<void> _saveLocation(String uid, String taskId) async {
  try {
    print("Trying to save location and weather...");
    Position position = await getLocation(); // 현재 위치 획득

    // 날씨 정보 획득
    WeatherModel weather = await getWeather(position.latitude, position.longitude);
    Map<String, dynamic> weatherData = weather.toJson();

    // Firestore에 저장할 위치 및 날씨 데이터
    Map<String, dynamic> locationAndWeatherData = {
      'timestamp': FieldValue.serverTimestamp(), // 서버 시간
      'location': { // 'location' 필드
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
      'weather': weatherData,
    };

    // 위치 및 날씨 데이터 Firestore에 저장
    await firestore.collection('locations').doc(uid).set({
      uid: locationAndWeatherData
    }, SetOptions(merge: true));
    print("Location and weather saved for user $uid with taskId $taskId");


    // 노인이 좋아할만한 장소 검색 키워드
    List<String> placeKeywords = ['공원', '도서관', '경로당', '산책로'];
    // 주변 장소 검색 후 저장
    List<VisitedPlaceModel> places = await getPlacesKakao(
        placeKeywords, position.latitude, position.longitude);

    // 검색된 장소들의 리스트를 맵으로 변환
    List<Map<String, dynamic>> placesMap = places.map((place) => place.toJson()).toList();

    // 위치, 날씨 데이터 및 검색된 장소들을 Firestore의 같은 문서에 저장
    await firestore.collection('locations').doc(uid).set({
      ...locationAndWeatherData, // 기존 위치 및 날씨 데이터
      'places': placesMap,       // 검색된 장소들의 리스트 추가
    }, SetOptions(merge: true)); // 'merge: true' 옵션을 사용하여 데이터를 병합

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
  var key = '9ed0df4a106dd50636a1ad5268d420cf'; // 배포 XXXXXXXXXXXXXXXXXXX
  var baseUrl = "https://dapi.kakao.com/v2/local/search/keyword.json";
  List<VisitedPlaceModel> responses = [];

  for (final placeName in placeNames) {
    // 검색 URL 생성
    var url = Uri.parse(
        "$baseUrl?query=$placeName&x=$longitude&y=$latitude&radius=1300&sort=distance"); // 반경 1.2km, 노인 생활 반경 반영

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