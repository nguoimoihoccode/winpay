import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/env/app_env.dart';
import 'package:winpay/ui/home/navigationBar.dart';
import '../global/global.dart';
import 'package:intl/intl.dart';
import 'package:animated_card/animated_card.dart';

class NotificationDetailScreen extends StatefulWidget {
  final int notificationId;

  const NotificationDetailScreen({super.key, required this.notificationId});

  @override
  _NotificationDetailScreenState createState() => _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  Map<String, dynamic>? notificationDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotificationDetail();
  }

  Future<void> fetchNotificationDetail() async {
    final token = Global.token;
    final response = await http.get(
      Uri.parse('${AppEnv.baseURL}consumer/notification/${widget.notificationId}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        notificationDetail = json.decode(utf8.decode(response.bodyBytes));
        isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String dateStr) {
    final DateTime dateTime = DateTime.parse(dateStr);
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Detail'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NavigationBarScreen(2)),
            );
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationDetail == null
          ? const Center(child: Text('Không thể tải thông báo'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedCard(
              direction: AnimatedCardDirection.top,
              initDelay: const Duration(milliseconds: 0),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  leading: const Icon(Icons.title, color: Colors.green),
                  title: Text(
                    notificationDetail!['title'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedCard(
              direction: AnimatedCardDirection.left,
              initDelay: const Duration(milliseconds: 200),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  leading: const Icon(Icons.description, color: Colors.blue),
                  title: Text(
                    notificationDetail!['content'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedCard(
              direction: AnimatedCardDirection.right,
              initDelay: const Duration(milliseconds: 400),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  leading: const Icon(Icons.date_range, color: Colors.orange),
                  title: Text(
                    'Was sent on: ${formatDate(notificationDetail!['createdDate'])}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
