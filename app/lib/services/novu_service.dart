import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:developer' as developer;

class NovuService {
  static String get _apiKey => dotenv.env['NOVU_API_KEY'] ?? '9bf8f535c3337adbaa9b753cb5d07012';
  static String get _appIdentifier => dotenv.env['NOVU_APP_IDENTIFIER'] ?? 'TYYV4MrlYpLD';
  static const String _baseUrl = 'https://api.novu.co/v1';
  static const String _subscriberId = 'patient_johndoe'; // Replace with actual user ID

  static Future<void> initializeNovu() async {
    try {
      // Create subscriber if not exists
      await createSubscriber(_subscriberId, {
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john@example.com',
        'phone': '+919876543210',
      });
      developer.log('🔔 Novu initialized successfully');
    } catch (e) {
      developer.log('❌ Novu initialization failed: $e');
    }
  }

  static Future<void> createSubscriber(String subscriberId, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/subscribers'),
        headers: {
          'Authorization': 'ApiKey $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'subscriberId': subscriberId,
          'firstName': data['firstName'],
          'lastName': data['lastName'],
          'email': data['email'],
          'phone': data['phone'],
        }),
      );
      
      if (response.statusCode == 201 || response.statusCode == 409) {
        developer.log('✅ Subscriber created/exists: $subscriberId');
      } else {
        developer.log('❌ Failed to create subscriber: ${response.body}');
      }
    } catch (e) {
      developer.log('❌ Error creating subscriber: $e');
    }
  }

  static Future<void> triggerNotification({
    required String templateId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/events/trigger'),
        headers: {
          'Authorization': 'ApiKey $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': templateId,
          'to': {
            'subscriberId': _subscriberId,
          },
          'payload': payload,
        }),
      );
      
      if (response.statusCode == 201) {
        developer.log('✅ Notification triggered: $templateId');
      } else {
        developer.log('❌ Failed to trigger notification: ${response.body}');
      }
    } catch (e) {
      developer.log('❌ Error triggering notification: $e');
    }
  }

  static Future<void> showNotifications(BuildContext context) async {
    // Show notifications panel
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationPanel(),
    );
  }

  static Future<List<NotificationItem>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/subscribers/$_subscriberId/notifications'),
        headers: {
          'Authorization': 'ApiKey $_apiKey',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final notifications = (data['data'] as List).map((item) {
          return NotificationItem(
            id: item['_id'],
            title: item['payload']['title'] ?? 'Notification',
            message: item['payload']['message'] ?? item['content'] ?? '',
            timestamp: DateTime.parse(item['createdAt']),
            isRead: item['read'] ?? false,
          );
        }).toList();
        
        developer.log('✅ Loaded ${notifications.length} notifications from Novu');
        return notifications;
      }
    } catch (e) {
      developer.log('❌ Error fetching notifications: $e');
    }
    
    // Fallback to mock notifications
    return [
      NotificationItem(
        id: '1',
        title: 'Appointment Reminder',
        message: 'You have an appointment with Dr. Smith tomorrow at 2:00 PM',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'Medicine Reminder',
        message: 'Time to take your medication - Aspirin 100mg',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
      ),
      NotificationItem(
        id: '3',
        title: 'Lab Results Ready',
        message: 'Your blood test results are now available',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
      ),
    ];
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });
}

class NotificationPanel extends StatefulWidget {
  const NotificationPanel({super.key});

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  List<NotificationItem> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final items = await NovuService.getNotifications();
    setState(() {
      notifications = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? const Center(
                    child: Text(
                      'No notifications',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: notification.isRead
                              ? Colors.white
                              : const Color(0xFFF31260).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: notification.isRead
                                ? const Color(0xFFE5E7EB)
                                : const Color(0xFFF31260).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                ),
                                if (!notification.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF31260),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notification.message,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatTimestamp(notification.timestamp),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}