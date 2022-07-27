import 'package:get/get.dart';
import '../ui/index_page.dart';

class BottomNavController extends GetxController {
  //BottomNavController은 IndexScreen 클래스에서 메인 화면에 표시되는 Canvas 위젯의 하단부인
  //BottomNavigationBar의 Item을 클릭시 어플이 페이지를 이동할 수 있게 도와주는 역할.

  @override
  void onInit() {
    super.onInit();
    loadTodoList();
  }

  RxInt pageIntex = 0.obs;

  void changeBottomNav(int value) {
    //BottomNavigationBar의 Item 클릭시마다 호출되는 함수로, 어떤 Item이 클릭되는지에 따라
    //각 페이지(0 -> timer, 1 -> todo, 2 -> chart)로 이동할 수 있음.
    switch(value) {
      case 0:
      case 1:
      case 2:
        _changePage(value);
        break;
    };
  }

  void _changePage(int value) {
    //BottomNavigationBar의 Item을 클릭시 PageIndex 값을 바꿔줌.
    pageIndex(value);
  }

}