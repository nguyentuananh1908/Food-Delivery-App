import 'package:flutter/foundation.dart';
import '../models/realtime_chat_message.dart';
import '../services/realtime_websocket_service.dart';
import '../services/realtime_api_service.dart';

class RealtimeChatProvider with ChangeNotifier {
  final RealtimeWebSocketService _websocketService = RealtimeWebSocketService();
  final RealtimeApiService _apiService = RealtimeApiService();

  List<RealtimeChatMessage> _messages = [];
  bool _isLoading = false;
  String? _currentOrderId;
  String? _currentUserId;
  String? _currentUserType;
  int _unreadCount = 0;

  List<RealtimeChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get currentOrderId => _currentOrderId;
  int get unreadCount => _unreadCount;

  void initialize(String userId, String userType) {
    _currentUserId = userId;
    _currentUserType = userType;

    // Setup WebSocket callbacks
    _websocketService.onNewMessage = _handleNewMessage;
    _websocketService.onConnected = _handleConnected;
    _websocketService.onDisconnected = _handleDisconnected;
    _websocketService.onError = _handleError;
  }

  Future<void> connectToOrder(String orderId) async {
    if (_currentUserId == null || _currentUserType == null) {
      throw Exception('User not initialized');
    }

    _currentOrderId = orderId;
    _isLoading = true;
    notifyListeners();

    try {
      // Connect to WebSocket server
      _websocketService.connect(
        'http://localhost:3000', // TODO: Make this configurable
        _currentUserId!,
        _currentUserType!,
      );

      // Load chat history
      await _loadChatHistory(orderId);

      // Join order room
      _websocketService.joinOrder(orderId);

    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _loadChatHistory(String orderId) async {
    try {
      final response = await _apiService.get('/chat/order/$orderId');
      if (response['messages'] != null) {
        _messages = (response['messages'] as List)
            .map((json) => RealtimeChatMessage.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }

  void sendMessage(String message, {String messageType = 'text'}) {
    if (_currentOrderId == null) {
      throw Exception('No order connected');
    }

    _websocketService.sendMessage(message, messageType: messageType);
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    final message = RealtimeChatMessage.fromJson(data['message']);
    
    // Check if message already exists to avoid duplicates
    final exists = _messages.any((m) => m.id == message.id);
    if (!exists) {
      _messages.add(message);
      notifyListeners();
    }

    // Update unread count if message is not from current user
    if (message.senderId != _currentUserId) {
      _unreadCount++;
      notifyListeners();
    }
  }

  void _handleConnected() {
    print('Realtime Chat connected');
  }

  void _handleDisconnected() {
    print('Realtime Chat disconnected');
  }

  void _handleError(String error) {
    print('Realtime Chat error: $error');
  }

  Future<void> markMessagesAsRead(List<String> messageIds) async {
    if (messageIds.isEmpty) return;

    try {
      await _apiService.post('/chat/mark-read', {
        'messageIds': messageIds,
        'userId': _currentUserId,
        'userType': _currentUserType,
      });

      // Update local message read status
      for (int i = 0; i < _messages.length; i++) {
        if (messageIds.contains(_messages[i].id)) {
          // Create a new message with updated read status
          final message = _messages[i];
          _messages[i] = RealtimeChatMessage(
            id: message.id,
            orderId: message.orderId,
            senderId: message.senderId,
            senderType: message.senderType,
            message: message.message,
            messageType: message.messageType,
            isRead: true,
            readBy: message.readBy,
            createdAt: message.createdAt,
            updatedAt: message.updatedAt,
          );
        }
      }
      notifyListeners();

      // Also send via WebSocket
      _websocketService.markMessagesAsRead(messageIds);

    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Future<void> loadUnreadCount() async {
    if (_currentUserId == null || _currentUserType == null) return;

    try {
      final response = await _apiService.get('/chat/unread/$_currentUserId?userType=$_currentUserType');
      _unreadCount = response['unreadCount'] ?? 0;
      notifyListeners();
    } catch (e) {
      print('Error loading unread count: $e');
    }
  }

  void disconnect() {
    _websocketService.leaveOrder();
    _messages.clear();
    _currentOrderId = null;
    _unreadCount = 0;
    notifyListeners();
  }

  void clearUnreadCount() {
    _unreadCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _websocketService.dispose();
    super.dispose();
  }
}
