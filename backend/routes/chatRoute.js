const express = require('express');
const router = express.Router();
const Chat = require('../models/chat');
const Order = require('../models/order');

// Get chat history for an order
router.get('/order/:orderId', async (req, res) => {
  try {
    const { orderId } = req.params;
    const { page = 1, limit = 50 } = req.query;

    // Verify order exists and user has access
    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    // TODO: Add authentication middleware to verify user access
    // const userId = req.user.id;
    // if (order.customerId.toString() !== userId && order.shipperId?.toString() !== userId) {
    //   return res.status(403).json({ error: 'Access denied' });
    // }

    const skip = (page - 1) * limit;
    const messages = await Chat.find({ orderId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit))
      .populate('senderId', 'name email')
      .lean();

    const totalMessages = await Chat.countDocuments({ orderId });

    res.json({
      messages: messages.reverse(),
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: totalMessages,
        pages: Math.ceil(totalMessages / limit)
      }
    });
  } catch (error) {
    console.error('Get chat history error:', error);
    res.status(500).json({ error: 'Failed to get chat history' });
  }
});

// Get unread message count for user
router.get('/unread/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { userType } = req.query;

    if (!userType) {
      return res.status(400).json({ error: 'User type is required' });
    }

    // Get orders where user is involved
    const orderQuery = userType === 'customer' 
      ? { customerId: userId }
      : { shipperId: userId };

    const orders = await Order.find(orderQuery).select('_id');
    const orderIds = orders.map(order => order._id);

    // Count unread messages
    const unreadCount = await Chat.countDocuments({
      orderId: { $in: orderIds },
      senderId: { $ne: userId },
      'readBy.userId': { $ne: userId }
    });

    res.json({ unreadCount });
  } catch (error) {
    console.error('Get unread count error:', error);
    res.status(500).json({ error: 'Failed to get unread count' });
  }
});

// Mark messages as read
router.post('/mark-read', async (req, res) => {
  try {
    const { messageIds, userId, userType } = req.body;

    if (!messageIds || !Array.isArray(messageIds) || messageIds.length === 0) {
      return res.status(400).json({ error: 'Message IDs are required' });
    }

    const updateResult = await Chat.updateMany(
      { 
        _id: { $in: messageIds },
        'readBy.userId': { $ne: userId }
      },
      { 
        $push: { 
          readBy: { 
            userId, 
            userType,
            readAt: new Date()
          }
        }
      }
    );

    res.json({ 
      success: true, 
      modifiedCount: updateResult.modifiedCount 
    });
  } catch (error) {
    console.error('Mark messages read error:', error);
    res.status(500).json({ error: 'Failed to mark messages as read' });
  }
});

// Send system message
router.post('/system-message', async (req, res) => {
  try {
    const { orderId, message } = req.body;

    if (!orderId || !message) {
      return res.status(400).json({ error: 'Order ID and message are required' });
    }

    // TODO: Add admin authentication middleware
    // const isAdmin = req.user.role === 'admin';
    // if (!isAdmin) {
    //   return res.status(403).json({ error: 'Admin access required' });
    // }

    const systemMessage = new Chat({
      orderId,
      senderId: null, // System message
      senderType: 'admin',
      message,
      messageType: 'system'
    });

    await systemMessage.save();

    // Broadcast to WebSocket clients
    const app = req.app;
    if (app.socketServer) {
      app.socketServer.sendToOrder(orderId, 'new_message', {
        message: systemMessage
      });
    }

    res.json({ 
      success: true, 
      message: systemMessage 
    });
  } catch (error) {
    console.error('Send system message error:', error);
    res.status(500).json({ error: 'Failed to send system message' });
  }
});

module.exports = router;

