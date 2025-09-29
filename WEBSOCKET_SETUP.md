# WebSocket Chat Realtime & Location Tracking Setup

## Tổng quan

Hệ thống này cung cấp:
- Chat realtime giữa khách hàng và shipper
- Cập nhật vị trí shipper realtime
- Bản đồ hiển thị vị trí và route
- WebSocket server với Socket.IO

## Backend Setup

### 1. Cài đặt Dependencies

```bash
cd backend
npm install
```

### 2. Cấu hình Environment

Tạo file `.env` trong thư mục `backend`:

```env
MONGO_URL=mongodb://localhost:27017/FoodDeliveryApp
PORT=3000
JWT_SECRET=your_jwt_secret_here
```

### 3. Chạy Server

```bash
npm run dev
```

Server sẽ chạy trên `http://localhost:3000`

## Frontend Setup

### 1. Cài đặt Dependencies

```bash
cd frontend
flutter pub get
```

### 2. Cấu hình Google Maps (Android)

Thêm API key vào `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
</application>
```

### 3. Cấu hình Permissions

Thêm permissions vào `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 4. Chạy App

```bash
flutter run
```

## API Endpoints

### Chat Endpoints

- `GET /api/chat/order/:orderId` - Lấy lịch sử chat
- `GET /api/chat/unread/:userId` - Lấy số tin nhắn chưa đọc
- `POST /api/chat/mark-read` - Đánh dấu tin nhắn đã đọc
- `POST /api/chat/system-message` - Gửi tin nhắn hệ thống

### Location Endpoints

- `GET /api/location/order/:orderId/current` - Lấy vị trí hiện tại
- `GET /api/location/order/:orderId/history` - Lấy lịch sử vị trí
- `POST /api/location/update` - Cập nhật vị trí
- `GET /api/location/nearby-orders` - Lấy đơn hàng gần đây
- `POST /api/location/stop-tracking/:orderId` - Dừng tracking

## WebSocket Events

### Client Events

- `authenticate` - Xác thực user
- `join_order` - Tham gia room đơn hàng
- `send_message` - Gửi tin nhắn
- `update_location` - Cập nhật vị trí
- `mark_messages_read` - Đánh dấu tin nhắn đã đọc

### Server Events

- `authenticated` - Xác thực thành công
- `new_message` - Tin nhắn mới
- `location_update` - Cập nhật vị trí
- `chat_history` - Lịch sử chat
- `error` - Lỗi

## Models

### Chat Message

```javascript
{
  _id: ObjectId,
  orderId: ObjectId,
  senderId: ObjectId,
  senderType: String, // 'customer', 'shipper', 'admin'
  message: String,
  messageType: String, // 'text', 'image', 'location', 'system'
  isRead: Boolean,
  readBy: [{
    userId: ObjectId,
    userType: String,
    readAt: Date
  }],
  createdAt: Date,
  updatedAt: Date
}
```

### Location

```javascript
{
  _id: ObjectId,
  shipperId: ObjectId,
  orderId: ObjectId,
  coordinates: {
    type: "Point",
    coordinates: [longitude, latitude]
  },
  address: String,
  accuracy: Number,
  speed: Number,
  heading: Number,
  timestamp: Date,
  isActive: Boolean
}
```

## Demo Pages

### 1. Chat Demo
- Truy cập `/demo` route
- Chọn "Chat" để test tính năng chat
- Có thể test với cả customer và shipper view

### 2. Tracking Demo
- Chọn "Tracking" để test tính năng theo dõi vị trí
- Hiển thị bản đồ với vị trí shipper realtime

### 3. Shipper Dashboard
- Chọn "Shipper" để test dashboard shipper
- Quản lý đơn hàng và chat với khách hàng

## Tính năng chính

### Chat Realtime
- ✅ Tin nhắn realtime
- ✅ Lịch sử chat
- ✅ Đánh dấu đã đọc
- ✅ Tin nhắn hệ thống
- ✅ Phân loại user (customer, shipper, admin)

### Location Tracking
- ✅ Cập nhật vị trí realtime
- ✅ Google Maps integration
- ✅ Hiển thị route
- ✅ Lịch sử vị trí
- ✅ GPS accuracy

### WebSocket
- ✅ Socket.IO server
- ✅ Room-based messaging
- ✅ User authentication
- ✅ Error handling
- ✅ Connection management

## Troubleshooting

### 1. WebSocket Connection Failed
- Kiểm tra server có đang chạy không
- Kiểm tra firewall settings
- Kiểm tra URL trong WebSocketService

### 2. Location Permission Denied
- Kiểm tra permissions trong AndroidManifest.xml
- Test trên device thật (không phải emulator)
- Kiểm tra location services có bật không

### 3. Google Maps Not Loading
- Kiểm tra API key
- Kiểm tra billing account
- Kiểm tra API restrictions

### 4. MongoDB Connection Error
- Kiểm tra MongoDB có đang chạy không
- Kiểm tra connection string trong .env
- Kiểm tra network connectivity

## Next Steps

1. **Authentication**: Thêm JWT authentication
2. **Push Notifications**: Thêm push notifications cho mobile
3. **File Upload**: Thêm tính năng gửi ảnh trong chat
4. **Offline Support**: Thêm support cho offline mode
5. **Analytics**: Thêm tracking analytics
6. **Testing**: Thêm unit tests và integration tests

## Support

Nếu gặp vấn đề, hãy kiểm tra:
1. Console logs trong browser/device
2. Server logs trong terminal
3. Network requests trong developer tools
4. Database connections và data

