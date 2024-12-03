import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/env/app_env.dart';
import '../global/global.dart';
import 'notificationDetail.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  List notifications = [];
  bool isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchNotifications({String? keyword}) async {
    final token = Global.token;
    final url = Uri.parse('${AppEnv.baseURL}consumer/notification');
    final queryParams = {'keyword': keyword ?? ''}; // Add keyword to query params if available

    final response = await http.get(url.replace(queryParameters: queryParams), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      setState(() {
        notifications = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách thông báo'),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        actions: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search notifications...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                style: const TextStyle(color: Colors.black),
                onSubmitted: (keyword) {
                  setState(() {
                    isLoading = true;
                  });
                  fetchNotifications(keyword: keyword);
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchNotifications(keyword: _searchController.text);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
        opacity: _animation,
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            final bool isRead = notification['read'] == true;
            final createdDate = DateTime.parse(notification['createdDate']);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'],
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Được gửi vào: ${createdDate.day}/${createdDate.month}/${createdDate.year}, ${createdDate.hour}:${createdDate.minute}:${createdDate.second}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  leading: Icon(
                    Icons.notifications,
                    color: isRead ? Colors.grey : Colors.blue,
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationDetailScreen(notificationId: notification['id']),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isLoading = true;
          });
          fetchNotifications();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.refresh),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked, // Adjust the position of the FAB
    );
  }
}
