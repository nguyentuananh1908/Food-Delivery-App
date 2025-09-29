import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'chat_list_page.dart';
import 'chat_conversation_page.dart';
import 'save_location_page.dart';
import 'realtime_tracking_page.dart';

class MainDemoPage extends StatefulWidget {
  const MainDemoPage({Key? key}) : super(key: key);

  @override
  State<MainDemoPage> createState() => _MainDemoPageState();
}

class _MainDemoPageState extends State<MainDemoPage> {
  // Test data - replace with real IDs from create_users_and_orders.js
  static const String testCustomerId = "REPLACE_WITH_REAL_CUSTOMER_ID";
  static const String testShipperId = "REPLACE_WITH_REAL_SHIPPER_ID";
  static const String testOrderId = "REPLACE_WITH_REAL_ORDER_ID";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Food Delivery Demo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            _buildTestDataInfo(),
            const SizedBox(height: 30),
            _buildFeatureButtons(),
            const SizedBox(height: 20),
            _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🍕 Food Delivery App',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Real-time Chat & Location Tracking',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🚀 Demo Version',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestDataInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Test Data Setup',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDataRow('Customer ID:', testCustomerId),
            _buildDataRow('Shipper ID:', testShipperId),
            _buildDataRow('Order ID:', testOrderId),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replace these IDs with real ones from create_users_and_orders.js',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🧪 Test Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureButton(
          icon: Icons.chat_bubble_outline,
          title: 'Chat Messages',
          subtitle: 'Real-time chat between customer and shipper',
          color: Colors.blue,
          onTap: () => _openChatList(),
        ),
        const SizedBox(height: 12),
        _buildFeatureButton(
          icon: Icons.location_on_outlined,
          title: 'Save Location',
          subtitle: 'Save delivery addresses with map selection',
          color: Colors.green,
          onTap: () => _openSaveLocation(),
        ),
        const SizedBox(height: 12),
        _buildFeatureButton(
          icon: Icons.track_changes_outlined,
          title: 'Location Tracking',
          subtitle: 'Track shipper location in real-time',
          color: Colors.red,
          onTap: () => _openLocationTracking(),
        ),
        const SizedBox(height: 12),
        _buildFeatureButton(
          icon: Icons.chat_outlined,
          title: 'Direct Chat',
          subtitle: 'Chat with specific user about order',
          color: Colors.purple,
          onTap: () => _openDirectChat(),
        ),
      ],
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber.shade600),
              const SizedBox(width: 8),
              const Text(
                'Quick Start Guide',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionStep('1', 'Run: cd backend && node create_users_and_orders.js'),
          _buildInstructionStep('2', 'Copy the generated IDs and replace in this file'),
          _buildInstructionStep('3', 'Start backend: npm run dev'),
          _buildInstructionStep('4', 'Start frontend: flutter run'),
          _buildInstructionStep('5', 'Test chat and location features'),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _openChatList() {
    if (testCustomerId == "REPLACE_WITH_REAL_CUSTOMER_ID") {
      _showSetupDialog();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatListPage(
          userId: testCustomerId,
          userType: 'customer',
        ),
      ),
    );
  }

  void _openSaveLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaveLocationPage(
          initialLocation: LatLng(21.0285, 105.8542),
          address: '3235 Royal Ln. Mesa, New Jersey 34567',
        ),
      ),
    );
  }

  void _openLocationTracking() {
    if (testShipperId == "REPLACE_WITH_REAL_SHIPPER_ID") {
      _showSetupDialog();
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

  void _openDirectChat() {
    if (testCustomerId == "REPLACE_WITH_REAL_CUSTOMER_ID") {
      _showSetupDialog();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConversationPage(
          orderId: testOrderId,
          userId: testCustomerId,
          userType: 'customer',
          otherUser: {
            'id': testShipperId,
            'name': 'Mike Wilson',
            'avatar': null,
            'isOnline': true,
          },
        ),
      ),
    );
  }

  void _showSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Required'),
        content: const Text(
          'Please run create_users_and_orders.js first and replace the test IDs with real ones.',
        ),
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
