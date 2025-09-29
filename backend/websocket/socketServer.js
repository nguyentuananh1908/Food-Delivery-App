const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const Chat = require('../models/chat');
const Location = require('../models/location');
const Order = require('../models/order');

class SocketServer {
  constructor(server) {
    this.io = new Server(server, {
      cors: {
        origin: "*",
        methods: ["GET", "POST"]
      }
    });
    
    this.connectedUsers = new Map(); // userId -> socketId
    this.orderRooms = new Map(); // orderId -> Set of socketIds
    
    this.initializeSocketHandlers();
  }

  initializeSocketHandlers() {
    this.io.on('connection', (socket) => {
      console.log(`User connected: ${socket.id}`);

      // Authenticate user
      socket.on('authenticate', async (data) => {
        try {
          const { token, userId, userType } = data;
          
          // Verify token if needed (optional for now)
          // const decoded = jwt.verify(token, process.env.JWT_SECRET);
          
          // Store user connection
          this.connectedUsers.set(userId, socket.id);
          socket.userId = userId;
          socket.userType = userType;
          
          console.log(`User authenticated: ${userId} (${userType})`);
          
          socket.emit('authenticated', { success: true });
        } catch (error) {
          console.error('Authentication error:', error);
          socket.emit('authentication_failed', { error: 'Invalid token' });
        }
      });

      // Join order room for chat and location updates
      socket.on('join_order', async (data) => {
        try {
          const { orderId } = data;
          
          if (!socket.userId) {
            socket.emit('error', { message: 'Not authenticated' });
            return;
          }

          // Verify user has access to this order
          const order = await Order.findById(orderId);
          if (!order || 
              (order.customerId.toString() !== socket.userId && 
               order.shipperId?.toString() !== socket.userId)) {
            socket.emit('error', { message: 'Access denied to this order' });
            return;
          }

          socket.join(`order_${orderId}`);
          
          // Track order room
          if (!this.orderRooms.has(orderId)) {
            this.orderRooms.set(orderId, new Set());
          }
          this.orderRooms.get(orderId).add(socket.id);
          
          console.log(`User ${socket.userId} joined order ${orderId}`);
          socket.emit('joined_order', { orderId });
          
          // Send recent chat messages
          const recentMessages = await Chat.find({ orderId })
            .sort({ createdAt: -1 })
            .limit(50)
            .populate('senderId', 'name email');
          
          socket.emit('chat_history', { messages: recentMessages.reverse() });
          
        } catch (error) {
          console.error('Join order error:', error);
          socket.emit('error', { message: 'Failed to join order' });
        }
      });

      // Handle chat messages
      socket.on('send_message', async (data) => {
        try {
          const { orderId, message, messageType = 'text' } = data;
          
          if (!socket.userId) {
            socket.emit('error', { message: 'Not authenticated' });
            return;
          }

          // Create chat message
          const chatMessage = new Chat({
            orderId,
            senderId: socket.userId,
            senderType: socket.userType,
            message,
            messageType
          });

          await chatMessage.save();
          await chatMessage.populate('senderId', 'name email');

          // Broadcast to all users in the order room
          this.io.to(`order_${orderId}`).emit('new_message', {
            message: chatMessage
          });

          console.log(`Message sent in order ${orderId} by ${socket.userId}`);
          
        } catch (error) {
          console.error('Send message error:', error);
          socket.emit('error', { message: 'Failed to send message' });
        }
      });

      // Handle location updates from shipper
      socket.on('update_location', async (data) => {
        try {
          const { orderId, latitude, longitude, address, accuracy, speed, heading } = data;
          
          if (!socket.userId || socket.userType !== 'shipper') {
            socket.emit('error', { message: 'Only shippers can update location' });
            return;
          }

          // Verify shipper is assigned to this order
          const order = await Order.findById(orderId);
          if (!order || order.shipperId?.toString() !== socket.userId) {
            socket.emit('error', { message: 'Not assigned to this order' });
            return;
          }

          // Save location update
          const locationUpdate = new Location({
            shipperId: socket.userId,
            orderId,
            coordinates: {
              type: "Point",
              coordinates: [longitude, latitude]
            },
            address,
            accuracy,
            speed,
            heading
          });

          await locationUpdate.save();

          // Broadcast location update to all users in the order room
          this.io.to(`order_${orderId}`).emit('location_update', {
            shipperId: socket.userId,
            coordinates: [longitude, latitude],
            address,
            timestamp: locationUpdate.timestamp,
            speed,
            heading
          });

          console.log(`Location updated for order ${orderId} by shipper ${socket.userId}`);
          
        } catch (error) {
          console.error('Location update error:', error);
          socket.emit('error', { message: 'Failed to update location' });
        }
      });

      // Mark messages as read
      socket.on('mark_messages_read', async (data) => {
        try {
          const { orderId, messageIds } = data;
          
          if (!socket.userId) {
            socket.emit('error', { message: 'Not authenticated' });
            return;
          }

          await Chat.updateMany(
            { _id: { $in: messageIds } },
            { 
              $push: { 
                readBy: { 
                  userId: socket.userId, 
                  userType: socket.userType,
                  readAt: new Date()
                }
              }
            }
          );

          socket.emit('messages_marked_read', { messageIds });
          
        } catch (error) {
          console.error('Mark messages read error:', error);
          socket.emit('error', { message: 'Failed to mark messages as read' });
        }
      });

      // Handle disconnection
      socket.on('disconnect', () => {
        console.log(`User disconnected: ${socket.id}`);
        
        if (socket.userId) {
          this.connectedUsers.delete(socket.userId);
          
          // Remove from order rooms
          this.orderRooms.forEach((socketIds, orderId) => {
            socketIds.delete(socket.id);
            if (socketIds.size === 0) {
              this.orderRooms.delete(orderId);
            }
          });
        }
      });
    });
  }

  // Method to send notification to specific user
  sendToUser(userId, event, data) {
    const socketId = this.connectedUsers.get(userId);
    if (socketId) {
      this.io.to(socketId).emit(event, data);
      return true;
    }
    return false;
  }

  // Method to send notification to all users in an order
  sendToOrder(orderId, event, data) {
    this.io.to(`order_${orderId}`).emit(event, data);
  }

  // Method to broadcast to all connected users
  broadcast(event, data) {
    this.io.emit(event, data);
  }
}

module.exports = SocketServer;
