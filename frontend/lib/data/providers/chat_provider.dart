import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/message_model.dart';

class ChatProvider {
  final ApiClient _api;

  ChatProvider(this._api);

  Future<MessageModel> sendMessage(String receiverId, String content) async {
    final response = await _api.post(ApiConstants.sendMessage, data: {
      'receiverId': receiverId,
      'content': content,
    });
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final messageData = data['data'] ?? data;
      if (messageData is Map<String, dynamic>) {
        return MessageModel.fromJson(messageData);
      }
    }
    throw Exception('Unexpected response format');
  }

  Future<List<MessageModel>> viewMessages(String receiverId) async {
    final response = await _api.get(
      ApiConstants.viewMessages,
      queryParams: {'receiverId': receiverId},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final messages = data['data'] ?? data['messages'];
      if (messages is List) {
        return messages
            .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
            .toList();
      }
    }
    if (data is List) {
      return data
          .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
