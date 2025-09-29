const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  phone: {
    type: String,
    required: true,
    trim: true
  },
  avatar: {
    type: String,
    default: null
  },
  role: {
    type: String,
    enum: ["customer", "shipper", "admin", "restaurant"],
    default: "customer"
  },
  isOnline: {
    type: Boolean,
    default: false
  },
  lastSeen: {
    type: Date,
    default: Date.now
  },
  // Thông tin dành cho shipper
  shipperInfo: {
    licenseNumber: String,
    vehicleType: {
      type: String,
      enum: ["motorbike", "bicycle", "car", "walking"]
    },
    vehicleNumber: String,
    isAvailable: {
      type: Boolean,
      default: true
    },
    rating: {
      type: Number,
      default: 5.0,
      min: 0,
      max: 5
    },
    totalDeliveries: {
      type: Number,
      default: 0
    },
    currentLocation: {
      type: {
        type: String,
        enum: ["Point"],
        default: "Point"
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
        default: [105.8542, 21.0285] // Hanoi coordinates
      }
    }
  },
  // Thông tin dành cho customer
  customerInfo: {
    addresses: [{
      label: {
        type: String,
        enum: ["home", "work", "other"],
        default: "home"
      },
      street: String,
      city: String,
      postalCode: String,
      apartment: String,
      coordinates: {
        type: {
          type: String,
          enum: ["Point"],
          default: "Point"
        },
        coordinates: [Number]
      },
      isDefault: {
        type: Boolean,
        default: false
      }
    }],
    preferences: {
      notifications: {
        type: Boolean,
        default: true
      }
    }
  },
  // Thông tin dành cho restaurant
  restaurantInfo: {
    businessName: String,
    businessLicense: String,
    address: String,
    coordinates: {
      type: {
        type: String,
        enum: ["Point"],
        default: "Point"
      },
      coordinates: [Number]
    },
    cuisine: [String],
    deliveryRadius: {
      type: Number,
      default: 5 // km
    },
    isOpen: {
      type: Boolean,
      default: true
    }
  }
}, {
  timestamps: true
});

// Indexes
userSchema.index({ email: 1 });
userSchema.index({ role: 1 });
userSchema.index({ "shipperInfo.currentLocation": "2dsphere" });
userSchema.index({ "restaurantInfo.coordinates": "2dsphere" });

// Virtual for full name
userSchema.virtual('fullName').get(function() {
  return this.name;
});

// Method to get user's current location
userSchema.methods.getCurrentLocation = function() {
  if (this.role === 'shipper' && this.shipperInfo.currentLocation) {
    return this.shipperInfo.currentLocation;
  }
  if (this.role === 'restaurant' && this.restaurantInfo.coordinates) {
    return this.restaurantInfo.coordinates;
  }
  return null;
};

// Method to update shipper location
userSchema.methods.updateLocation = function(longitude, latitude) {
  if (this.role === 'shipper') {
    this.shipperInfo.currentLocation.coordinates = [longitude, latitude];
    this.lastSeen = new Date();
    return this.save();
  }
  return Promise.reject(new Error('Only shippers can update location'));
};

// Method to set online status
userSchema.methods.setOnlineStatus = function(isOnline) {
  this.isOnline = isOnline;
  if (!isOnline) {
    this.lastSeen = new Date();
  }
  return this.save();
};

module.exports = mongoose.model("User", userSchema);


