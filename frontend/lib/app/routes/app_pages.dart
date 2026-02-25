import 'package:get/get.dart';
import '../bindings/auth_binding.dart';
import '../bindings/profile_binding.dart';
import '../bindings/chat_binding.dart';
import '../../modules/auth/views/landing_view.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/register_view.dart';
import '../../modules/profile/views/profile_view.dart';
import '../../modules/profile/views/edit_profile_view.dart';
import '../../modules/profile/views/interests_view.dart';
import '../../modules/chat/views/chat_list_view.dart';
import '../../modules/chat/views/chat_room_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.landing,
      page: () => const LandingView(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.interests,
      page: () => const InterestsView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.chatList,
      page: () => const ChatListView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.chatRoom,
      page: () => const ChatRoomView(),
      binding: ChatBinding(),
    ),
  ];
}
