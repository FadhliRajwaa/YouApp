import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../data/models/message_model.dart';
import '../../../data/providers/chat_provider.dart';

class ChatController extends GetxController {
  final messages = <MessageModel>[].obs;
  final isLoading = false.obs;
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  // Search
  final searchResults = <Map<String, dynamic>>[].obs;
  final isSearching = false.obs;

  late final ChatProvider _chatProvider;
  Timer? _pollTimer;

  // Current chat partner
  final currentReceiverId = ''.obs;
  final currentReceiverName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _chatProvider = ChatProvider(ApiClient());
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void setReceiver(String receiverId, String receiverName) {
    currentReceiverId.value = receiverId;
    currentReceiverName.value = receiverName;
    loadMessages();

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _silentlyRefreshMessages();
    });
  }

  Future<void> loadMessages() async {
    if (currentReceiverId.value.isEmpty) return;

    isLoading.value = true;
    try {
      final result =
          await _chatProvider.viewMessages(currentReceiverId.value);
      messages.value = result;
      _scrollToBottom();
    } on DioException catch (e) {
      _handleChatError(e, 'load');
    } catch (e) {
      debugPrint('Load messages error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _silentlyRefreshMessages() async {
    if (currentReceiverId.value.isEmpty) return;
    try {
      final result =
          await _chatProvider.viewMessages(currentReceiverId.value);
      if (result.length != messages.length) {
        messages.value = result;
        _scrollToBottom();
      }
    } catch (_) {}
  }

  void clearReceiver() {
    _pollTimer?.cancel();
    currentReceiverId.value = '';
    currentReceiverName.value = '';
    messages.clear();
  }

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }
    isSearching.value = true;
    try {
      final results = await _chatProvider.searchUsers(query.trim());
      searchResults.value = results;
    } catch (e) {
      debugPrint('Search users error: $e');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || currentReceiverId.value.isEmpty) return;

    messageController.clear();

    try {
      final message =
          await _chatProvider.sendMessage(currentReceiverId.value, text);
      messages.add(message);
      _scrollToBottom();
    } on DioException catch (e) {
      _handleChatError(e, 'send');
    } catch (e) {
      debugPrint('Send message error: $e');
      Get.snackbar('Error', 'Failed to send message: $e',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    }
  }

  void _handleChatError(DioException e, String action) {
    final statusCode = e.response?.statusCode;
    debugPrint('Chat $action error: $statusCode - ${e.response?.data}');

    if (statusCode == 404) {
      Get.snackbar(
        'Chat Unavailable',
        'Chat requires the YouApp backend server.\nChange baseUrl in api_constants.dart to your backend URL.',
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } else {
      String errorMsg = 'Failed to $action messages';
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        errorMsg = data['message'] is List
            ? (data['message'] as List).join(', ')
            : data['message'].toString();
      }
      Get.snackbar('Error', errorMsg,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
