import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../themes/app_theme.dart';
import '../../widgets/mobile_layout.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(text: 'Hello! How can I help you today?', isDoctor: true, time: DateTime.now().subtract(const Duration(minutes: 5))),
    ChatMessage(text: 'I have been experiencing headaches lately', isDoctor: false, time: DateTime.now().subtract(const Duration(minutes: 3))),
    ChatMessage(text: 'How long have you been experiencing these headaches?', isDoctor: true, time: DateTime.now().subtract(const Duration(minutes: 1))),
  ];

  @override
  Widget build(BuildContext context) {
    return MobileLayout(
      currentRoute: '/dashboard',
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMessagesList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F2937)),
          ),
          Stack(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/admin.png'),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dr. Sarah Wilson', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Cardiologist • Online', style: TextStyle(color: Color(0xFF10B981), fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Iconsax.call, color: Color(0xFF6366F1)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isDoctor ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isDoctor ? Colors.white : const Color(0xFF6366F1),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: message.isDoctor ? const Radius.circular(4) : const Radius.circular(16),
            bottomRight: message.isDoctor ? const Radius.circular(16) : const Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isDoctor ? AppTheme.textPrimary : Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.time),
              style: TextStyle(
                color: message.isDoctor ? AppTheme.textSecondary : Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Iconsax.send_1, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          text: _messageController.text.trim(),
          isDoctor: false,
          time: DateTime.now(),
        ));
        _messageController.clear();
      });
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class ChatMessage {
  final String text;
  final bool isDoctor;
  final DateTime time;

  ChatMessage({required this.text, required this.isDoctor, required this.time});
}