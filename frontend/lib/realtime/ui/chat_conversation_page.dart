import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/realtime_chat_provider.dart';
import '../models/realtime_chat_message.dart';

class ChatConversationPage extends StatefulWidget {
  final String orderId;
  final String userId;
  final String userType;
  final Map<String, dynamic> otherUser;

  const ChatConversationPage({
    Key? key,
    required this.orderId,
    required this.userId,
    required this.userType,
    required this.otherUser,
  }) : super(key: key);

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final chatProvider = Provider.of<RealtimeChatProvider>(context, listen: false);
      chatProvider.initialize(widget.userId, widget.userType);
      await chatProvider.connectToOrder(widget.orderId);
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to chat: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[300],
              backgroundImage: widget.otherUser['avatar'] != null 
                  ? NetworkImage(widget.otherUser['avatar'])
                  : null,
              child: widget.otherUser['avatar'] == null 
                  ? Text(
                      widget.otherUser['name'][0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUser['name'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.otherUser['isOnline'] ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: widget.otherUser['isOnline'] ? Colors.green : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => _showMoreOptions(),
          ),
        ],
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Consumer<RealtimeChatProvider>(
              builder: (context, chatProvider, child) {
                return Column(
                  children: [
                    Expanded(
                      child: _buildMessagesList(chatProvider),
                    ),
                    _buildMessageInput(chatProvider),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildMessagesList(RealtimeChatProvider chatProvider) {
    if (chatProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatProvider.messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet.\nStart the conversation!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        return _buildMessageBubble(message, index, chatProvider.messages);
      },
    );
  }

  Widget _buildMessageBubble(RealtimeChatMessage message, int index, List<RealtimeChatMessage> allMessages) {
    final isMe = message.senderId == widget.userId;
    final isSystem = message.isSystemMessage;
    
    // Check if this message should show timestamp
    bool showTimestamp = true;
    if (index > 0) {
      final previousMessage = allMessages[index - 1];
      final timeDiff = message.createdAt.difference(previousMessage.createdAt);
      showTimestamp = timeDiff.inMinutes >= 1;
    }

    return Column(
      children: [
        if (showTimestamp)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              DateFormat('h:mm a').format(message.createdAt),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
        Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe && !isSystem) ...[
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey[300],
                backgroundImage: widget.otherUser['avatar'] != null 
                    ? NetworkImage(widget.otherUser['avatar'])
                    : null,
                child: widget.otherUser['avatar'] == null 
                    ? Text(
                        widget.otherUser['name'][0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSystem
                      ? Colors.grey[200]
                      : isMe
                          ? Colors.orange
                          : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.message,
                      style: TextStyle(
                        color: isSystem
                            ? Colors.black87
                            : isMe
                                ? Colors.white
                                : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('h:mm a').format(message.createdAt),
                          style: TextStyle(
                            color: isSystem
                                ? Colors.black54
                                : isMe
                                    ? Colors.white70
                                    : Colors.black54,
                            fontSize: 11,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.check,
                            color: Colors.white70,
                            size: 12,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.orange,
                child: widget.otherUser['avatar'] != null 
                    ? ClipOval(
                        child: Image.network(
                          widget.otherUser['avatar'],
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 12,
                      ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMessageInput(RealtimeChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
            onPressed: () => _showEmojiPicker(),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Write somethings',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _sendMessage(_messageController.text),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    final chatProvider = Provider.of<RealtimeChatProvider>(context, listen: false);
    try {
      chatProvider.sendMessage(message.trim());
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  void _showEmojiPicker() {
    // TODO: Implement emoji picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emoji picker coming soon!')),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Order Details'),
              onTap: () {
                Navigator.pop(context);
                _showOrderDetails();
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Track Location'),
              onTap: () {
                Navigator.pop(context);
                _trackLocation();
              },
            ),
            ListTile(
              leading: const Icon(Icons.call_outlined),
              title: const Text('Call Shipper'),
              onTap: () {
                Navigator.pop(context);
                _callShipper();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Details'),
        content: const Text('Order details will be shown here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _trackLocation() {
    // TODO: Navigate to tracking page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location tracking coming soon!')),
    );
  }

  void _callShipper() {
    // TODO: Implement calling functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calling functionality coming soon!')),
    );
  }
}
