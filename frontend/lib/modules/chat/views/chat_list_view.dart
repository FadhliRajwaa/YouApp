import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/common_widgets.dart';
import '../controllers/chat_controller.dart';

class ChatListView extends GetView<ChatController> {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Get.back(),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chevron_left,
                                  color: Colors.white, size: 24),
                              SizedBox(width: 2),
                              Text('Back',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Messages',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    const SizedBox(width: 60),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.inputBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const TextField(
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      border: InputBorder.none,
                      hintText: 'Search',
                      hintStyle:
                          TextStyle(color: AppColors.white40, fontSize: 14),
                      icon: Icon(Icons.search, color: AppColors.white40),
                    ),
                  ),
                ),
              ),

              // Chat list
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          color: AppColors.white40, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'No messages yet',
                        style:
                            TextStyle(color: AppColors.white40, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start a conversation by entering\na user ID below',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: AppColors.white40, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: GradientButton(
                          text: 'New Chat',
                          onPressed: () => _showNewChatDialog(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    final idController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF162329),
        title: const Text('New Chat',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: idController,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter User ID',
            hintStyle:
                const TextStyle(color: AppColors.white40, fontSize: 14),
            filled: true,
            fillColor: AppColors.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.white40)),
          ),
          TextButton(
            onPressed: () {
              final userId = idController.text.trim();
              if (userId.isNotEmpty) {
                Navigator.pop(ctx);
                controller.setReceiver(userId, userId);
                Get.toNamed(AppRoutes.chatRoom);
              }
            },
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.goldenGradient.createShader(bounds),
              child: const Text('Start Chat',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
