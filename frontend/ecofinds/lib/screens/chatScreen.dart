import 'dart:async';
import 'dart:convert';

import 'package:ecofinds/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final String productOwnerId;
  final String? chatTitle;
  const ChatScreen({Key? key, required this.productOwnerId, this.chatTitle})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // final List<Map<String, dynamic>> _messages = [
  //   // Example messages
  //   {"text": "Hello! How can I help you?", "isMe": false, "time": "09:00"},
  //   {
  //     "text": "Hi! I want to know more about your products.",
  //     "isMe": true,
  //     "time": "09:01"
  //   },
  //   {
  //     "text": "Sure! What would you like to know?",
  //     "isMe": false,
  //     "time": "09:02"
  //   },
  // ];
  List _messages = [];
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? userId;
  Timer? timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMessages();
    timer = Timer.periodic(
        Duration(seconds: 2), (Timer t) => getMessages());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void getMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id');
    });
    var res = await http.get(Uri.parse(
        '$baseUrl/chat/getChat.php?user_id=${userId}&receiver_id=${widget.productOwnerId}'));
    if (res.statusCode == 200) {
      setState(() {
        _messages = jsonDecode(res.body);
      });
    }
  }

  void _sendMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    var res = await http.get(Uri.parse(
        '$baseUrl/chat/send_chat.php?user_id=${userId}&receiver_id=${widget.productOwnerId}&msg=${_msgController.text.toString()}'));
    if (res.statusCode == 200) {
      _msgController.clear();
      getMessages();
    } else {
      print('Error while Sending Message.');
    }
    // setState(() {
    //   _messages.add({
    //     "text": text,
    //     "isMe": true,
    //     "time": TimeOfDay.now().format(context),
    //   });
    // });
    // _controller.clear();
    // Future.delayed(const Duration(milliseconds: 100), () {
    //   _scrollController.animateTo(
    //     _scrollController.position.maxScrollExtent,
    //     duration: const Duration(milliseconds: 300),
    //     curve: Curves.easeOut,
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatTitle ?? "Chat"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Container(
        color: const Color(0xFFF6F6F6),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = (msg["user_id"] == userId);
                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.green.shade100 : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg["sent"],
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg["datetime"] ?? "",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 2,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        filled: true,
                        fillColor: const Color(0xFFF1F1F1),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.green.shade700,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
