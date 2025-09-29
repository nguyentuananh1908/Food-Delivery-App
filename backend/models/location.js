const mongoose = require("mongoose");

const locationSchema = new mongoose.Schema({
  shipperId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
    index: true
  },
  orderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Order",
    required: true,
    index: true
  },
  coordinates: {
    type: {
      type: String,
      enum: ["Point"],
      default: "Point"
    },
    coordinates: {
      type: [Number], // [longitude, latitude]
      required: true,
      index: "2dsphere"
    }
  },
  address: {
    type: String,
    required: true
  },
  accuracy: {
    type: Number,
    default: 10
  },
  speed: {
    type: Number,
    default: 0
  },
  heading: {
    type: Number,
    default: 0
  },
  timestamp: {
    type: Date,
    default: Date.now,
    index: true
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Geospatial index for location queries
locationSchema.index({ coordinates: "2dsphere" });
locationSchema.index({ shipperId: 1, orderId: 1, timestamp: -1 });

module.exports = mongoose.model("Location", locationSchema);
