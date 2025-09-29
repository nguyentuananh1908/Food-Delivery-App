require("dotenv").config();
// Nó nạp (load) toàn bộ biến môi trường từ file .env vào process.env của Node.js.
const express = require("express");
const cors = require("cors");
// Nó giúp server cho phép (hoặc chặn) client từ domain khác gọi API của bạn.
const mongoose = require("mongoose");
const http = require("http");
const foodRoute = require("./routes/foodRoute");
const loginRoute = require("./routes/login");
const locationRoute = require("./routes/location");
const { connectRedis } = require("./redisClient");
const addressRoute = require("./routes/addressRoute");
const chatRoute = require("./routes/chatRoute");
const SocketServer = require("./websocket/socketServer");

// Read connection values from environment (see .env or .env.example)
const MONGO_URL =
  process.env.MONGO_URL ||
  process.env.MONGO ||
  "mongodb://localhost:27017/FoodDeliveryApp";

mongoose
  .connect(MONGO_URL, {
    useNewUrlParser: true,
    // useNewUrlParser: true buộc nó dùng parser mới và ổn định hơn
    useUnifiedTopology: true,
  })
  .then(() => console.log("Connected to MongoDB"))
  .catch((err) => console.error("Failed to connect to MongoDB", err));

const app = express();
const server = http.createServer(app);
const PORT = process.env.PORT || 3000;

// Initialize WebSocket server
const socketServer = new SocketServer(server);

// Middleware
app.use(cors());
app.use(express.json());

app.use("/api/foods", foodRoute);
app.use("/api/auth", loginRoute);
app.use("/api/location", locationRoute);
app.use("/api/addresses", addressRoute);
app.use("/api/chat", chatRoute);

// Hello World route
app.get("/", (req, res) => {
  res.json({
    message: "Hello World from Food Delivery Backend!",
    status: "success",
    timestamp: new Date().toISOString(),
  });
});

// Start server
server.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
  console.log(`WebSocket server is ready for connections`);
  // Connect to Redis (best-effort)
  connectRedis().catch((err) =>
    console.error("Failed to connect to Redis", err)
  );
});

// Export socket server for use in other modules
app.socketServer = socketServer;

module.exports = app;
