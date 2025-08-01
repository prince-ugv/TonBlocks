import 'package:get/get.dart';
import '../../../data/services/ton_api_service.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Register TonApiService first
    Get.put<TonApiService>(TonApiService(), permanent: true);
    
    // Register HomeController
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
