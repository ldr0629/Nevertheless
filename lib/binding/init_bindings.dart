import 'dart:io';

import 'package:get/get.dart';
import '../controller/bottom_nav_controller.dart';

class InitBinding extends Bindings {
  //Getx의 페이지 이동 기능을 사용하기 위해 붙여 넣은 코드
  
  @override
  void dependencies() {
    Get.put(BottomNavController(), permanent: true);
    //"controller" 폴더 내부에 존재하는 BottomNavController 클래스의 객체를 생성하여 binding의 종속성에 추가
  }

}