class ChatMessage {
  final String id;
  final String orderId;
  final String senderId;
  final String senderType; // 'customer', 'shipper', 'admin'
  final String message;
  final String messageType; // 'text', 'image', 'location', 'system'
  final bool isRead;
  final List<ReadBy> readBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatMessage({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.senderType,
    required this.message,
    required this.messageType,
    required this.isRead,
    required this.readBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? '',
      orderId: json['orderId'] ?? '',
      senderId: json['senderId'] is Map 
          ? json['senderId']['_id'] ?? ''
          : json['senderId']?.toString() ?? '',
      senderType: json['senderType'] ?? '',
      message: json['message'] ?? '',
      messageType: json['messageType'] ?? 'text',
      isRead: json['isRead'] ?? false,
      readBy: (json['readBy'] as List?)
          ?.map((item) => ReadBy.fromJson(item))
          .toList() ?? [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderId': orderId,
      'senderId': senderId,
      'senderType': senderType,
      'message': message,
      'messageType': messageType,
      'isRead': isRead,
      'readBy': readBy.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get senderName {
    if (senderId.isEmpty) return 'System';
    // TODO: Get actual sender name from user data
    switch (senderType) {
      case 'customer':
        return 'Customer';
      case 'shipper':
        return 'Shipper';
      case 'admin':
        return 'Admin';
      default:
        return 'Unknown';
    }
  }

  bool get isSystemMessage => messageType == 'system' || senderId.isEmpty;
}

class ReadBy {
  final String userId;
  final String userType;
  final DateTime readAt;

  ReadBy({
    required this.userId,
    required this.userType,
    required this.readAt,
  });

  factory ReadBy.fromJson(Map<String, dynamic> json) {
    return ReadBy(
      userId: json['userId'] ?? '',
      userType: json['userType'] ?? '',
      readAt: DateTime.tryParse(json['readAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userType': userType,
      'readAt': readAt.toIso8601String(),
    };
  }
}
