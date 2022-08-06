import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/todo.dart';
import '../../index_page.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({Key? key, required this.todoList}) : super(key: key);
  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  List<double> yList = List.empty(growable : true);
// 요일별 차트의 봉에 해당하는 높이를 담고 있는 변수. todo의 timeLog 값에 비례.

  @override
  Widget build(BuildContext context) {

    final storage = GetStorage();
    DateTime now = DateTime.now();

    boll init = storage.read('init') ?? false; // 차트는 매주 월요일에 초기화
    if(now.weekday == 1 && !init) { // 월요일인데 초기화가 되지 않았다면
      for(Todo i in todoList) {
        i.timeLog = null;
      }
      storage.write('init', true);
    } else if(now.weekday != 1) {
      storage.write('init', false);
    }
    yList = List.empty(growable: true);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Chart"),
      ),
      body: Center(
        child : Padding(
          padding: const EdgeInsets.all(12),
          child : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children : [
              Row(
                children: [
                  const Text(
                    '주별 기록',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeigt: FontWeight.bold,
                    ),
                  ),
                    Text(
                      '(${now.weekday > 1 ? 8 - now.weekday: 7}일 후 갱신)',
                      //1주일마다 todo의 timeLog가 갱신된다는 것을 알리기 위한 텍스트.
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              IconButton(onPressed: ()) {
                showCupertinoDialog(context: context, builder: (context)) {
                  return CupertinoAlertDialog(
                    content: const Text(
                            "1. 시간이 기록되려면 반드시 일정의 종료시각을 거쳐야합니다\n\n"
                            "2. 일정 진행 중에 앱을 종료할 경우, 앱을 다시 시작한 시각으로부터 종료 시각까지의 시간을 계산합니다\n\n"
                            "3. 일정 진행 중에 시작 시각을 앞당기더라도 기록에 반영되지 않습니다", textAlign: TextAlign.start,),
                    actions: [
                      CupertinoDialogAction(isDefaultAction : false, child:const Text("확인"), onPressed: ()) {
                      Navigator.pop(context);
                    })
                    ],
                  );
                });
                },
                  icon: const Icon(Icons.info_outline, size: 24, color: Colors.amber,))
                ],
          ),
          const SizedBox(height: 8),
          todoListWidget(widget.todoList),
            const SizedBox(height: 14),
            Expanded(
              child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    titlesData: FlTitlesData(
                        leftTitles: AxisTitles(),
                        rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                        showTitles: true,
                        interval: 60,
                        getTitlesWidget: rightTitles,
                        reservedSize: 32
                    )
                ),
              topTitles: AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: bottomTitles,
                  ),
                ),
              ),
            barTouchData: BarTouchData(enabled: false),
            //bar를 클릭 했을 때 이벤트인 터치와 같은 시스템을 구현할 경우 true 값을 사용.
            borderData: FlBorderData(show: false),
            //경계선을 표시할지에 대한 옵션.
            gridData: FlGridData(show: false),
            //격자무늬 표시를 할지 여부를 결정하는 옵션.
            barGroups: [
                //차트에 들어가는 내부 데이터를 집어넣는 부분.
                generateGroupData(0, widget.todoList),
                //generateGroupData() 함수는 클래스 하단부에 구현되어 있는 각 todo의 timeLog 데이터를
                //집어 넣어 줄 함수. 0부터 월요일을 의미
                generateGroupData(1, widget.todoList),
                generateGroupData(2, widget.todoList),
                generateGroupData(3, widget.todoList),
                generateGroupData(4, widget.todoList),
                generateGroupData(5, widget.todoList),
                generateGroupData(6, widget.todoList),
                //6은 일요일을 뜻합니다
            ],
            maxY: ((yList.reduce(max)~/60 * 60) +60).toDouble(),
            //차트의 최대 높이입니다. 해당 차트에서 todo의 timeLog 값은 곧 높이를 의미하므로
            //현재 모든 todo의 timeLog는 yList에 존재. 해당 리스트로부터 reduce(max) 메소드를 이용해
            //최대값(단위 : 분)을 추출하고 60으로 나눈 몫을 구합니다(이렇게 하면 시간이 아닌 분에 해당하는 나머지 부분은버려지게 됨).
             //그리고 다시 60을 곱하게 되면 시간 단위만 남는데 여기에 60을 더해줌으로써 단위를
            //시간으로 통일합니다(Ex: 2시간 0분은 2시간, 2시간 1~59분은 3시간으로 표기됩니다).
            ),
          ),
        ),
        ],
      ),
    ),
    ),
    );
  }
  BarChartGroupData generateGroupData(int x, List<Todo?> todoList) {
    List<BarChartRodData temp = List.empty(growable: true);
    //임시로 특정 요일에 대한 모든 todo의 timeLog 정보를 담은 BarChartRodData를 저장할 리스트
    double sumY = 0;
    if(todoList.isNotEmpty) {
      for(Todo? i in todoList) {
        for(int j = 0; j<7; j++) {
          if(j == x && i != null && i.timeLog != null) {
            //만약 timeLog의 요일에 해당하는 부분과 차트의 요일에 해당하는 부분이 일치하고
            //todo 객체와 객체의 timeLog가 null이 아닐 경우
            temp.add(
              BarChartRodData(
                fromY: sumY,
                toY: (i.timeLog![j]).toDouble() + sumY,
                width: 8,
                color: Color(i.color!)
              )
            );
            sumY += (i.timeLog![i]).toDouble();
          }
        }
      }
    }
    YList.add(sumY);
    return BarChartGroupData(
      //todoList를 돌면서 bar 정보를 완성 후 기존 barGroups로 반환
      x: x,
      groupVertically: true,
      barRods: temp
    );
   }
  Widget rightTitles(double value, TitleMeta meta) {
    //BarChartData의 오른쪽 텍스트로 시간 단위가 적혀있는 부분.
    const style = TextStyle(color: Colors.white, fontSize: 10);
    String text;
    if (value == 0) {
      text = '0';
    } else {
      text = '${value.toInt()~/60} hours';
    }
    return SideTitleWidget(
      angle: 0,
      axisSide: meta.axisSide,
      space: 0,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    //차트의 하단부에 들어갈 요일을 표시할 부분.
    const style = TextStyle(
      color: Color(0xffffffff),
      fontSize: 10,
    );
    String text;
    //임시적으로 텍스트를 담을 변수입니다.
    switch (value.toInt()) {
    //총 value는 요일의 총수인 0부터 6까지에 해당하며 BarChart에서 자동으로 인덱스를 증가시켜 대입.
    //이에 따라 인덱스별 텍스트를 지정해줍니다.
      case 0:
        text = "Mon";
        break;
      case 1:
        text = "Tue";
        break;
      case 2:
        text = "Wed";
        break;
      case 3:
        text = "Thr";
        break;
      case 4:
        text = "Fri";
        break;
      case 5:
        text = "Sat";
        break;
      case 6:
        text = "Sun";
        break;
      default:
        text = "";
    }
    return SideTitleWidget(
      child: Text(text, style: style),
      axisSide: meta.axisSide,
    );
  }

  Widget todoListWidget(List<Todo?>todoList){
    //차트 상단에 todo의 색상과 제목을 띄워 Bar를 쉽게 찾을 수 있도록 도와주는 위젯을 반환하는 함수.
    if(todoList.isNotEmpty){
      //todoList가 비어 있지 않다면 Wrap 위젯을 반환.
      return Wrap(
        //Wrap 위젯은 todo의 갯수가 증가하여 더이상 한줄로 제목 및 색상을 배열할 수 없을 때
        //이어서 다음줄로 내려 추가.
        spacing: 16,
        children: todoList.map((e) => e!.timeLog != null ? Row(
          //Wrap 위젯은 List<Widget>형식인 children 속성을 가지므로 todoList.map() 메소드를 통해
          //todoList 내부에 있는 각 원소들(e)로 부터 정보를 가져와 Row 위젯에 배열. 만약 해당 todo의 timeLog가
          //null 값일 경우 빈 Container 위젯을 반환.
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(e.color!),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              e.title!,
              style: const TextStyle(
                color: Color(0xffffffff),
                fontSize: 12,
              ),
            ),
          ],
        ) : Container() ).toList(),
        //children 속성이 List<Widget> 이므로 해당 Row 위젯을 todoList.map().toList() 형식으로 리스트로 만들어 줘야 함.
      );
    }else {
      //todoList가 비어있다면 빈 Container를 반환합니다.
      return Container();
    }
  }
}