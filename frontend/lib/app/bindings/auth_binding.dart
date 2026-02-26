import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../data/providers/auth_provider.dart';
import '../../modules/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApiClient(), fenix: true);
    Get.lazyPut(() => AuthProvider(Get.find()), fenix: true);
    Get.lazyPut(() => AuthController(), fenix: true);
  }
}
