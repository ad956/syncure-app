class ChatRoom {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String? doctorPhoto;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  ChatRoom({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    this.doctorPhoto,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? '',
      doctorId: json['doctor_id'] ?? '',
      doctorName: json['doctor_name'] ?? '',
      doctorSpecialty: json['doctor_specialty'] ?? '',
      doctorPhoto: json['doctor_photo'],
      lastMessage: json['last_message'] ?? '',
      lastMessageTime: json['last_message_time'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
      isOnline: json['is_online'] ?? false,
    );
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String message;
  final String timestamp;
  final String status;
  final String? attachmentUrl;
  final String? attachmentType;
  final bool isFromPatient;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.status,
    this.attachmentUrl,
    this.attachmentType,
    required this.isFromPatient,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      roomId: json['room_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      senderName: json['sender_name'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
      status: json['status'] ?? 'sent',
      attachmentUrl: json['attachment_url'],
      attachmentType: json['attachment_type'],
      isFromPatient: json['is_from_patient'] ?? false,
    );
  }
}

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String? photo;
  final String hospital;
  final int experience;
  final double rating;
  final bool isOnline;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    this.photo,
    required this.hospital,
    required this.experience,
    required this.rating,
    required this.isOnline,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
      photo: json['photo'],
      hospital: json['hospital'] ?? '',
      experience: json['experience'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      isOnline: json['is_online'] ?? false,
    );
  }
}