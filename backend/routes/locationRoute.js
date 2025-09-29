const express = require('express');
const router = express.Router();
const Location = require('../models/location');
const Order = require('../models/order');

// Get current location of shipper for an order
router.get('/order/:orderId/current', async (req, res) => {
  try {
    const { orderId } = req.params;

    // Verify order exists
    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    if (!order.shipperId) {
      return res.status(404).json({ error: 'No shipper assigned to this order' });
    }

    // Get latest location
    const latestLocation = await Location.findOne({
      orderId,
      shipperId: order.shipperId,
      isActive: true
    })
    .sort({ timestamp: -1 })
    .lean();

    if (!latestLocation) {
      return res.status(404).json({ error: 'No location data available' });
    }

    res.json({
      shipperId: latestLocation.shipperId,
      coordinates: latestLocation.coordinates.coordinates,
      address: latestLocation.address,
      accuracy: latestLocation.accuracy,
      speed: latestLocation.speed,
      heading: latestLocation.heading,
      timestamp: latestLocation.timestamp
    });
  } catch (error) {
    console.error('Get current location error:', error);
    res.status(500).json({ error: 'Failed to get current location' });
  }
});

// Get location history for an order
router.get('/order/:orderId/history', async (req, res) => {
  try {
    const { orderId } = req.params;
    const { limit = 100 } = req.query;

    // Verify order exists
    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    // Get location history
    const locations = await Location.find({
      orderId,
      isActive: true
    })
    .sort({ timestamp: -1 })
    .limit(parseInt(limit))
    .select('coordinates address accuracy speed heading timestamp')
    .lean();

    const locationHistory = locations.map(loc => ({
      coordinates: loc.coordinates.coordinates,
      address: loc.address,
      accuracy: loc.accuracy,
      speed: loc.speed,
      heading: loc.heading,
      timestamp: loc.timestamp
    }));

    res.json({ locationHistory });
  } catch (error) {
    console.error('Get location history error:', error);
    res.status(500).json({ error: 'Failed to get location history' });
  }
});

// Update shipper location (REST API fallback)
router.post('/update', async (req, res) => {
  try {
    const { 
      orderId, 
      shipperId, 
      latitude, 
      longitude, 
      address, 
      accuracy, 
      speed, 
      heading 
    } = req.body;

    // Validate required fields
    if (!orderId || !shipperId || latitude === undefined || longitude === undefined) {
      return res.status(400).json({ 
        error: 'Order ID, shipper ID, latitude, and longitude are required' 
      });
    }

    // Verify shipper is assigned to order
    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    if (order.shipperId?.toString() !== shipperId) {
      return res.status(403).json({ error: 'Shipper not assigned to this order' });
    }

    // Save location update
    const locationUpdate = new Location({
      shipperId,
      orderId,
      coordinates: {
        type: "Point",
        coordinates: [longitude, latitude]
      },
      address: address || '',
      accuracy: accuracy || 10,
      speed: speed || 0,
      heading: heading || 0
    });

    await locationUpdate.save();

    // Broadcast to WebSocket clients
    const app = req.app;
    if (app.socketServer) {
      app.socketServer.sendToOrder(orderId, 'location_update', {
        shipperId,
        coordinates: [longitude, latitude],
        address: address || '',
        timestamp: locationUpdate.timestamp,
        speed: speed || 0,
        heading: heading || 0
      });
    }

    res.json({ 
      success: true, 
      location: {
        id: locationUpdate._id,
        coordinates: [longitude, latitude],
        address: address || '',
        accuracy: accuracy || 10,
        speed: speed || 0,
        heading: heading || 0,
        timestamp: locationUpdate.timestamp
      }
    });
  } catch (error) {
    console.error('Update location error:', error);
    res.status(500).json({ error: 'Failed to update location' });
  }
});

// Get nearby orders for shipper
router.get('/nearby-orders', async (req, res) => {
  try {
    const { latitude, longitude, maxDistance = 5000 } = req.query; // maxDistance in meters

    if (!latitude || !longitude) {
      return res.status(400).json({ 
        error: 'Latitude and longitude are required' 
      });
    }

    // Find orders near the shipper's location
    const nearbyOrders = await Order.find({
      status: { $in: ['confirmed', 'preparing', 'ready'] },
      deliveryAddress: {
        $near: {
          $geometry: {
            type: "Point",
            coordinates: [parseFloat(longitude), parseFloat(latitude)]
          },
          $maxDistance: parseInt(maxDistance)
        }
      }
    })
    .populate('customerId', 'name phone')
    .populate('restaurantId', 'name address')
    .select('_id totalAmount status estimatedDeliveryTime deliveryAddress createdAt')
    .lean();

    res.json({ nearbyOrders });
  } catch (error) {
    console.error('Get nearby orders error:', error);
    res.status(500).json({ error: 'Failed to get nearby orders' });
  }
});

// Stop location tracking for an order
router.post('/stop-tracking/:orderId', async (req, res) => {
  try {
    const { orderId } = req.params;
    const { shipperId } = req.body;

    // Verify shipper is assigned to order
    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    if (order.shipperId?.toString() !== shipperId) {
      return res.status(403).json({ error: 'Shipper not assigned to this order' });
    }

    // Mark all locations as inactive
    await Location.updateMany(
      { orderId, shipperId, isActive: true },
      { isActive: false }
    );

    res.json({ success: true });
  } catch (error) {
    console.error('Stop tracking error:', error);
    res.status(500).json({ error: 'Failed to stop location tracking' });
  }
});

module.exports = router;

