import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../widgets/common_widgets.dart';
import '../../../data/models/message_model.dart';
import '../controllers/chat_controller.dart';

class ChatRoomView extends GetView<ChatController> {
  const ChatRoomView({super.key});

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
                    Obx(() => Text(
                          controller.currentReceiverName.value,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        )),
                    const Spacer(),
                    const SizedBox(width: 60),
                  ],
                ),
              ),

              const Divider(color: AppColors.white30, height: 1),

              // Messages
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.messages.isEmpty) {
                    return const Center(
                      child: Text('No messages yet. Say hello!',
                          style:
                              TextStyle(color: AppColors.white40, fontSize: 14)),
                    );
                  }

                  return FutureBuilder<String?>(
                    future: _getCurrentUserId(),
                    builder: (context, snapshot) {
                      final currentUserId = snapshot.data ?? '';
                      return ListView.builder(
                        controller: controller.scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          final message = controller.messages[index];
                          final isMine = message.senderId == currentUserId;
                          return _buildMessageBubble(message, isMine);
                        },
                      );
                    },
                  );
                }),
              ),

              // Input bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF162329),
                  border: Border(
                    top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: controller.messageController,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            border: InputBorder.none,
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                                color: AppColors.white40, fontSize: 14),
                          ),
                          onSubmitted: (_) => controller.sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: controller.sendMessage,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryButton,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.userId);
  }

  Widget _buildMessageBubble(MessageModel message, bool isMine) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          gradient: isMine ? AppColors.primaryButton : null,
          color: isMine ? null : const Color(0xFF1A2E35),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
