#!/bin/bash

echo "🚀 Setting up Food Delivery App with WebSocket Chat & Location Tracking"
echo "=================================================================="

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo "✅ Node.js and Flutter are installed"

# Setup Backend
echo ""
echo "📦 Setting up Backend..."
cd backend

if [ ! -d "node_modules" ]; then
    echo "Installing backend dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install backend dependencies"
        exit 1
    fi
    echo "✅ Backend dependencies installed"
else
    echo "✅ Backend dependencies already installed"
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    cat > .env << EOF
MONGO_URL=mongodb://localhost:27017/FoodDeliveryApp
PORT=3000
JWT_SECRET=your_jwt_secret_here_$(date +%s)
EOF
    echo "✅ .env file created"
else
    echo "✅ .env file already exists"
fi

cd ..

# Setup Frontend
echo ""
echo "📱 Setting up Frontend..."
cd frontend

echo "Getting Flutter dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Failed to get Flutter dependencies"
    exit 1
fi
echo "✅ Flutter dependencies installed"

cd ..

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "Next steps:"
echo "1. Start MongoDB server"
echo "2. Run backend: cd backend && npm run dev"
echo "3. Run frontend: cd frontend && flutter run"
echo "4. Access demo pages:"
echo "   - Original demo: /demo route"
echo "   - New realtime demo: /realtime-demo route"
echo ""
echo "📚 Documentation:"
echo "   - WEBSOCKET_SETUP.md - General setup guide"
echo "   - REALTIME_FEATURES.md - New separated realtime features"
