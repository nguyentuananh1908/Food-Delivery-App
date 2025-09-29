const mongoose = require("mongoose");

const orderSchema = new mongoose.Schema({
  orderNumber: {
    type: String,
    unique: true,
    required: true
  },
  customerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
    index: true
  },
  shipperId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    index: true
  },
  restaurantId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
    index: true
  },
  items: [{
    foodId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Food",
      required: true
    },
    quantity: {
      type: Number,
      required: true,
      min: 1
    },
    price: {
      type: Number,
      required: true
    }
  }],
  totalAmount: {
    type: Number,
    required: true
  },
  deliveryFee: {
    type: Number,
    default: 0
  },
  status: {
    type: String,
    enum: ["pending", "confirmed", "preparing", "ready", "picked_up", "on_the_way", "delivered", "cancelled"],
    default: "pending",
    index: true
  },
  deliveryAddress: {
    street: String,
    city: String,
    coordinates: {
      type: {
        type: String,
        enum: ["Point"],
        default: "Point"
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
        required: true
      }
    }
  },
  estimatedDeliveryTime: {
    type: Date
  },
  actualDeliveryTime: {
    type: Date
  },
  paymentMethod: {
    type: String,
    enum: ["cash", "card", "wallet"],
    default: "cash"
  },
  paymentStatus: {
    type: String,
    enum: ["pending", "paid", "failed"],
    default: "pending"
  },
  notes: {
    type: String,
    maxlength: 500
  }
}, {
  timestamps: true
});

// Indexes
orderSchema.index({ customerId: 1, createdAt: -1 });
orderSchema.index({ shipperId: 1, status: 1 });
orderSchema.index({ status: 1, createdAt: -1 });
orderSchema.index({ "deliveryAddress.coordinates": "2dsphere" });

module.exports = mongoose.model("Order", orderSchema);
