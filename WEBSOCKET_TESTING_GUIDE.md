# Hướng dẫn Test WebSocket Chat & Location Tracking

## 🚀 Cách Test Không Cần Tài Khoản Thật

### 1. Test với Mock Data

**Bước 1: Chạy Backend Server**
```bash
cd backend
npm install
npm run dev
```
Server sẽ chạy trên `http://localhost:3000`

**Bước 2: Chạy Frontend App**
```bash
cd frontend
flutter run
```

**Bước 3: Test WebSocket Chat**
1. Mở app và navigate đến `/demo` hoặc `/realtime-demo`
2. Chọn "Chat" demo
3. Mở 2 tab/window:
   - Tab 1: Click "Customer View" 
   - Tab 2: Click "Shipper View"
4. Gửi tin nhắn từ cả 2 phía để test realtime

### 2. Test Location Tracking

**Bước 1: Chuẩn bị**
- Đảm bảo có location permissions
- Test trên device thật (không phải emulator)

**Bước 2: Test Tracking**
1. Navigate đến `/realtime-demo`
2. Chọn "Tracking" demo
3. Click "View Tracking"
4. App sẽ yêu cầu location permission
5. Cho phép và xem bản đồ hiển thị vị trí

## 🛠️ Test Scenarios Chi Tiết

### Scenario 1: Chat Between Customer & Shipper

```dart
// Test data mặc định
Customer ID: "customer_123"
Shipper ID: "shipper_123" 
Order ID: "order_123"
```

**Test Steps:**
1. Mở 2 instances của app (hoặc 2 devices)
2. Instance 1: Customer chat với order_123
3. Instance 2: Shipper chat với order_123
4. Gửi tin nhắn từ customer → xem shipper nhận được
5. Gửi tin nhắn từ shipper → xem customer nhận được

### Scenario 2: Location Tracking

**Test Steps:**
1. Mở tracking page với order_123
2. Bắt đầu location tracking
3. Di chuyển xung quanh
4. Xem bản đồ cập nhật vị trí realtime
5. Kiểm tra route được vẽ trên map

## 🔧 Cách Tạo Test Data

### 1. Tạo Mock Orders trong Database

Tạo file `backend/test_data.js`:

```javascript
const mongoose = require('mongoose');
const Order = require('./models/order');
const User = require('./models/login');

async function createTestData() {
  try {
    // Connect to MongoDB
    await mongoose.connect('mongodb://localhost:27017/FoodDeliveryApp');
    
    // Create test customer
    const customer = new User({
      email: 'customer@test.com',
      password: 'password123',
      name: 'Test Customer',
      role: 'customer'
    });
    await customer.save();
    
    // Create test shipper
    const shipper = new User({
      email: 'shipper@test.com', 
      password: 'password123',
      name: 'Test Shipper',
      role: 'shipper'
    });
    await shipper.save();
    
    // Create test order
    const order = new Order({
      customerId: customer._id,
      shipperId: shipper._id,
      restaurantId: new mongoose.Types.ObjectId(),
      items: [{
        foodId: new mongoose.Types.ObjectId(),
        quantity: 2,
        price: 15.99
      }],
      totalAmount: 31.98,
      status: 'confirmed',
      deliveryAddress: {
        street: '123 Test Street',
        city: 'Test City',
        coordinates: {
          type: 'Point',
          coordinates: [105.8542, 21.0285] // Hanoi coordinates
        }
      }
    });
    await order.save();
    
    console.log('Test data created successfully!');
    console.log('Customer ID:', customer._id);
    console.log('Shipper ID:', shipper._id);
    console.log('Order ID:', order._id);
    
  } catch (error) {
    console.error('Error creating test data:', error);
  }
}

createTestData();
```

Chạy script:
```bash
cd backend
node test_data.js
```

### 2. Test với Real IDs

Sau khi tạo test data, sử dụng real IDs trong app:

