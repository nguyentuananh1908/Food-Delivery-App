const mongoose = require("mongoose");

const chatSchema = new mongoose.Schema({
  orderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Order",
    required: true,
    index: true
  },
  senderId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    index: true
  },
  senderType: {
    type: String,
    enum: ["customer", "shipper", "admin"],
    required: true
  },
  message: {
    type: String,
    required: true,
    maxlength: 1000
  },
  messageType: {
    type: String,
    enum: ["text", "image", "location", "system"],
    default: "text"
  },
  isRead: {
    type: Boolean,
    default: false
  },
  readBy: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true
    },
    userType: {
      type: String,
      enum: ["customer", "shipper", "admin"],
      required: true
    },
    readAt: {
      type: Date,
      default: Date.now
    }
  }]
}, {
  timestamps: true
});

// Indexes for better performance
chatSchema.index({ orderId: 1, createdAt: -1 });
chatSchema.index({ senderId: 1, createdAt: -1 });

module.exports = mongoose.model("Chat", chatSchema);
