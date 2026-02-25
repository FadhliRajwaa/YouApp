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
    final data = response.data['data'] ?? response.data;
    return MessageModel.fromJson(data);
  }

  Future<List<MessageModel>> viewMessages(String receiverId) async {
    final response = await _api.get(
      ApiConstants.viewMessages,
      queryParams: {'receiverId': receiverId},
    );
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((m) => MessageModel.fromJson(m)).toList();
    }
    return [];
  }
}
