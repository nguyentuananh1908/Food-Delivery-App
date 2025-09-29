const mongoose = require('mongoose');
const Order = require('./models/order');
const User = require('./models/login');

// Test data configuration
const TEST_DATA = {
  customer: {
    email: 'customer@test.com',
    password: 'password123',
    name: 'Test Customer',
    phone: '0123456789',
    address: {
      houseNumber: '123',
      ward: 'Trung Hoa',
      city: 'Hanoi'
    }
  },
  shipper: {
    email: 'shipper@test.com',
    password: 'password123', 
    name: 'Test Shipper',
    phone: '0987654321',
    address: {
      houseNumber: '456',
      ward: 'Thanh Xuan',
      city: 'Hanoi'
    }
  },
  order: {
    orderNumber: 'ORDER123',
    items: [
      {
        name: 'Pizza',
        quantity: 2,
        price: 150000
      },
      {
        name: 'Burger',
        quantity: 1,
        price: 80000
      }
    ],
    status: 'pending',
    total: 380000,
    totalAmount: 380000,
    address: {
      houseNumber: '123',
      ward: 'Trung Hoa',
      city: 'Hanoi'
    },
    deliveryAddress: {
      coordinates: {
        type: 'Point',
        coordinates: [105.8542, 21.0285]
      }
    }
  }
};

async function createTestData() {
  try {
    console.log('🚀 Creating test data...');
    
    // Connect to MongoDB
    const MONGO_URL = process.env.MONGO_URL || 'mongodb://localhost:27017/FoodDeliveryApp';
    await mongoose.connect(MONGO_URL);
    console.log('✅ Connected to MongoDB');

    // Clear existing test data
    await User.deleteMany({ email: { $in: ['customer@test.com', 'shipper@test.com', 'restaurant@test.com'] } });
    console.log('🧹 Cleared existing test data');

    // Create test customer
    const customer = new User(TEST_DATA.customer);
    await customer.save();
    console.log('👤 Created test customer:', customer._id.toString());

    // Create test shipper  
    const shipper = new User(TEST_DATA.shipper);
    await shipper.save();
    console.log('🚚 Created test shipper:', shipper._id.toString());

    // Create test restaurant
    const restaurant = new User({
      email: 'restaurant@test.com',
      password: 'password123',
      name: 'Test Restaurant',
      role: 'restaurant',
      phone: '0111222333',
      address: {
        houseNumber: '789',
        ward: 'Cau Giay',
        city: 'Hanoi'
      }
    });
    await restaurant.save();
    console.log('🍕 Created test restaurant:', restaurant._id.toString());

    // Create test order
    const orderData = {
      ...TEST_DATA.order,
      customerId: customer._id,
      shipperId: shipper._id,
      restaurantId: restaurant._id,
      items: TEST_DATA.order.items.map(item => ({
        ...item,
        foodId: new mongoose.Types.ObjectId() // Generate new food ID
      }))
    };
    
    const order = new Order(orderData);
    await order.save();
    console.log('📦 Created test order:', order._id.toString());

    // Print test data for easy copy-paste
    console.log('\n📋 Test Data Summary:');
    console.log('='.repeat(50));
    console.log('Customer ID:', customer._id.toString());
    console.log('Shipper ID:', shipper._id.toString());
    console.log('Restaurant ID:', restaurant._id.toString());
    console.log('Order ID:', order._id.toString());
    console.log('='.repeat(50));
    
    console.log('\n🔧 Usage in Flutter App:');
    console.log('Customer ID: "${customer._id.toString()}"');
    console.log('Shipper ID: "${shipper._id.toString()}"');
    console.log('Order ID: "${order._id.toString()}"');
    
    console.log('\n📱 Test Accounts:');
    console.log('Customer: customer@test.com / password123');
    console.log('Shipper: shipper@test.com / password123');
    console.log('Restaurant: restaurant@test.com / password123');
    
    console.log('\n✅ Test data created successfully!');
    console.log('You can now test WebSocket features with these IDs.');

  } catch (error) {
    console.error('❌ Error creating test data:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

// Run the script
createTestData();