```dart
// Thay thế trong demo pages
const String customerId = "REAL_CUSTOMER_ID_FROM_DB";
const String shipperId = "REAL_SHIPPER_ID_FROM_DB";
const String orderId = "REAL_ORDER_ID_FROM_DB";
```

## 🧪 Test Cases Chi Tiết

### Test Case 1: WebSocket Connection

**Input:** Connect với userId và userType
**Expected:** WebSocket connects và emit 'authenticated'
**Test:**
```bash
# Check server logs
# Should see: "User connected: socket_id"
# Should see: "User authenticated: user_id (user_type)"
```

### Test Case 2: Join Order Room

**Input:** Join order room với orderId
**Expected:** User joins room và nhận chat history
**Test:**
```bash
# Check server logs  
# Should see: "User user_id joined order order_id"
# Should see: "Chat history received: X messages"
```

### Test Case 3: Send Message

**Input:** Gửi message từ customer
**Expected:** Shipper nhận được message realtime
**Test:**
```bash
# Check server logs
# Should see: "Message sent in order order_id by user_id"
# Should see: "New message received: message_data"
```

### Test Case 4: Location Update

**Input:** Shipper cập nhật location
**Expected:** Customer thấy vị trí mới trên map
**Test:**
```bash
# Check server logs
# Should see: "Location updated for order order_id by shipper user_id"
# Should see: "Location update received: location_data"
```

## 🐛 Troubleshooting

### 1. WebSocket Connection Failed

**Lỗi:** `WebSocket connection error`
**Giải pháp:**
- Kiểm tra backend server có chạy không
- Check URL trong WebSocketService
- Verify network connectivity

```dart
// Check trong realtime_websocket_service.dart
_websocketService.connect(
  'http://localhost:3000', // Đảm bảo URL đúng
  userId,
  userType,
);
```

### 2. Authentication Failed

**Lỗi:** `Authentication failed`
**Giải pháp:**
- Backend chưa implement JWT verification
- Hiện tại dùng dummy token, có thể bỏ qua

### 3. Location Permission Denied

**Lỗi:** `Location permission denied`
**Giải pháp:**
- Check AndroidManifest.xml permissions
- Test trên device thật
- Enable location services

### 4. No Messages Received

**Lỗi:** Messages không hiển thị
**Giải pháp:**
- Check WebSocket connection status
- Verify orderId trong cả 2 instances
- Check server logs

## 📱 Test trên Multiple Devices

### Cách 1: Multiple Devices
1. Install app trên 2 devices khác nhau
2. Connect cùng WiFi network
3. Thay đổi IP trong WebSocketService:
```dart
// Thay localhost bằng IP thật
_websocketService.connect(
  'http://192.168.1.100:3000', // IP của máy chạy backend
  userId,
  userType,
);
```

### Cách 2: Browser + Mobile
1. Tạo simple HTML page để test WebSocket
2. Test từ browser và mobile app cùng lúc

## 🔍 Debug Tools

### 1. Server Logs
```bash
cd backend
npm run dev
# Xem logs realtime
```

### 2. Browser DevTools
- Open DevTools → Network → WebSocket
- Xem WebSocket frames
- Monitor connection status

### 3. Flutter Debug Console
```bash
flutter run --verbose
# Xem detailed logs
```

## ✅ Checklist Test

- [ ] Backend server running
- [ ] WebSocket connection successful  
- [ ] Authentication working
- [ ] Join order room successful
- [ ] Chat messages sent/received
- [ ] Location updates working
- [ ] Map displaying correctly
- [ ] Real-time updates working
- [ ] No console errors
- [ ] Multiple users can connect

## 🎯 Expected Results

1. **Chat:** Messages appear instantly between users
2. **Location:** Map updates with shipper position
3. **Real-time:** No delays in updates
4. **Stable:** No disconnections during testing
5. **Scalable:** Multiple users can connect simultaneously

