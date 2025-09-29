import 'package:socket_io_client/socket_io_client.dart' as io;

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  io.Socket? _socket;
  bool _isConnected = false;
  String? _userId;
  String? _userType;
  String? _currentOrderId;

  // Callbacks
  Function(Map<String, dynamic>)? onNewMessage;
  Function(Map<String, dynamic>)? onLocationUpdate;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(String)? onError;

  bool get isConnected => _isConnected;

  void connect(String serverUrl, String userId, String userType) {
    if (_isConnected) {
      disconnect();
    }

    _userId = userId;
    _userType = userType;

    _socket = io.io(serverUrl, io.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .build());

    _setupEventListeners();
  }

  void _setupEventListeners() {
    _socket?.onConnect((_) {
      _isConnected = true;
      print('WebSocket connected');
      
      // Authenticate user
      _socket?.emit('authenticate', {
        'userId': _userId,
        'userType': _userType,
        'token': 'dummy_token' // TODO: Replace with actual JWT token
      });
      
      onConnected?.call();
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
      print('WebSocket disconnected');
      onDisconnected?.call();
    });

    _socket?.onConnectError((error) {
      print('WebSocket connection error: $error');
      onError?.call('Connection failed: $error');
    });

    _socket?.onError((error) {
      print('WebSocket error: $error');
      onError?.call('Socket error: $error');
    });

    _socket?.on('authenticated', (data) {
      print('Authentication successful');
    });

    _socket?.on('authentication_failed', (data) {
      print('Authentication failed: $data');
      onError?.call('Authentication failed');
    });

    _socket?.on('joined_order', (data) {
      print('Joined order: $data');
    });

    _socket?.on('new_message', (data) {
      print('New message received: $data');
      onNewMessage?.call(data);
    });

    _socket?.on('location_update', (data) {
      print('Location update received: $data');
      onLocationUpdate?.call(data);
    });

    _socket?.on('chat_history', (data) {
      print('Chat history received: ${data['messages']?.length} messages');
    });

    _socket?.on('error', (data) {
      print('Server error: $data');
      onError?.call(data['message'] ?? 'Unknown error');
    });
  }

  void joinOrder(String orderId) {
    if (!_isConnected || _socket == null) {
      onError?.call('Not connected to server');
      return;
    }

    _currentOrderId = orderId;
    _socket?.emit('join_order', {'orderId': orderId});
  }

  void sendMessage(String message, {String messageType = 'text'}) {
    if (!_isConnected || _socket == null || _currentOrderId == null) {
      onError?.call('Cannot send message: not connected or no order joined');
      return;
    }

    _socket?.emit('send_message', {
      'orderId': _currentOrderId,
      'message': message,
      'messageType': messageType
    });
  }

  void updateLocation({
    required double latitude,
    required double longitude,
    required String address,
    double accuracy = 10.0,
    double speed = 0.0,
    double heading = 0.0,
  }) {
    if (!_isConnected || _socket == null || _currentOrderId == null) {
      onError?.call('Cannot update location: not connected or no order joined');
      return;
    }

    _socket?.emit('update_location', {
      'orderId': _currentOrderId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
    });
  }

  void markMessagesAsRead(List<String> messageIds) {
    if (!_isConnected || _socket == null || _currentOrderId == null) {
      return;
    }

    _socket?.emit('mark_messages_read', {
      'orderId': _currentOrderId,
      'messageIds': messageIds
    });
  }

  void leaveOrder() {
    if (_currentOrderId != null) {
      _socket?.emit('leave_order', {'orderId': _currentOrderId});
      _currentOrderId = null;
    }
  }

  void disconnect() {
    leaveOrder();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _userId = null;
    _userType = null;
    _currentOrderId = null;
  }

  // Clean up resources
  void dispose() {
    disconnect();
    onNewMessage = null;
    onLocationUpdate = null;
    onConnected = null;
    onDisconnected = null;
    onError = null;
  }
}
