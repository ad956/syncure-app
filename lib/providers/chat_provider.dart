import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import '../models/chat.dart';

class ChatState {
  final List<ChatRoom> chatRooms;
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({
    this.chatRooms = const [],
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatRoom>? chatRooms,
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      chatRooms: chatRooms ?? this.chatRooms,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ApiService _apiService;

  ChatNotifier(this._apiService) : super(ChatState());

  Future<void> loadChatRooms() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.getChatRooms();
      final List<dynamic> data = response.data['rooms'] ?? [];
      final rooms = data.map((json) => ChatRoom.fromJson(json)).toList();
      state = state.copyWith(chatRooms: rooms, isLoading: false);
    } catch (e) {
      // Use mock data if API fails
      final mockRooms = [
        ChatRoom(
          id: '1',
          doctorId: 'doc1',
          doctorName: 'Dr. Sarah Johnson',
          doctorSpecialty: 'Cardiologist',
          doctorPhoto: null,
          lastMessage: 'How are you feeling today?',
          lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
          unreadCount: 2,
          isOnline: true,
        ),
        ChatRoom(
          id: '2',
          doctorId: 'doc2',
          doctorName: 'Dr. Michael Chen',
          doctorSpecialty: 'General Medicine',
          doctorPhoto: null,
          lastMessage: 'Your test results look good',
          lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          unreadCount: 0,
          isOnline: false,
        ),
        ChatRoom(
          id: '3',
          doctorId: 'doc3',
          doctorName: 'Dr. Emily Davis',
          doctorSpecialty: 'Dermatologist',
          doctorPhoto: null,
          lastMessage: 'Please follow the prescribed treatment',
          lastMessageTime: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          unreadCount: 1,
          isOnline: true,
        ),
      ];
      state = state.copyWith(chatRooms: mockRooms, isLoading: false);
    }
  }

  Future<void> loadMessages(String roomId) async {
    try {
      final response = await _apiService.getChatMessages(roomId);
      final List<dynamic> data = response.data['messages'] ?? [];
      final messages = data.map((json) => ChatMessage.fromJson(json)).toList();
      state = state.copyWith(messages: messages);
      
      // Mark messages as read
      await _apiService.markMessagesAsRead(roomId);
      
      // Update unread count for the room
      final updatedRooms = state.chatRooms.map((room) {
        if (room.id == roomId) {
          return ChatRoom(
            id: room.id,
            doctorId: room.doctorId,
            doctorName: room.doctorName,
            doctorSpecialty: room.doctorSpecialty,
            doctorPhoto: room.doctorPhoto,
            lastMessage: room.lastMessage,
            lastMessageTime: room.lastMessageTime,
            unreadCount: 0,
            isOnline: room.isOnline,
          );
        }
        return room;
      }).toList();
      
      state = state.copyWith(chatRooms: updatedRooms);
    } catch (e) {
      // Use mock messages if API fails
      final mockMessages = [
        ChatMessage(
          id: '1',
          roomId: roomId,
          senderId: 'doc1',
          senderName: 'Dr. Sarah Johnson',
          message: 'Hello! How can I help you today?',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
          status: 'read',
          isFromPatient: false,
        ),
        ChatMessage(
          id: '2',
          roomId: roomId,
          senderId: 'patient1',
          senderName: 'Patient',
          message: 'I have been experiencing some chest pain lately.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String(),
          status: 'read',
          isFromPatient: true,
        ),
        ChatMessage(
          id: '3',
          roomId: roomId,
          senderId: 'doc1',
          senderName: 'Dr. Sarah Johnson',
          message: 'Can you describe the pain? Is it sharp or dull? When does it occur?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 40)).toIso8601String(),
          status: 'read',
          isFromPatient: false,
        ),
        ChatMessage(
          id: '4',
          roomId: roomId,
          senderId: 'patient1',
          senderName: 'Patient',
          message: 'It\'s a dull pain that occurs mostly when I exercise or climb stairs.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 35)).toIso8601String(),
          status: 'read',
          isFromPatient: true,
        ),
        ChatMessage(
          id: '5',
          roomId: roomId,
          senderId: 'doc1',
          senderName: 'Dr. Sarah Johnson',
          message: 'I recommend you come in for an ECG and stress test. This could be related to your heart condition.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
          status: 'delivered',
          isFromPatient: false,
        ),
      ];
      state = state.copyWith(messages: mockMessages);
    }
  }

  Future<void> sendMessage(String roomId, String message) async {
    // Add message optimistically to UI
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomId: roomId,
      senderId: 'patient1',
      senderName: 'Patient',
      message: message,
      timestamp: DateTime.now().toIso8601String(),
      status: 'sending',
      isFromPatient: true,
    );

    final updatedMessages = [...state.messages, newMessage];
    state = state.copyWith(messages: updatedMessages);

    try {
      await _apiService.sendMessage({
        'roomId': roomId,
        'message': message,
      });

      // Update message status to sent
      final sentMessages = state.messages.map((msg) {
        if (msg.id == newMessage.id) {
          return ChatMessage(
            id: msg.id,
            roomId: msg.roomId,
            senderId: msg.senderId,
            senderName: msg.senderName,
            message: msg.message,
            timestamp: msg.timestamp,
            status: 'sent',
            isFromPatient: msg.isFromPatient,
          );
        }
        return msg;
      }).toList();

      state = state.copyWith(messages: sentMessages);

      // Update last message in chat room
      final updatedRooms = state.chatRooms.map((room) {
        if (room.id == roomId) {
          return ChatRoom(
            id: room.id,
            doctorId: room.doctorId,
            doctorName: room.doctorName,
            doctorSpecialty: room.doctorSpecialty,
            doctorPhoto: room.doctorPhoto,
            lastMessage: message,
            lastMessageTime: DateTime.now().toIso8601String(),
            unreadCount: room.unreadCount,
            isOnline: room.isOnline,
          );
        }
        return room;
      }).toList();

      state = state.copyWith(chatRooms: updatedRooms);
    } catch (e) {
      // Update message status to failed
      final failedMessages = state.messages.map((msg) {
        if (msg.id == newMessage.id) {
          return ChatMessage(
            id: msg.id,
            roomId: msg.roomId,
            senderId: msg.senderId,
            senderName: msg.senderName,
            message: msg.message,
            timestamp: msg.timestamp,
            status: 'failed',
            isFromPatient: msg.isFromPatient,
          );
        }
        return msg;
      }).toList();

      state = state.copyWith(messages: failedMessages, error: 'Failed to send message');
    }
  }

  Future<void> createChatRoom(String doctorId) async {
    try {
      await _apiService.createChatRoom({
        'doctorId': doctorId,
      });
      
      // Reload chat rooms after creating
      await loadChatRooms();
    } catch (e) {
      state = state.copyWith(error: 'Failed to create chat room: ${e.toString()}');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearMessages() {
    state = state.copyWith(messages: []);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ApiService());
});