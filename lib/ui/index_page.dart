import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nevertheless/ui/timechart/pages/chart_page.dart';
import 'package:nevertheless/ui/timer/pages/timer_page.dart';
import 'package:nevertheless/ui/todo/pages/todo_page.dart';
import '../controller/bottom_nav_controller.dart';
import '../data/todo.dart';

List<Todo> todoList = [];
// 앱이 실행되는 동안 모든 todo들을 담고있는 리스트

class IndexScreen extends GetView<BottomNavController> {
  const IndexScreen({Key? key}) : super(key: key);
  //Getx를 사용하므로 StatefulWidget이 아닌 GetView 클래스를 사용.
  //또한 이전에 정의해둔 BottomNavController을 controller로 사용.
  @override
  Widget build(BuildContext context) {
    return Obx (() =>Scaffold(
      body : Center(
        child:
          IndexedStack(
            index: controller.pageIntex.value,
            children: <Widget>[
              TimerPage(todoList: todoList,), // 메인페이지
              TodoPage(todoList: todoList,), // todo 리스트를 보여주는 페이지
              ChartPage(todoList: todoList,) // todo의 timelog를 통해 차트를 보여주는 페이지
            ],
          )
      ),
      bottomNavigationBar: BottomNavigationBar(
        type : BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        currentIndex: controller.pageIntex.value,
        onTap: (value) { // 각 아이템을 클릭했을 때 어떤 이벤트를 발생시킬지 담고 있음
          controller.changeBottomNav(value);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Todo'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Chart'),
        ],
      ),
    ));
  }

}

loadTodoList(){
  //단말기의 저장소에 저장된 todo들을 불러와서 todoList에 담기 위한 함수.
  final storage = GetStorage();
  List list = storage.read("todoList") ?? [];

  todoList = [];
  for(var i in list){
    todoList.add(Todo(
      id :  i['id'],
      title : i['title'],
      note : i['note'],
      startTime : i['startTime'],
      endTime : i['endTime'],
      color : i['color'],
      repeat : i['repeat'],
      timeLog : i['timeLog'],
    ));
  }
}

void saveTodo() {
  // 단말기 저장소에 todo를 저장하는 함수
  final storage = GetStorage();
  List list = List.empty(growable: true);
  for(Todo i in todoList) {
    list.add(i.toMap());
  }
  storage.write("todoList", list);
}