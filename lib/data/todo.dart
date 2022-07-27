import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../ui/index_page.dart';

class Todo {
  int? id;
  String? title;
  String? note;
  String? startTime;
  String? endTime;
  int? color;
  List? repeat;
  List? timeLog;

  Todo({
    this.id,
    this.title,
    this.note,
    this.startTime,
    this.color,
    this.repeat,
    this.endTime,
    this.timeLog
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'startTime': startTime,
      'endTime': endTime,
      'color': color,
      'repeat' : repeat,
      'timeLog' : timeLog
    };
  }
}

bool isTimeNested({required Todo schedule, required List<Todo> todoList}){

  //각 todo 일정들이 서로 겹치는 시간이 있는지 없는지를 판별하여 return 해주는 함수.


  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.jm();
    return TimeOfDay.fromDateTime(format.parse(tod));
  }

  for(Todo i in todoList){
    for(int j =0; j < 7; j++){
      if((i.id != schedule.id) && (schedule.repeat![j] == true && i.repeat![j] == true)){
        if((stringToTimeOfDay(schedule.startTime!).hour < stringToTimeOfDay(i.startTime!).hour ||
            (stringToTimeOfDay(schedule.startTime!).hour == stringToTimeOfDay(i.startTime!).hour
                && stringToTimeOfDay(schedule.startTime!).minute < stringToTimeOfDay(i.startTime!).minute))
            &&(stringToTimeOfDay(schedule.endTime!).hour > stringToTimeOfDay(i.startTime!).hour ||
                (stringToTimeOfDay(schedule.endTime!).hour == stringToTimeOfDay(i.startTime!).hour
                    && stringToTimeOfDay(schedule.endTime!).minute > stringToTimeOfDay(i.startTime!).minute))){
          return true;
        } else if(
        (stringToTimeOfDay(schedule.startTime!).hour > stringToTimeOfDay(i.startTime!).hour ||
            (stringToTimeOfDay(schedule.startTime!).hour == stringToTimeOfDay(i.startTime!).hour &&
                stringToTimeOfDay(schedule.startTime!).minute >= stringToTimeOfDay(i.startTime!).minute))
            &&(stringToTimeOfDay(schedule.startTime!).hour < stringToTimeOfDay(i.endTime!).hour ||
            (stringToTimeOfDay(schedule.startTime!).hour == stringToTimeOfDay(i.endTime!).hour &&
                stringToTimeOfDay(schedule.startTime!).minute < stringToTimeOfDay(i.endTime!).minute))
        ){
          return true;
        }else{
          return false;
        }
      }
    }
  }

  return false;
}

int generateID(List<Todo> todoList){
  //각 todo는 서로 다른 고유한 id 값을 가져야하므로,
  //0부터 최대 128까지 todoList에 겹치지 않는 id 값 중 가장 작은 값은 return 해주는 함수.
  int id = 0;
  List<int> idList = List.empty(growable: true);

  for(Todo i in todoList){
    idList.add(i.id!);
  }
  for(int j = 0; j < 128; j++){
    if(!idList.contains(j)){
      id = j;
      break;
    }
  }

  return id;
}