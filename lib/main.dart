import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nevertheless/ui/index_page.dart';
import 'binding/init_bindings.dart';
import 'firebase_options.dart';

void main() async {
  await GetStorage.init();
  //저장소를 불러오기 위해 초기화 해주며 비동기 방식을 사용.

  WidgetsFlutterBinding.ensureInitialized();
  //Getx 사용을 위해 binding을 초기화.

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //Firebase를 초기화하며, 현재 어떤 플랫폼(android, ios)으로 접속했는지를 파악.

  _initNotiSetting();
  // 타이머 종료시 발생할 알림에 관한 초기화를 진행하는 부분.

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  //Firebase를 통해 앱 사용 중 발생하는 오류들을 보고해주는 기능인 Crashlytics를 초기화 해주는 부분.

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  //화면을 세로모드로 고정.

  runApp(
    GetMaterialApp(
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      initialBinding: InitBinding(), //binding 폴더 내부의 InitBinding 클래스의 객체를 생성.
      themeMode: ThemeMode.dark,
      home: const IndexScreen() //ui 폴더 내부의 IndexScreen 클래스 객체를 생성하여 앱의 화면을 띄움.
    )
  );
}

void _initNotiSetting() async {
  //main 함수 코드에서 호출한 알림 초기화를 진행하는 함수.

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //알림 객체 생성
  const initSettingsAndroid = AndroidInitializationSettings('@drawable/ic_launcher');
  //android 알림 아이콘 설정 부분으로 @drawable/ic_launcher'은 안드로이드 폴더 내부에 존재.
  const initSettingsIOS = IOSInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );
  //ios 알림 설정 부분으로 사운드, 뱃지, 알림에 관한 권한을 요청.

  const initSettings = InitializationSettings(
    android: initSettingsAndroid,
    iOS: initSettingsIOS,
  );
  //위의 android 및 ios 설정들을 초기 설정으로 묶어 담음.

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
  );
  //알림 객체에 묶어 담은 설정들을 적용.
}


