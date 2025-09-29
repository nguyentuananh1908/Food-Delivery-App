import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../providers/location_provider.dart';
import '../models/location_data.dart';
import 'chat_page.dart';
import 'tracking_page.dart';

class ShipperDashboard extends StatefulWidget {
  final String shipperId;

  const ShipperDashboard({
    Key? key,
    required this.shipperId,
  }) : super(key: key);

  @override
  State<ShipperDashboard> createState() => _ShipperDashboardState();
}

class _ShipperDashboardState extends State<ShipperDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _currentOrderId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      locationProvider.initialize(widget.shipperId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _selectOrder(String orderId) {
    setState(() {
      _currentOrderId = orderId;
    });

    // Initialize chat for selected order
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.initialize(widget.shipperId, 'shipper');
    chatProvider.connectToOrder(orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipper Dashboard'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        bottom: _currentOrderId != null
            ? TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(icon: Icon(Icons.chat), text: 'Chat'),
                  Tab(icon: Icon(Icons.location_on), text: 'Tracking'),
                ],
              )
            : null,
      ),
      body: _currentOrderId == null
          ? _buildOrderSelection()
          : TabBarView(
              controller: _tabController,
              children: [
                ChatPage(
                  orderId: _currentOrderId!,
                  userId: widget.shipperId,
                  userType: 'shipper',
                ),
                TrackingPage(
                  orderId: _currentOrderId!,
                  shipperId: widget.shipperId,
                ),
              ],
            ),
    );
  }

  Widget _buildOrderSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select an Order',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _getMockOrders().length,
              itemBuilder: (context, index) {
                final order = _getMockOrders()[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Text(
                        '#' + order['id'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text('Order #${order['id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer: ${order['customer']}'),
                        Text('Restaurant: ${order['restaurant']}'),
                        Text('Status: ${order['status']}'),
                        Text('Total: \$${order['total']}'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _selectOrder(order['id'].toString()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockOrders() {
    // TODO: Replace with actual API call
    return [
      {
        'id': '1',
        'customer': 'John Doe',
        'restaurant': 'Pizza Palace',
        'status': 'Ready for pickup',
        'total': 25.99,
      },
      {
        'id': '2',
        'customer': 'Jane Smith',
        'restaurant': 'Burger King',
        'status': 'Preparing',
        'total': 18.50,
      },
      {
        'id': '3',
        'customer': 'Bob Johnson',
        'restaurant': 'Taco Bell',
        'status': 'Confirmed',
        'total': 12.75,
      },
    ];
  }
}

class CustomerTrackingPage extends StatefulWidget {
  final String orderId;
  final String customerId;

  const CustomerTrackingPage({
    Key? key,
    required this.orderId,
    required this.customerId,
  }) : super(key: key);

  @override
  State<CustomerTrackingPage> createState() => _CustomerTrackingPageState();
}

class _CustomerTrackingPageState extends State<CustomerTrackingPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.initialize(widget.customerId, 'customer');
      chatProvider.connectToOrder(widget.orderId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.chat), text: 'Chat'),
            Tab(icon: Icon(Icons.location_on), text: 'Track'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ChatPage(
            orderId: widget.orderId,
            userId: widget.customerId,
            userType: 'customer',
          ),
          Consumer<LocationProvider>(
            builder: (context, locationProvider, child) {
              return FutureBuilder<LocationData?>(
                future: locationProvider.getCurrentLocationForOrder(widget.orderId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final currentLocation = snapshot.data;
                  if (currentLocation == null) {
                    return const Center(
                      child: Text('No location data available'),
                    );
                  }

                  return TrackingPage(
                    orderId: widget.orderId,
                    shipperId: currentLocation.shipperId,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
