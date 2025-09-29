import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/realtime_chat_provider.dart';
import '../providers/realtime_location_provider.dart';
import 'realtime_chat_page.dart';
import 'realtime_tracking_page.dart';

class RealtimeTestPage extends StatefulWidget {
  const RealtimeTestPage({Key? key}) : super(key: key);

  @override
  State<RealtimeTestPage> createState() => _RealtimeTestPageState();
}

class _RealtimeTestPageState extends State<RealtimeTestPage> {
  // Test data - replace with real IDs from create_test_data.js
  static const String testCustomerId = "REPLACE_WITH_REAL_CUSTOMER_ID";
  static const String testShipperId = "REPLACE_WITH_REAL_SHIPPER_ID";
  static const String testOrderId = "REPLACE_WITH_REAL_ORDER_ID";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Test Page'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTestDataInfo(),
            const SizedBox(height: 20),
            _buildTestButtons(),
            const SizedBox(height: 20),
            _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestDataInfo() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 Test Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text('Customer ID: $testCustomerId'),
            Text('Shipper ID: $testShipperId'),
            Text('Order ID: $testOrderId'),
            const SizedBox(height: 8),
            const Text(
              'Note: Replace these IDs with real ones from create_test_data.js',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🧪 Test WebSocket Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Chat Tests
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _testCustomerChat(),
                icon: const Icon(Icons.person),
                label: const Text('Customer Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _testShipperChat(),
                icon: const Icon(Icons.local_shipping),
                label: const Text('Shipper Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Location Tests
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _testLocationTracking(),
                icon: const Icon(Icons.location_on),
                label: const Text('Location Tracking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _testFullDemo(),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Full Demo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📖 How to Test',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '1. Backend Setup:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('   • Run: cd backend && npm run dev'),
            const Text('   • Run: node create_test_data.js'),
            const Text('   • Copy the generated IDs above'),
            const SizedBox(height: 8),
            
            const Text(
              '2. Frontend Setup:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('   • Replace test IDs with real ones'),
            const Text('   • Run: flutter run'),
            const SizedBox(height: 8),
            
            const Text(
              '3. Testing:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('   • Open 2 instances of the app'),
            const Text('   • Test customer and shipper chat'),
            const Text('   • Test location tracking'),
            const Text('   • Check real-time updates'),
            
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Text(
                '💡 Tip: Use multiple devices or browser tabs to test real-time communication between users.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testCustomerChat() {
    if (testCustomerId == "REPLACE_WITH_REAL_CUSTOMER_ID") {
      _showErrorDialog('Please replace test IDs with real ones from create_test_data.js');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RealtimeChatPage(
          orderId: testOrderId,
          userId: testCustomerId,
          userType: 'customer',
        ),
      ),
    );
  }

  void _testShipperChat() {
    if (testShipperId == "REPLACE_WITH_REAL_SHIPPER_ID") {
      _showErrorDialog('Please replace test IDs with real ones from create_test_data.js');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RealtimeChatPage(
          orderId: testOrderId,
          userId: testShipperId,
          userType: 'shipper',
        ),
      ),
    );
  }

  void _testLocationTracking() {
    if (testShipperId == "REPLACE_WITH_REAL_SHIPPER_ID") {
      _showErrorDialog('Please replace test IDs with real ones from create_test_data.js');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RealtimeTrackingPage(
          orderId: testOrderId,
          shipperId: testShipperId,
        ),
      ),
    );
  }

  void _testFullDemo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Full Demo Test'),
        content: const Text(
          'This will open multiple test pages. You can test:\n\n'
          '• Customer chat\n'
          '• Shipper chat\n'
          '• Location tracking\n'
          '• Real-time updates\n\n'
          'Open multiple instances to test communication between users.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startFullDemo();
            },
            child: const Text('Start Demo'),
          ),
        ],
      ),
    );
  }

  void _startFullDemo() {
    // Open customer chat
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RealtimeChatPage(
          orderId: testOrderId,
          userId: testCustomerId,
          userType: 'customer',
        ),
      ),
    );
    
    // Note: In a real app, you'd open multiple windows/tabs
    // For mobile, user needs to manually navigate between pages
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

