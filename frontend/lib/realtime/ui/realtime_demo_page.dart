import 'package:flutter/material.dart';
import 'realtime_chat_page.dart';
import 'realtime_tracking_page.dart';

class RealtimeDemoPage extends StatefulWidget {
  const RealtimeDemoPage({Key? key}) : super(key: key);

  @override
  State<RealtimeDemoPage> createState() => _RealtimeDemoPageState();
}

class _RealtimeDemoPageState extends State<RealtimeDemoPage> {
  String _selectedDemo = 'chat';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Features Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildDemoSelector(),
          Expanded(
            child: _buildDemoContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Realtime Demo:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Chat'),
                  value: 'chat',
                  groupValue: _selectedDemo,
                  onChanged: (value) {
                    setState(() {
                      _selectedDemo = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Tracking'),
                  value: 'tracking',
                  groupValue: _selectedDemo,
                  onChanged: (value) {
                    setState(() {
                      _selectedDemo = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemoContent() {
    switch (_selectedDemo) {
      case 'chat':
        return _buildChatDemo();
      case 'tracking':
        return _buildTrackingDemo();
      default:
        return const Center(child: Text('Select a demo option'));
    }
  }

  Widget _buildChatDemo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Realtime Chat Demo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'This demo shows real-time chat between customer and shipper using WebSocket.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RealtimeChatPage(
                          orderId: 'order_123',
                          userId: 'customer_123',
                          userType: 'customer',
                        ),
                      ),
                    );
                  },
                  child: const Text('Customer View'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RealtimeChatPage(
                          orderId: 'order_123',
                          userId: 'shipper_123',
                          userType: 'shipper',
                        ),
                      ),
                    );
                  },
                  child: const Text('Shipper View'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Features:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('• Real-time messaging via WebSocket'),
          const Text('• Message history persistence'),
          const Text('• Read receipts and unread count'),
          const Text('• System messages support'),
          const Text('• Multiple user types (customer, shipper, admin)'),
          const Text('• Room-based messaging per order'),
        ],
      ),
    );
  }

  Widget _buildTrackingDemo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Realtime Location Tracking Demo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'This demo shows real-time location tracking of the shipper with Google Maps integration.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RealtimeTrackingPage(
                          orderId: 'order_123',
                          shipperId: 'shipper_123',
                        ),
                      ),
                    );
                  },
                  child: const Text('View Tracking'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Features:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('• Real-time location updates via WebSocket'),
          const Text('• Google Maps integration with markers'),
          const Text('• Route visualization with polylines'),
          const Text('• Location history tracking'),
          const Text('• GPS accuracy and speed display'),
          const Text('• Automatic camera movement'),
          const SizedBox(height: 16),
          const Text(
            'Note: Location tracking requires location permissions.',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
