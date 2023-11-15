import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:memo_re/app.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:memo_re/providers/place_api.dart';
import 'package:intl/date_symbol_data_local.dart';

// 상태 관리 : 프로바이더
import 'package:provider/provider.dart';
import 'package:memo_re/providers/loginProvider.dart';
import 'package:memo_re/providers/postProvider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  initLocationState();
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginProvider()),
        ChangeNotifierProvider(create: (context) => PostProvider()),
      ],
      child: const MyApp(),
    ),
  );
}