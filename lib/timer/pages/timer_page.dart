import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../../data/todo.dart';
import '../../todo/pages/todo_detail_page.dart';
import '../widgets/pomodoro_timer.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({Key? key, required this.todoList}) : super(key : key);
  @override
  State<TimerPage> createState() => _TimerPageState();
  final List<Todo> todoList;
}

class _TimerPageState extends State<TimerPage> {
  List<Widget> todoWidgetList = [];
  // 메인 화면 타이머 하단부에 리스트 형식으로 todo들을 보여주기 위한 변수
  List<Todo> todayTodoList = List.empty(growable: true);
  // 전체 todo 중, 오늘 진행할 todo만을 보여주기 위한 리스트
  bool isNotification = true;

  final storage = GetStorage();
  final flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();
  final CountDownController countDownController = CountDownController();

  @override
  Widget build(BuildContext context) {

    todoWidgetList = List.empty(growable: true);
    todayTodoList = List.empty(growable: true);

    widget.todoList.sort((a,b) =>
        DateFormat('hh:mm a').parse(a.startTime!)
            .compareTo( DateFormat('hh:mm a').parse(b.startTime!)));

    isNotification = storage.read('notification') ?? true;

    for( Todo i in widget.todoList) {
      if (i.repeat![DateTime.now().weekday - 1]! ) {
        todoWidgetList.add(
            Card(
                color: Color(i.color!),
                child: ListTile(
                  title: Text(i.title!,maxLines: 1, overflow: TextOverflow.ellipsis,),
                  subtitle: Text(i.note!,maxLines: 1, overflow: TextOverflow.ellipsis,),
                  trailing: Text("${i.startTime!} ~ ${i.endTime!}"),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                        builder: (context) => TodoDetailPage(todo: i))
                    ).then((value) {
                      setState(() {});
                    });
                  },
                )
            ));
        todayTodoList.add(i);
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Timer'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 16),
            child: IconButton(
              //아이콘 버튼 위젯입니다.
              icon:  isNotification == true ? const Icon(Icons.notifications): const Icon(Icons.notifications_off),
              onPressed: (){
                if (isNotification == true) {
                  setState((){
                    storage.write('notification', false);
                  });
                } else {
                  setState((){
                    storage.write('notification', true);
                  });
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          PomodoroTimer(todayTodoList: todayTodoList,
              controller: countDownController),
          todoWidgetList.isNotEmpty ? Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: todoWidgetList,
            ),
          ) : Container()
        ],
      ),
    );
  }
}