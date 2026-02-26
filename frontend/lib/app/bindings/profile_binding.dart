import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../../data/providers/profile_provider.dart';
import '../../modules/profile/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApiClient(), fenix: true);
    Get.lazyPut(() => ProfileProvider(Get.find()), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
  }
}
