import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'tracking_page.dart';
import 'shipper_dashboard.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({Key? key}) : super(key: key);

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  String _selectedDemo = 'chat';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket & Location Demo'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildRealtimeDemoButton(),
          _buildDemoSelector(),
          Expanded(
            child: _buildDemoContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeDemoButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🚀 New Realtime Features',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try the new separated realtime chat and location tracking features!',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/realtime-demo');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Realtime Demo'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/websocket-test');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('WebSocket Test'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
            'Original Demo (Legacy):',
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
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Shipper'),
                  value: 'shipper',
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
      case 'shipper':
        return const ShipperDashboard(shipperId: 'shipper_123');
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
            'Chat Demo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'This demo shows real-time chat between customer and shipper.',
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
                        builder: (context) => ChatPage(
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
                        builder: (context) => ChatPage(
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
          const Text('• Real-time messaging'),
          const Text('• Message history'),
          const Text('• Read receipts'),
          const Text('• System messages'),
          const Text('• Multiple user types'),
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
            'Location Tracking Demo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'This demo shows real-time location tracking of the shipper.',
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
                        builder: (context) => TrackingPage(
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
          const Text('• Real-time location updates'),
          const Text('• Google Maps integration'),
          const Text('• Route visualization'),
          const Text('• Location history'),
          const Text('• GPS accuracy display'),
          const SizedBox(height: 16),
          const Text(
            'Note: Location tracking requires location permissions.',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
