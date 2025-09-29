import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/realtime_chat_provider.dart';
import '../models/realtime_chat_message.dart';
import 'chat_conversation_page.dart';

class ChatListPage extends StatefulWidget {
  final String userId;
  final String userType;

  const ChatListPage({
    Key? key,
    required this.userId,
    required this.userType,
  }) : super(key: key);

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize chat provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<RealtimeChatProvider>(context, listen: false);
      chatProvider.initialize(widget.userId, widget.userType);
      chatProvider.loadUnreadCount();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              child: Text(
                'Notifications',
                style: TextStyle(fontSize: 14),
              ),
            ),
            Consumer<RealtimeChatProvider>(
              builder: (context, chatProvider, child) {
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Messages'),
                      if (chatProvider.unreadCount > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${chatProvider.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsTab(),
          _buildMessagesTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildNotificationsTab() {
    return const Center(
      child: Text(
        'No notifications yet',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    return Consumer<RealtimeChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final conversations = _getMockConversations();

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            return _buildConversationItem(conversation);
          },
        );
      },
    );
  }

  Widget _buildConversationItem(Map<String, dynamic> conversation) {
    final bool isOnline = conversation['isOnline'] ?? false;
    final int unreadCount = conversation['unreadCount'] ?? 0;
    final String lastMessage = conversation['lastMessage'] ?? '';
    final DateTime lastMessageTime = conversation['lastMessageTime'] ?? DateTime.now();

    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[300],
              backgroundImage: conversation['avatar'] != null 
                  ? NetworkImage(conversation['avatar'])
                  : null,
              child: conversation['avatar'] == null 
                  ? Text(
                      conversation['name'][0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            if (isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          conversation['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          lastMessage,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('HH:mm').format(lastMessageTime),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatConversationPage(
                orderId: conversation['orderId'],
                userId: widget.userId,
                userType: widget.userType,
                otherUser: {
                  'id': conversation['id'],
                  'name': conversation['name'],
                  'avatar': conversation['avatar'],
                  'isOnline': isOnline,
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.grid_view, false),
          _buildNavItem(Icons.menu, false),
          _buildNavItem(Icons.add, true),
          _buildNavItem(Icons.notifications_outlined, false),
          _buildNavItem(Icons.person_outline, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive) {
    return Container(
      width: isActive ? 50 : 40,
      height: isActive ? 50 : 40,
      decoration: BoxDecoration(
        color: isActive ? Colors.orange : Colors.transparent,
        shape: BoxShape.circle,
        border: isActive ? Border.all(color: Colors.orange, width: 2) : null,
      ),
      child: Icon(
        icon,
        color: isActive ? Colors.white : Colors.grey[600],
        size: isActive ? 24 : 20,
      ),
    );
  }

  List<Map<String, dynamic>> _getMockConversations() {
    return [
      {
        'id': 'shipper_123',
        'name': 'Royal Parvej',
        'avatar': null,
        'isOnline': true,
        'orderId': 'order_1',
        'lastMessage': 'Sounds awesome!',
        'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 5)),
        'unreadCount': 1,
      },
      {
        'id': 'shipper_456',
        'name': 'Cameron Williamson',
        'avatar': null,
        'isOnline': true,
        'orderId': 'order_2',
        'lastMessage': 'Ok, Just hurry up little bit...😊',
        'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 10)),
        'unreadCount': 2,
      },
      {
        'id': 'shipper_789',
        'name': 'Ralph Edwards',
        'avatar': null,
        'isOnline': true,
        'orderId': 'order_3',
        'lastMessage': 'Thanks dude.',
        'lastMessageTime': DateTime.now().subtract(const Duration(hours: 1)),
        'unreadCount': 0,
      },
      {
        'id': 'shipper_101',
        'name': 'Cody Fisher',
        'avatar': null,
        'isOnline': true,
        'orderId': 'order_4',
        'lastMessage': 'How is going...?',
        'lastMessageTime': DateTime.now().subtract(const Duration(hours: 2)),
        'unreadCount': 0,
      },
      {
        'id': 'shipper_102',
        'name': 'Eleanor Pena',
        'avatar': null,
        'isOnline': false,
        'orderId': 'order_5',
        'lastMessage': 'Thanks for the awesome food man...!',
        'lastMessageTime': DateTime.now().subtract(const Duration(days: 1)),
        'unreadCount': 0,
      },
    ];
  }
}
