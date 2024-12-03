import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/env/app_env.dart';
import 'dart:convert';

import 'package:winpay/global/global.dart';
import 'package:winpay/model/chat/chat_message.dart';
import 'package:winpay/model/chat/chat_user.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> messages = [];
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  Map<String, ImageProvider> avatarCache = {};

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  void _fetchMessages() async {
    final token = Global.token;
    final response = await http.get(
      Uri.parse('${AppEnv.baseURL}consumer/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        messages = data.map((message) => ChatMessage.fromJson(message)).toList();
      });
    } else {
      throw Exception('Failed to load messages');
    }
  }

  void _sendMessage() {
    if (messageController.text.isNotEmpty) {
      final messageText = messageController.text;

      setState(() {
        messages.add(ChatMessage(
          id: messages.length,
          senderId: '1002', // Thay đổi ID này cho phù hợp
          receiptId: '303', // Thay đổi ID này cho phù hợp
          message: messageText,
          read: false,
          chatId: 1,
          createdDate: DateTime.now().toIso8601String(),
          senderName: 'David Mai',
          receiptName: 'Admin',
          status: 'SENDER',
        ));
        messageController.clear();
      });

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      _sendMessageToAPI(messageText);
    }
  }

  void _sendMessageToAPI(String messageText) async {
    final token = Global.token;
    final response = await http.post(
      Uri.parse('${AppEnv.baseURL}consumer/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'message': messageText,
      }),
    );

    if (response.statusCode != 204) {
      // Xử lý lỗi nếu cần thiết
      print('Failed to send message');
    }
  }

  Future<ImageProvider> _getAvatar(String userId) async {
    if (avatarCache.containsKey(userId)) {
      return avatarCache[userId]!;
    } else {
      final user = await fetchChatUser(userId);
      final avatarImage = await fetchAvatarImage(user.avatar);
      avatarCache[userId] = avatarImage;
      return avatarImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with admin'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                return FutureBuilder<ImageProvider>(
                  future: _getAvatar(messages[index].senderId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildMessage(messages[index], null);
                    } else if (snapshot.hasError) {
                      return _buildMessage(messages[index], null);
                    } else {
                      return _buildMessage(messages[index], snapshot.data);
                    }
                  },
                );
              },
            ),
          ),
          _buildMessageInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message, ImageProvider? avatar) {
    bool isSender = message.status == 'SENDER';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (!isSender) // Avatar of the recipient
            CircleAvatar(
              child: const Icon(Icons.person),
              backgroundColor: Colors.grey.shade500,
            ),
          if (!isSender) // Add spacing between avatar and message
            const SizedBox(width: 8.0),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: isSender ? Colors.green : Colors.blue,
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(12.0),
              child: Text(
                message.message,
                style: const TextStyle(color: Colors.white),
                maxLines: null, // Allow the text to wrap
              ),
            ),
          ),
          if (isSender) // Add spacing between message and avatar
            const SizedBox(width: 8.0),
          if (isSender) // Avatar of the sender
            CircleAvatar(
              backgroundImage: avatar,
              backgroundColor: Colors.grey,
            ),
        ],
      ),
    );
  }


  Widget _buildMessageInputArea() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  hintText: 'Enter your message...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<ChatUser> fetchChatUser(String userId) async {
  final token = Global.token;
  final response = await http.get(
    Uri.parse('${AppEnv.baseURL}consumer/profiles'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    return ChatUser.fromJson(json.decode(utf8.decode(response.bodyBytes)));
  } else {
    throw Exception('Failed to load user');
  }
}


Future<ImageProvider> fetchAvatarImage(String avatar) async {
  final token = Global.token;
  final response = await http.get(
    Uri.parse('${AppEnv.baseURL}consumer/download/$avatar'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    return MemoryImage(response.bodyBytes);
  } else {
    throw Exception('Failed to load avatar image');
  }
}
