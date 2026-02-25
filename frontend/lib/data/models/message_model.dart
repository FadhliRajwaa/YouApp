class MessageModel {
  final String? id;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final DateTime? createdAt;
  final SenderInfo? senderInfo;
  final SenderInfo? receiverInfo;

  MessageModel({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.isRead = false,
    this.createdAt,
    this.senderInfo,
    this.receiverInfo,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? json['id'],
      senderId: json['senderId'] is Map
          ? json['senderId']['_id']
          : json['senderId'] ?? '',
      receiverId: json['receiverId'] is Map
          ? json['receiverId']['_id']
          : json['receiverId'] ?? '',
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      senderInfo: json['senderId'] is Map
          ? SenderInfo.fromJson(json['senderId'])
          : null,
      receiverInfo: json['receiverId'] is Map
          ? SenderInfo.fromJson(json['receiverId'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'receiverId': receiverId,
        'content': content,
      };
}

class SenderInfo {
  final String id;
  final String? username;
  final String? name;

  SenderInfo({required this.id, this.username, this.name});

  factory SenderInfo.fromJson(Map<String, dynamic> json) {
    return SenderInfo(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'],
      name: json['name'],
    );
  }
}
