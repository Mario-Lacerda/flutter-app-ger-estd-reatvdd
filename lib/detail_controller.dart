import 'package:get/get.dart';

class DetailController extends GetxController {
  var favorite = 0.obs;

  void favCounter() {
    if (favorite.value == 1) {
      Get.snackbar('amei', 'Você já amou isso');
    } else {
      favorite.value++;
      Get.snackbar('amei', 'Você amou isso');
    }
  }
}
