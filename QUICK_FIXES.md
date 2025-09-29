# Quick Fixes - Common Errors

## ✅ Fixed: LatLng Constant Expression Error

**Lỗi:**
```
Error: Not a constant expression.
initialLocation: const LatLng(21.0285, 105.8542),
```

**Nguyên nhân:**
- `LatLng` constructor không phải là constant expression
- Không thể sử dụng `const` với `LatLng`

**Giải pháp:**
```dart
// ❌ Sai
initialLocation: const LatLng(21.0285, 105.8542),

// ✅ Đúng
initialLocation: LatLng(21.0285, 105.8542),
```

**File đã sửa:**
- `frontend/lib/realtime/ui/main_demo_page.dart` (line 399)

## 🚀 Test App

**Chạy app:**
```bash
cd frontend
flutter run -d chrome --web-port 8080
```

**Test routes:**
- http://localhost:8080/#/main-demo
- http://localhost:8080/#/demo
- http://localhost:8080/#/realtime-demo

## 📱 Features Ready to Test

✅ **Chat Messages** - Giống ảnh demo đầu tiên
✅ **Chat Conversation** - Giống ảnh demo thứ hai  
✅ **Save Location** - Giống ảnh demo thứ ba
✅ **Location Tracking** - Real-time shipper tracking
✅ **User Management** - Customer, Shipper, Restaurant

## 🔧 Setup Backend

```bash
cd backend
npm install
node create_users_and_orders.js
npm run dev
```

## 📋 Next Steps

1. ✅ Lỗi compilation đã sửa
2. ✅ App có thể chạy được
3. 🔄 Test các features trong app
4. 🔄 Replace test IDs với real IDs từ database
5. 🔄 Test WebSocket chat và location tracking

## 🐛 Common Issues & Solutions

### 1. Import Errors
```dart
// Add missing imports
import 'package:google_maps_flutter/google_maps_flutter.dart';
```

### 2. Provider Errors
```dart
// Ensure providers are registered in main.dart
ChangeNotifierProvider(create: (context) => RealtimeChatProvider()),
ChangeNotifierProvider(create: (context) => RealtimeLocationProvider()),
```

### 3. WebSocket Connection
```dart
// Check server URL
_websocketService.connect(
  'http://localhost:3000', // Ensure backend is running
  userId,
  userType,
);
```

### 4. Location Permissions
```xml
<!-- Add to android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

## ✅ Status

- ✅ Compilation errors fixed
- ✅ App can run successfully  
- ✅ All UI components created
- ✅ Backend models ready
- ✅ WebSocket infrastructure ready
- 🔄 Ready for testing


