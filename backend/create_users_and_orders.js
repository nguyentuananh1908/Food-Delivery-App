const mongoose = require('mongoose');
const User = require('./models/user');
const Order = require('./models/order');
const Food = require('./models/food');

// Generate order number
function generateOrderNumber() {
  const date = new Date();
  const year = date.getFullYear().toString().slice(-2);
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const day = date.getDate().toString().padStart(2, '0');
  const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
  return `FD${year}${month}${day}${random}`;
}

async function createUsersAndOrders() {
  try {
    console.log('🚀 Creating users and orders...');
    
    // Connect to MongoDB
    const MONGO_URL = process.env.MONGO_URL || 'mongodb://localhost:27017/FoodDeliveryApp';
    await mongoose.connect(MONGO_URL);
    console.log('✅ Connected to MongoDB');

    // Clear existing test data
    await User.deleteMany({ 
      email: { 
        $in: [
          'customer@test.com', 
          'shipper@test.com',
          'restaurant@test.com'
        ] 
      } 
    });
    console.log('🧹 Cleared existing test users');

    // Create test customer
    const customer = new User({
      name: 'John Doe',
      email: 'customer@test.com',
      password: 'password123',
      phone: '0123456789',
      role: 'customer',
      customerInfo: {
        addresses: [{
          label: 'home',
          street: '123 Main Street',
          city: 'Hanoi',
          postalCode: '100000',
          apartment: 'Apt 101',
          coordinates: {
            type: 'Point',
            coordinates: [105.8542, 21.0285]
          },
          isDefault: true
        }, {
          label: 'work',
          street: '456 Business District',
          city: 'Hanoi',
          postalCode: '100001',
          apartment: 'Floor 5',
          coordinates: {
            type: 'Point',
            coordinates: [105.8642, 21.0385]
          },
          isDefault: false
        }]
      }
    });
    await customer.save();
    console.log('👤 Created customer:', customer._id.toString());

    // Create test shipper
    const shipper = new User({
      name: 'Mike Wilson',
      email: 'shipper@test.com',
      password: 'password123',
      phone: '0987654321',
      role: 'shipper',
      isOnline: true,
      shipperInfo: {
        licenseNumber: 'SH123456',
        vehicleType: 'motorbike',
        vehicleNumber: '29A1-12345',
        isAvailable: true,
        rating: 4.8,
        totalDeliveries: 150,
        currentLocation: {
          type: 'Point',
          coordinates: [105.8442, 21.0185]
        }
      }
    });
    await shipper.save();
    console.log('🚚 Created shipper:', shipper._id.toString());

    // Create test restaurant
    const restaurant = new User({
      name: 'Pizza Palace',
      email: 'restaurant@test.com',
      password: 'password123',
      phone: '0111222333',
      role: 'restaurant',
      restaurantInfo: {
        businessName: 'Pizza Palace',
        businessLicense: 'BL123456',
        address: '789 Food Street, Hanoi',
        coordinates: {
          type: 'Point',
          coordinates: [105.8342, 21.0085]
        },
        cuisine: ['Italian', 'Pizza', 'Fast Food'],
        deliveryRadius: 5,
        isOpen: true
      }
    });
    await restaurant.save();
    console.log('🍕 Created restaurant:', restaurant._id.toString());

    // Create some sample foods
    const foods = [
      {
        name: 'Margherita Pizza',
        description: 'Classic pizza with tomato, mozzarella, and basil',
        price: 15.99,
        category: 'Pizza',
        restaurantId: restaurant._id
      },
      {
        name: 'Pepperoni Pizza',
        description: 'Pizza with pepperoni and mozzarella cheese',
        price: 18.99,
        category: 'Pizza',
        restaurantId: restaurant._id
      },
      {
        name: 'Caesar Salad',
        description: 'Fresh salad with caesar dressing',
        price: 8.99,
        category: 'Salad',
        restaurantId: restaurant._id
      }
    ];

    const createdFoods = [];
    for (const foodData of foods) {
      const food = new Food(foodData);
      await food.save();
      createdFoods.push(food);
    }
    console.log('🍽️ Created foods:', createdFoods.length);

    // Create test orders
    const orders = [];
    
    // Order 1 - Active order with shipper
    const order1 = new Order({
      orderNumber: generateOrderNumber(),
      customerId: customer._id,
      shipperId: shipper._id,
      restaurantId: restaurant._id,
      items: [{
        foodId: createdFoods[0]._id,
        quantity: 2,
        price: createdFoods[0].price
      }, {
        foodId: createdFoods[2]._id,
        quantity: 1,
        price: createdFoods[2].price
      }],
      totalAmount: (createdFoods[0].price * 2) + createdFoods[2].price,
      deliveryFee: 3.00,
      status: 'picked_up',
      deliveryAddress: {
        street: customer.customerInfo.addresses[0].street,
        city: customer.customerInfo.addresses[0].city,
        coordinates: {
          type: 'Point',
          coordinates: customer.customerInfo.addresses[0].coordinates.coordinates
        }
      },
      estimatedDeliveryTime: new Date(Date.now() + 30 * 60 * 1000), // 30 minutes from now
      paymentMethod: 'cash',
      paymentStatus: 'pending',
      notes: 'Please ring the doorbell'
    });
    await order1.save();
    orders.push(order1);

    // Order 2 - Ready for pickup
    const order2 = new Order({
      orderNumber: generateOrderNumber(),
      customerId: customer._id,
      shipperId: shipper._id,
      restaurantId: restaurant._id,
      items: [{
        foodId: createdFoods[1]._id,
        quantity: 1,
        price: createdFoods[1].price
      }],
      totalAmount: createdFoods[1].price,
      deliveryFee: 2.50,
      status: 'ready',
      deliveryAddress: {
        street: customer.customerInfo.addresses[1].street,
        city: customer.customerInfo.addresses[1].city,
        coordinates: {
          type: 'Point',
          coordinates: customer.customerInfo.addresses[1].coordinates.coordinates
        }
      },
      estimatedDeliveryTime: new Date(Date.now() + 45 * 60 * 1000),
      paymentMethod: 'card',
      paymentStatus: 'paid'
    });
    await order2.save();
    orders.push(order2);

    console.log('📦 Created orders:', orders.length);

    // Print summary
    console.log('\n📋 Test Data Summary:');
    console.log('='.repeat(60));
    console.log('👤 Customer:');
    console.log('   ID:', customer._id.toString());
    console.log('   Email:', customer.email);
    console.log('   Name:', customer.name);
    console.log('   Phone:', customer.phone);
    console.log('');
    console.log('🚚 Shipper:');
    console.log('   ID:', shipper._id.toString());
    console.log('   Email:', shipper.email);
    console.log('   Name:', shipper.name);
    console.log('   Phone:', shipper.phone);
    console.log('   Vehicle:', shipper.shipperInfo.vehicleType);
    console.log('   Rating:', shipper.shipperInfo.rating);
    console.log('');
    console.log('🍕 Restaurant:');
    console.log('   ID:', restaurant._id.toString());
    console.log('   Name:', restaurant.restaurantInfo.businessName);
    console.log('   Email:', restaurant.email);
    console.log('');
    console.log('📦 Orders:');
    orders.forEach((order, index) => {
      console.log(`   Order ${index + 1}:`);
      console.log('     ID:', order._id.toString());
      console.log('     Number:', order.orderNumber);
      console.log('     Status:', order.status);
      console.log('     Total:', `$${order.totalAmount}`);
    });
    
    console.log('\n🔧 Usage in Flutter App:');
    console.log('='.repeat(60));
    console.log('Customer ID: "${customer._id.toString()}"');
    console.log('Shipper ID: "${shipper._id.toString()}"');
    console.log('Restaurant ID: "${restaurant._id.toString()}"');
    console.log('Active Order ID: "${orders[0]._id.toString()}"');
    console.log('Ready Order ID: "${orders[1]._id.toString()}"');
    
    console.log('\n📱 Test Accounts:');
    console.log('='.repeat(60));
    console.log('Customer: customer@test.com / password123');
    console.log('Shipper: shipper@test.com / password123');
    console.log('Restaurant: restaurant@test.com / password123');
    
    console.log('\n✅ Test data created successfully!');
    console.log('You can now test the complete WebSocket chat and location tracking system.');

  } catch (error) {
    console.error('❌ Error creating test data:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

// Run the script
createUsersAndOrders();
