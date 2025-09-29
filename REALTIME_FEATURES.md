# Realtime Features - Separated Implementation

## Tổng quan

Đây là phiên bản tách biệt của các tính năng realtime chat và location tracking, được tổ chức trong thư mục `frontend/lib/realtime/` để tránh xung đột với code cũ.

## Cấu trúc thư mục

```
frontend/lib/realtime/
├── models/
│   ├── realtime_chat_message.dart      # Model cho tin nhắn chat
│   └── realtime_location_data.dart     # Model cho dữ liệu vị trí
├── services/
│   ├── realtime_websocket_service.dart # WebSocket service
│   └── realtime_api_service.dart       # API service
├── providers/
│   ├── realtime_chat_provider.dart     # State management cho chat
│   └── realtime_location_provider.dart # State management cho location
├── ui/
│   ├── realtime_chat_page.dart         # Giao diện chat
│   ├── realtime_tracking_page.dart     # Giao diện tracking
│   └── realtime_demo_page.dart         # Trang demo
└── realtime.dart                       # Export file
```

## Tính năng chính

### 🔥 Realtime Chat
- **File**: `RealtimeChatPage`
- **Provider**: `RealtimeChatProvider`
- **Model**: `RealtimeChatMessage`

**Tính năng:**
- ✅ Chat realtime qua WebSocket
- ✅ Lịch sử tin nhắn
- ✅ Đánh dấu đã đọc
- ✅ Tin nhắn hệ thống
- ✅ Phân loại user (customer, shipper, admin)
- ✅ Room-based messaging

### 🗺️ Location Tracking
- **File**: `RealtimeTrackingPage`
- **Provider**: `RealtimeLocationProvider`
- **Model**: `RealtimeLocationData`

**Tính năng:**
- ✅ Cập nhật vị trí realtime
- ✅ Google Maps integration
- ✅ Hiển thị route với polylines
- ✅ Lịch sử vị trí
- ✅ GPS accuracy và speed
- ✅ Auto camera movement

## Cách sử dụng

### 1. Import Realtime Features

```dart
import 'package:your_app/realtime/realtime.dart';
```

### 2. Sử dụng trong Provider

```dart
// Trong main.dart
ChangeNotifierProvider(create: (context) => RealtimeChatProvider()),
ChangeNotifierProvider(create: (context) => RealtimeLocationProvider()),
```

### 3. Sử dụng Chat

```dart
// Khởi tạo chat
final chatProvider = Provider.of<RealtimeChatProvider>(context, listen: false);
chatProvider.initialize(userId, userType);
await chatProvider.connectToOrder(orderId);

// Gửi tin nhắn
chatProvider.sendMessage('Hello!');

// Lắng nghe tin nhắn mới
chatProvider.onNewMessage = (data) {
  // Xử lý tin nhắn mới
};
```

### 4. Sử dụng Location Tracking

```dart
// Khởi tạo location tracking
final locationProvider = Provider.of<RealtimeLocationProvider>(context, listen: false);
locationProvider.initialize(shipperId);

// Bắt đầu tracking
await locationProvider.startLocationTracking(orderId);

// Lắng nghe cập nhật vị trí
locationProvider.onLocationUpdate = (data) {
  // Xử lý cập nhật vị trí
};
```

### 5. Sử dụng UI Components

```dart
// Chat Page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RealtimeChatPage(
      orderId: 'order_123',
      userId: 'user_123',
      userType: 'customer',
    ),
  ),
);

// Tracking Page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RealtimeTrackingPage(
      orderId: 'order_123',
      shipperId: 'shipper_123',
    ),
  ),
);
```

## Demo

### Truy cập Demo
1. Chạy app
2. Navigate đến `/demo` route
3. Click "Open Realtime Demo"
4. Hoặc truy cập trực tiếp `/realtime-demo`

### Test Chat
1. Chọn "Chat" demo
2. Click "Customer View" hoặc "Shipper View"
3. Gửi tin nhắn và xem realtime updates

### Test Location Tracking
1. Chọn "Tracking" demo
2. Click "View Tracking"
3. Xem bản đồ với vị trí shipper realtime

## So sánh với phiên bản cũ

| Tính năng | Phiên bản cũ | Phiên bản mới |
|-----------|--------------|---------------|
| **Namespace** | Trùng với code cũ | `Realtime*` prefix |
| **Models** | `ChatMessage`, `LocationData` | `RealtimeChatMessage`, `RealtimeLocationData` |
| **Providers** | `ChatProvider`, `LocationProvider` | `RealtimeChatProvider`, `RealtimeLocationProvider` |
| **Services** | `WebSocketService`, `ApiService` | `RealtimeWebSocketService`, `RealtimeApiService` |
| **UI** | `ChatPage`, `TrackingPage` | `RealtimeChatPage`, `RealtimeTrackingPage` |
| **Colors** | Orange theme | Blue theme |
| **Demo** | `/demo` route | `/realtime-demo` route |

## Lợi ích của việc tách biệt

### ✅ Tránh xung đột
- Không ảnh hưởng đến code cũ
- Có thể chạy song song
- Dễ dàng so sánh và test

### ✅ Tổ chức tốt hơn
- Code được nhóm theo chức năng
- Dễ maintain và extend
- Clear separation of concerns

### ✅ Dễ migrate
- Có thể dần dần chuyển đổi
- Test thoroughly trước khi replace
- Rollback dễ dàng nếu cần

## Migration Guide

### Từ phiên bản cũ sang mới

1. **Update imports:**
```dart
// Cũ
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';

// Mới
import 'package:your_app/realtime/realtime.dart';
```

2. **Update provider usage:**
```dart
// Cũ
Provider.of<ChatProvider>(context)

// Mới
Provider.of<RealtimeChatProvider>(context)
```

3. **Update UI components:**
```dart
// Cũ
ChatPage(orderId: orderId, userId: userId, userType: userType)

// Mới
RealtimeChatPage(orderId: orderId, userId: userId, userType: userType)
```

## Troubleshooting

### 1. Import errors
- Kiểm tra đường dẫn import
- Đảm bảo file `realtime.dart` tồn tại
- Check pubspec.yaml dependencies

### 2. Provider not found
- Đảm bảo provider đã được đăng ký trong main.dart
- Check MultiProvider setup
- Verify provider name (Realtime* prefix)

### 3. WebSocket connection issues
- Kiểm tra server có chạy không
- Check URL trong RealtimeWebSocketService
- Verify network connectivity

### 4. Location permission issues
- Kiểm tra permissions trong AndroidManifest.xml
- Test trên device thật
- Check location services

## Next Steps

1. **Testing**: Test thoroughly các tính năng mới
2. **Performance**: So sánh performance với phiên bản cũ
3. **Migration**: Lên kế hoạch migrate từ cũ sang mới
4. **Enhancement**: Thêm tính năng mới vào phiên bản realtime
5. **Documentation**: Cập nhật documentation cho team

## Support

Nếu gặp vấn đề:
1. Check console logs
2. Verify dependencies
3. Test trên device thật
4. So sánh với phiên bản cũ
5. Check network connectivity

