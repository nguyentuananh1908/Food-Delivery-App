@echo off
echo ========================================
echo    WebSocket Testing Setup
echo ========================================
echo.

echo Step 1: Starting Backend Server...
cd backend
start "Backend Server" cmd /k "npm run dev"
echo Backend server started in new window
echo.

echo Step 2: Creating Test Data...
node create_test_data.js
echo.

echo Step 3: Starting Frontend App...
cd ..\frontend
echo Starting Flutter app...
echo.
echo ========================================
echo    Test Instructions
echo ========================================
echo.
echo 1. Backend server is running on http://localhost:3000
echo 2. Copy the Customer/Shipper/Order IDs from above
echo 3. Replace test IDs in RealtimeTestPage with real ones
echo 4. Open app and navigate to /websocket-test route
echo 5. Test chat and location tracking features
echo.
echo Test Routes:
echo - /demo (Original demo)
echo - /realtime-demo (New realtime demo)  
echo - /websocket-test (WebSocket test with real data)
echo.
echo ========================================
echo    Testing Tips
echo ========================================
echo.
echo For best testing experience:
echo - Use 2 devices or browser tabs
echo - Test customer chat in one, shipper chat in other
echo - Verify real-time message delivery
echo - Test location tracking with GPS enabled
echo.
pause


