@echo off
echo ========================================
echo    Complete Food Delivery System Setup
echo ========================================
echo.

echo Step 1: Installing Backend Dependencies...
cd backend
npm install
echo ✅ Backend dependencies installed
echo.

echo Step 2: Creating Users and Orders...
node create_users_and_orders.js
echo.

echo Step 3: Starting Backend Server...
start "Backend Server" cmd /k "npm run dev"
echo ✅ Backend server started on http://localhost:3000
echo.

echo Step 4: Installing Frontend Dependencies...
cd ..\frontend
flutter pub get
echo ✅ Frontend dependencies installed
echo.

echo ========================================
echo    🎉 Setup Complete!
echo ========================================
echo.
echo 📱 Available Routes:
echo - /main-demo (Main demo with all features)
echo - /demo (Original demo)
echo - /realtime-demo (Realtime demo)
echo - /websocket-test (WebSocket test)
echo.
echo 🧪 Test Features:
echo ✅ Real-time chat between customer and shipper
echo ✅ Location tracking with Google Maps
echo ✅ Save location with map selection
echo ✅ Chat list with unread counts
echo ✅ Order management
echo.
echo 📋 Next Steps:
echo 1. Copy the generated IDs from above
echo 2. Replace test IDs in MainDemoPage with real ones
echo 3. Start frontend: flutter run
echo 4. Navigate to /main-demo route
echo 5. Test all features!
echo.
echo 🔧 Test Data:
echo - Customer: customer@test.com / password123
echo - Shipper: shipper@test.com / password123
echo - Restaurant: restaurant@test.com / password123
echo.
echo ========================================
echo    📚 Documentation
echo ========================================
echo.
echo - WEBSOCKET_TESTING_GUIDE.md
echo - REALTIME_FEATURES.md
echo - BUGFIXES.md
echo.
pause


