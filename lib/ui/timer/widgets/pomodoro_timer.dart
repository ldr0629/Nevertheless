import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:nevertheless/ui/index_page.dart';
import '../../../data/todo.dart';
import '../../../notification/notification.dart';

class PomodoroTimer extends StatefulWidget{
  const PomodoroTimer({Key? key, required this.controller, required this.todayTodoList}) : super(key : key);
  final List<Todo> todayTodoList;
  final CountDownController controller;
  @override
  State<StatefulWidget> createState() {
    return _PomodoroTimer();
  }
}

class _PomodoroTimer extends State<PomodoroTimer>{

  List<Map<String,dynamic>> durationList = [{
    "todo" : null,
    "startTime" : null,
    "endTime" : null,
  }];

  int durationCounter = 0;
  bool isItRest = false;
  String text = "진행가능한 일정 없음";
  int initDuration = 0;
  bool isNotification = true;
  late DateTime startTimeLog;

  Todo? todo;
  Color processColor = Colors.red;
  //타이머 하단부에 표현되는 진행 색상으로 빨간색은 현재 진행중인 일정이 없음을, 노랑색은 일정을 대기중임을,
  //초록색은 일정을 진행중임을 나타낸다.

  final storage = GetStorage();

  @override
  initState(){
    DateTime now = DateTime.now();
    durationList = List.empty(growable: true);

    if(widget.todayTodoList.isNotEmpty){
      if(now.compareTo(stringToDateTime(widget.todayTodoList.first.startTime!)) == -1){
        durationList.add(
            {
              "todo" : null,
              "startTime" : now,
              "endTime" : stringToDateTime(widget.todayTodoList.first.startTime!)
            }
        );
      }

      for (int i = 0; i < widget.todayTodoList.length; i++) {

        if(now.compareTo(stringToDateTime(widget.todayTodoList[i].startTime!)) >= 0 &&
            now.compareTo(stringToDateTime(widget.todayTodoList[i].endTime!))  == -1){
          durationList.add(
              {"todo" : widget.todayTodoList[i],
                "startTime" : stringToDateTime(widget.todayTodoList[i].startTime!)
                    .add(Duration(hours: now.hour - stringToDateTime(widget.todayTodoList[i].startTime!).hour,
                    minutes: now.minute - stringToDateTime(widget.todayTodoList[i].startTime!).minute,
                    seconds: now.second)),
                "endTime" : stringToDateTime(widget.todayTodoList[i].endTime!),
              }
          );
        }else{
          if(now.compareTo(stringToDateTime(widget.todayTodoList[i].startTime!)) >= 0 &&
              now.compareTo(stringToDateTime(widget.todayTodoList[i].endTime!))  >= 0){
            //만약 각 todo의 시각과 현재시각이 모두 현재에 비해 과거라면 durationCounter를 증가시켜 이후
            //타이머 시작시 해당 일정을 넘김.
            durationCounter++;
          }
          durationList.add(
              {"todo" : widget.todayTodoList[i],
                "startTime" : stringToDateTime(widget.todayTodoList[i].startTime!),
                "endTime" : stringToDateTime(widget.todayTodoList[i].endTime!)
              }
          );
        }

        if((widget.todayTodoList[i] != widget.todayTodoList.last)
            && subtractDateTimeToInt(stringToDateTime(widget.todayTodoList[i].endTime!),
                stringToDateTime(widget.todayTodoList[i+1].startTime!)) > 0
            && now.compareTo(stringToDateTime(widget.todayTodoList[i+1].startTime!)) == -1){
          durationList.add(
              {
                "todo" : null,
                "startTime" : now.compareTo(stringToDateTime(widget.todayTodoList[i].endTime!)) == -1
                    ? stringToDateTime(widget.todayTodoList[i].endTime!): now,
                "endTime" : stringToDateTime(widget.todayTodoList[i+1].startTime!)

              }
          );
        }
      }

      initDuration =  durationList.isNotEmpty && DateTime.now().compareTo(durationList.last["endTime"]) == -1 ? subtractDateTimeToInt(durationList[durationCounter]["startTime"],
          durationList[durationCounter]["endTime"]) : 1;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    isNotification = storage.read('notification') ?? true;

    return Column(
      children: [
        CircularCountDownTimer(
            duration : initDuration < 1 ? 1 : initDuration,
            initialDuration: 0,
            controller: widget.controller,
            //타이머의 시작 또는 종료와 같은 기능을 제어.
            width: MediaQuery.of(context).size.width / 3,
            height: MediaQuery.of(context).size.height / 3,
            ringColor: Colors.grey,
            fillColor: Colors.black45,
            backgroundColor: Colors.black12,
            strokeWidth: 5.0,
            strokeCap: StrokeCap.round,

            textStyle: const TextStyle(fontSize: 24.0, color: Colors.white, fontWeight: FontWeight.bold),
            textFormat: CountdownTextFormat.HH_MM_SS,
            isReverse: true,
            isReverseAnimation: false,
            isTimerTextShown: true,
            autoStart: true,
            onStart: () {
              //타이머가 시작되었을 때 콜백되는 함수.

              if(widget.todayTodoList.isNotEmpty && initDuration != 1){
                DateTime now = DateTime.now();

                todo = durationList[durationCounter]["todo"];
                isItRest = durationList[durationCounter]["todo"] != null ? false: true;
                if(todo != null){
                  text = "${todo!.title}";
                  processColor = Colors.green; // 진행중
                }else if(durationList[durationCounter+1]["todo"] != null){
                  text = "${durationList[durationCounter+1]["todo"].title}";
                  processColor = Colors.orangeAccent; // 대기중
                }
                if (!isItRest) {
                  startTimeLog = DateTime(
                      now.year, now.month, now
                      .day, now.hour, now.minute, 0
                  );

                  if (isNotification) {
                    todoNotification(todo!.id!, "Nevertheless",
                        "\"${todo!.title!}\" 일정 종료");
                    //사용자가 알림을 허용한 상태라면 알림을 울림.
                  }
                }else{
                  if (isNotification) {
                    todoNotification(999, "Nevertheless", "휴식시간 종료");
                    //알림이 켜져있을 경우 휴식시간 종료를 알림.
                    //todo가 존재하지 않으므로 임의의 값(999)을 id로 넣음.
                  }

                }
              }
            },
            onComplete: () {
              //타이머 종료시에 콜백되는 함수.

              if(widget.todayTodoList.isNotEmpty && initDuration !=1){
                DateTime now = DateTime.now();

                setState(() {
                  if (!isItRest && todo != null) {
                    if(todo!.timeLog == null){
                      //현재의 todo의 timeLog에 아무 데이터가 들어있지 않다면
                      //아래와 같이 초기화. 리스트의 인덱스는 각각 [월,화,수,목,금,토,일]을 의미.
                      //인덱스의 숫자값은 해당 요일동한 진행한 todo의 타이머 기록시간.
                      todo!.timeLog = [0,0,0,0,0,0,0];
                    }
                    todo!.timeLog![now.weekday-1] = todo!.timeLog![now.weekday-1]!
                        + subtractDateTimeToInt(startTimeLog, now)~/60;
                    saveTodo();
                  } else {
                    //타이머가 대기중이었던 시간이 끝날 경우.
                    isItRest = false;
                  }

                  if (initDuration!=1 && todo?.id != widget.todayTodoList.last.id) {
                    durationCounter++;
                    widget.controller.restart(
                        duration: subtractDateTimeToInt( durationList[durationCounter]["startTime"],
                            durationList[durationCounter]["endTime"]));
                  }else if(initDuration!=1 && todo?.id == widget.todayTodoList.last.id){
                    text = "모든 일정 종료";
                    processColor = Colors.red;
                  }
                });
              }
            }),
        FutureBuilder(
          //타이머 하단부에 담기는 위젯.
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return Padding(
                padding: const EdgeInsets.only(left: 32, right: 32),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                          width: 16.0,
                          height: 16.0,
                          decoration: BoxDecoration(
                            color: processColor,
                            shape: BoxShape.circle,
                          )),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text( text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400), maxLines: 1,
                        overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,),
                    ),
                  ],
                ),
              );
            }),
        const SizedBox(
          height: 24,
        ),
        Divider(thickness: 2,),
      ],
    );
  }
}

