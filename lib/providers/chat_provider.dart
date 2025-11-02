import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import '../api/api_service.dart';
import '../models/chat.dart';
import 'auth_provider.dart';

class ChatState {
  final List<ChatRoom> chatRooms;
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isLoadingMessages;
  final bool isSendingImage;
  final String? error;

  ChatState({
    this.chatRooms = const [],
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMessages = false,
    this.isSendingImage = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatRoom>? chatRooms,
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isLoadingMessages,
    bool? isSendingImage,
    String? error,
  }) {
    return ChatState(
      chatRooms: chatRooms ?? this.chatRooms,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isSendingImage: isSendingImage ?? this.isSendingImage,
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
      
      if (response.statusCode == 200) {
        final rooms = (response.data['data']['rooms'] as List? ?? [])
            .map((room) => _mapApiRoomToChatRoom(room))
            .toList();
        
        state = state.copyWith(chatRooms: rooms, isLoading: false);
      } else {
        state = state.copyWith(
          chatRooms: [],
          isLoading: false,
          error: 'Failed to load chat rooms'
        );
      }
    } catch (e) {
      state = state.copyWith(
        chatRooms: [],
        isLoading: false,
        error: 'Error loading chat rooms: ${e.toString()}'
      );
    }
  }

  ChatRoom _mapApiRoomToChatRoom(Map<String, dynamic> room) {
    final participants = room['participants'] as List? ?? [];
    final doctorParticipant = participants.firstWhere(
      (p) => p['role'] == 'Doctor',
      orElse: () => null,
    );
    
    final doctor = doctorParticipant?['userId'] ?? {};
    final lastMessage = room['lastMessage'] ?? {};
    
    return ChatRoom(
      id: room['_id'] ?? '',
      doctorId: doctor['_id'] ?? '',
      doctorName: 'Dr. ${doctor['firstname'] ?? ''} ${doctor['lastname'] ?? ''}',
      doctorSpecialty: doctor['specialty'] ?? 'General Medicine',
      doctorPhoto: doctor['profile'],
      lastMessage: lastMessage['message'] ?? 'Start a conversation',
      lastMessageTime: lastMessage['createdAt'] ?? DateTime.now().toIso8601String(),
      unreadCount: 0,
      isOnline: true,
    );
  }



  Future<void> loadMessages(String roomId) async {
    state = state.copyWith(isLoadingMessages: true);
    
    try {
      final response = await _apiService.getChatMessages(roomId);
      
      if (response.statusCode == 200) {
        final messages = (response.data['data']['messages'] as List? ?? [])
            .map((json) => _mapApiMessageToChatMessage(json))
            .toList();
        state = state.copyWith(
          messages: messages,
          isLoadingMessages: false,
        );
        
        // Mark messages as read
        await _apiService.markMessagesAsRead(roomId);
        
        // Update unread count for the room
        _updateRoomUnreadCount(roomId, 0);
      } else {
        state = state.copyWith(
          messages: [],
          isLoadingMessages: false,
          error: 'Failed to load messages'
        );
      }
    } catch (e) {
      state = state.copyWith(
        messages: [],
        isLoadingMessages: false,
        error: 'Error loading messages: ${e.toString()}'
      );
    }
  }

  ChatMessage _mapApiMessageToChatMessage(Map<String, dynamic> json) {
    final sender = json['senderId'] ?? {};
    final senderRole = json['senderRole'] ?? '';
    
    return ChatMessage(
      id: json['_id'] ?? '',
      roomId: json['roomId'] ?? '',
      senderId: sender['_id'] ?? '',
      senderName: senderRole == 'Patient' ? 'You' : 'Dr. ${sender['firstname'] ?? ''} ${sender['lastname'] ?? ''}',
      message: json['message'] ?? '',
      timestamp: json['createdAt'] ?? DateTime.now().toIso8601String(),
      status: 'sent',
      attachmentUrl: json['imageUrl'],
      attachmentType: json['messageType'] == 'image' ? 'image' : null,
      isFromPatient: senderRole == 'Patient',
    );
  }

  void _updateRoomUnreadCount(String roomId, int count) {
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
          unreadCount: count,
          isOnline: room.isOnline,
        );
      }
      return room;
    }).toList();
    
    state = state.copyWith(chatRooms: updatedRooms);
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
      final response = await _apiService.sendMessage({
        'roomId': roomId,
        'message': message,
        'messageType': 'text',
      });

      if (response.statusCode == 200) {
        // Update message status to sent
        _updateMessageStatus(newMessage.id, 'sent');
        
        // Update last message in chat room
        _updateRoomLastMessage(roomId, message);
      } else {
        _updateMessageStatus(newMessage.id, 'failed');
      }
    } catch (e) {
      _updateMessageStatus(newMessage.id, 'failed');
      state = state.copyWith(error: 'Failed to send message');
    }
  }

  void _updateMessageStatus(String messageId, String status) {
    final updatedMessages = state.messages.map((msg) {
      if (msg.id == messageId) {
        return ChatMessage(
          id: msg.id,
          roomId: msg.roomId,
          senderId: msg.senderId,
          senderName: msg.senderName,
          message: msg.message,
          timestamp: msg.timestamp,
          status: status,
          isFromPatient: msg.isFromPatient,
        );
      }
      return msg;
    }).toList();

    state = state.copyWith(messages: updatedMessages);
  }

  void _updateRoomLastMessage(String roomId, String message) {
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

  Future<void> sendImageMessage(String roomId) async {
    state = state.copyWith(isSendingImage: true);
    
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) {
        state = state.copyWith(isSendingImage: false);
        return;
      }
      
      // Upload to Cloudinary
      final imageUrl = await _uploadImageToCloudinary(File(image.path));
      
      if (imageUrl != null) {
        // Send message with image
        final response = await _apiService.sendMessage({
          'roomId': roomId,
          'message': '',
          'messageType': 'image',
          'imageUrl': imageUrl,
        });
        
        if (response.statusCode == 200) {
          // Reload messages to show the new image
          await loadMessages(roomId);
        }
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to send image: ${e.toString()}',
      );
    } finally {
      state = state.copyWith(isSendingImage: false);
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    try {
      // Step 1: Get signature from backend
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final publicId = 'chat_image_${timestamp}';
      
      final signResponse = await _apiService.uploadImage({
        'paramsToSign': {
          'timestamp': timestamp.toString(),
          'folder': 'syncure',
          'public_id': publicId,
        }
      });
      
      if (signResponse.statusCode != 200) return null;
      
      final signature = signResponse.data['signature'];
      final apiKey = dotenv.env['CLOUDINARY_API_KEY']!;
      
      // Step 2: Upload to Cloudinary using multipart
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
        'timestamp': timestamp.toString(),
        'folder': 'syncure',
        'public_id': publicId,
        'api_key': apiKey,
        'signature': signature,
      });
      
      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
      final uploadResponse = await Dio().post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: formData,
      );
      
      if (uploadResponse.statusCode == 200) {
        return uploadResponse.data['secure_url'];
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ApiService());
});