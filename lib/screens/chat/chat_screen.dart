import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../themes/app_theme.dart';
import '../../widgets/mobile_layout.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  String? selectedRoomId;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).loadChatRooms();
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
    final chatState = ref.watch(chatProvider);
    
    // Show error toast if there's an error
    if (chatState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(chatState.error!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(chatProvider.notifier).clearError();
      });
    }
    
    return MobileLayout(
      currentRoute: '/chat',
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(selectedRoomId != null ? 'Chat' : 'Doctor Chat'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: selectedRoomId != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => selectedRoomId = null),
                )
              : null,
        ),
        body: selectedRoomId != null
            ? _buildChatInterface(chatState)
            : _buildChatRoomsList(chatState),
      ),
    );
  }

  Widget _buildChatRoomsList(ChatState chatState) {
    if (chatState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatState.chatRooms.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chatState.chatRooms.length,
      itemBuilder: (context, index) {
        final room = chatState.chatRooms[index];
        return _buildChatRoomItem(room);
      },
    );
  }



  Widget _buildChatRoomItem(ChatRoom room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: room.doctorPhoto != null
                  ? NetworkImage(room.doctorPhoto!)
                  : const AssetImage('assets/images/doctor.png') as ImageProvider,
            ),
            if (room.isOnline)
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
        title: Text(
          room.doctorName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room.doctorSpecialty,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              room.lastMessage.isNotEmpty ? room.lastMessage : 'Start a conversation',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(room.lastMessageTime),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            if (room.unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  room.unreadCount.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]
          ],
        ),
        onTap: () {
          setState(() => selectedRoomId = room.id);
          ref.read(chatProvider.notifier).loadMessages(room.id);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.message,
                size: 48,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No doctors available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later for available doctors to chat with',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInterface(ChatState chatState) {
    final room = chatState.chatRooms.firstWhere((r) => r.id == selectedRoomId);
    final messages = chatState.messages;

    return Column(
      children: [
        _buildChatHeader(room),
        Expanded(
          child: chatState.isLoadingMessages
              ? const Center(child: CircularProgressIndicator())
              : messages.isEmpty
                  ? _buildEmptyChatState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return _buildMessageBubble(message);
                      },
                    ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildChatHeader(ChatRoom room) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: room.doctorPhoto != null
                    ? NetworkImage(room.doctorPhoto!)
                    : const AssetImage('assets/images/doctor.png') as ImageProvider,
              ),
              if (room.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.doctorName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  room.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: room.isOnline ? const Color(0xFF10B981) : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChatState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'Start a conversation with the doctor',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isFromPatient = message.isFromPatient;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isFromPatient ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromPatient) ...[
            const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/images/doctor.png'),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFromPatient ? const Color(0xFF6366F1) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.attachmentUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.attachmentUrl!,
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 150,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    ),
                    if (message.message.isNotEmpty) const SizedBox(height: 8),
                  ],
                  if (message.message.isNotEmpty)
                    Text(
                      message.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: isFromPatient ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isFromPatient ? Colors.white70 : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isFromPatient) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/images/admin.png'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final chatState = ref.watch(chatProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: chatState.isSendingImage
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.image, color: Color(0xFF6366F1)),
            onPressed: chatState.isSendingImage ? null : _sendImage,
          ),
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
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || selectedRoomId == null) return;
    
    ref.read(chatProvider.notifier).sendMessage(
      selectedRoomId!,
      _messageController.text.trim(),
    );
    
    _messageController.clear();
    
    // Scroll to bottom
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

  String _formatTime(String timestamp) {
    if (timestamp.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  void _sendImage() {
    if (selectedRoomId == null) return;
    ref.read(chatProvider.notifier).sendImageMessage(selectedRoomId!);
  }

  String _formatMessageTime(String timestamp) {
    if (timestamp.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        return DateFormat('MMM dd, HH:mm').format(dateTime);
      } else {
        return DateFormat('HH:mm').format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }
}