DateTime stringToDateTime(String time){
  DateTime now = DateTime.now();
  final format = DateFormat.jm();
  var tod = TimeOfDay.fromDateTime(format.parse(time));
  var result = DateTime(now.year,now.month,now.day,tod.hour, tod.minute, 0);
  return result;
}

int subtractDateTimeToInt(DateTime startTime, DateTime endTime){
  //자료형이 DateTime인 두 시간을 뺄샘하여 시간 간격 차이를 초단위로 바꾸고 반환하는 함수.
  DateTime time;
  int result = 0;
  startTime.compareTo(endTime) <= -1 ?
  time =  endTime.subtract(Duration(hours: startTime.hour,minutes: startTime.minute,seconds: startTime.second))
      :  time = startTime.subtract(Duration(hours: endTime.hour,minutes: endTime.minute,seconds: endTime.second));
  //시작 시각을 종료 시각과 비교. 시작 시각이 미래인 경우 시작 시각으로부터 종료 시각을 빼고,
  //종료 시각이 미래인 경우 종료 시각으로부터 시작 시각을 뺀 후 time 변수에 담음.

  startTime.compareTo(endTime) <= -1 ?
  result = ((time.hour * 60 * 60) + (time.minute * 60) + time.second)
      : result = - ((time.hour * 60 * 60) + (time.minute * 60) + time.second);

  return result;
}
