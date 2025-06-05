import 'package:ecofinds/screens/chatScreen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatNotification {
  final String sender;
  final String message;
  final DateTime time;

  ChatNotification({
    required this.sender,
    required this.message,
    required this.time,
  });

  factory ChatNotification.fromJson(Map<String, dynamic> json) {
    return ChatNotification(
      sender: json['user_id'].toString(),
      message: json['sent'] ?? '',
      time: DateTime.parse(json['datetime']),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<ChatNotification>> notificationsFuture;

  @override
  void initState() {
    super.initState();
    notificationsFuture = fetchNotifications();
  }

  Future<List<ChatNotification>> fetchNotifications() async {
    final response = await http.get(Uri.parse(
        'http://192.168.242.110/ecofinds/api/chat/showIncomingChats.php?receiver_id=9'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ChatNotification.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<String?> fetchUsername(String userId) async {
    final response = await http.post(
      Uri.parse('http://192.168.242.110/ecofinds/api/users/profile.php'),
      body: {'user_id': userId},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['username'];
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Notifications'),
      ),
      body: FutureBuilder<List<ChatNotification>>(
          future: notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No notifications found.'));
            }
            final notifications = snapshot.data!;
            // ...existing code...
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return FutureBuilder<String?>(
                  future: fetchUsername(notification.sender),
                  builder: (context, snapshot) {
                    final username =
                        snapshot.data ?? 'User ${notification.sender}';
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(username[0]),
                      ),
                      title: Text(username),
                      subtitle: Text(notification.message),
                      trailing: Text(
                        _formatTime(notification.time),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ChatScreen(
                              productOwnerId: notification.sender);
                        }));
                        // Handle notification tap
                      },
                    );
                  },
                );
              },
            );
          }),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
