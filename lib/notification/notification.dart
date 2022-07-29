import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:get_storage/get_storage.dart';

Future todoNotification(int id, String notiTitle, String notiDesc) async {
  //todo의 타이머 시간이 종료되면 알림이 울림. 해당 알림은 고유한 id가 필요하므로 todo의
  //id를 인자로 받으며 추가적으로 제목(notiTitle)과 설명(notiDesc)을 인자로 받음.

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final result = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true,);
  //현재 단말기가 ios일 경우 알림, 뱃지, 사운드의 권한이 허가되어 있는지를 판별하여 true 또는 false를 return하여 result 변수에 담음.
  //단, ios가 아닌 플랫폼일 경우 null을 return.

  var android = AndroidNotificationDetails("nevertheless", "nevertheless",
      importance: Importance.max, priority: Priority.max, playSound: true);
  //android 알림에 관한 설정으로 채널id(String 값), 채널명, 알림의 중요도와 우선순위, 사운드 재생 여부 등을 정함.
  var ios = const IOSNotificationDetails();
  //ios 알림에 관한 설정 객체를 생성합니다.
  var detail = NotificationDetails(android: android, iOS: ios);
  //android와 ios 알림 설정을 하나로 묶어 detail 변수에 담음.

  if ((!Platform.isAndroid && result != null && result) || Platform.isAndroid) {

    String timeZone = await FlutterNativeTimezone.getLocalTimezone();
    //단말기 시간대의 국가 및 도시 정보를 받아오기 위해 외부 라이브러리를 사용.

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(timeZone));

    final storage = GetStorage();
    bool isNotification = storage.read('notification') ?? true;
    if(isNotification){
      //알림이 허용되어있다면 알림 객체를 이용하여 예정된 시간에 알림을 발생.
      await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          notiTitle,
          notiDesc,
          tz.TZDateTime.now(tz.local).add(Duration(seconds: duration)),
          //알림의 시간을 설정하는 부분입니다. 현재 시간대에서 인자로 받아온 duration(todo의 종료시각 - 시작시각)만큼 후에 알림이 울리도록 예약.
          detail,
          androidAllowWhileIdle: true,
          //장치가 저전력 유휴 모드인 경우에도 지정된 시간에 알림을 전달해야 하는지 여부를 결정하는 데 사용.
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime
        //예약된 날짜를 절대 시간으로 해석할지 벽시계 시간으로 해석할지 결정하는 데 사용.
      );

    }

  }
}