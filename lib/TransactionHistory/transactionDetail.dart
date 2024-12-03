import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/env/app_env.dart';
import 'dart:convert';

import '../ui/chat/chatScreen.dart';
import '../global/global.dart';

class TransactionDetailScreen extends StatefulWidget {
  final int transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  _TransactionDetailScreenState createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late Future<Transaction> futureTransaction;

  @override
  void initState() {
    super.initState();
    futureTransaction = fetchTransactionDetails(widget.transactionId);
  }

  Future<Transaction> fetchTransactionDetails(int id) async {
    final token = Global.token;
    final url = Uri.parse('${AppEnv.baseURL}consumer/transaction-history/$id');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return Transaction.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load transaction details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<Transaction>(
        future: futureTransaction,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final transaction = snapshot.data!;
            DateTime dateTime = DateTime.parse(transaction.createdDate);
            String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Padding(
                        key: ValueKey<int>(transaction.id),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _buildDetailRow(Icons.info, 'Transaction ID', transaction.id.toString()),
                            _buildDetailRow(Icons.date_range, 'Date', formattedDate),
                            _buildDetailRow(Icons.category, 'Type', transaction.type),
                            if (transaction.bankName != null) _buildDetailRow(Icons.account_balance, 'Bank', transaction.bankName!),
                            if (transaction.receiverName != null) _buildDetailRow(Icons.person, 'Receiver', transaction.receiverName!),
                            if (transaction.senderName != null) _buildDetailRow(Icons.person_outline, 'Sender', transaction.senderName!),
                            _buildDetailRow(Icons.monetization_on, 'Amount', '${transaction.totalMoney}đ', isAmount: true),
                            if (transaction.description != null) _buildDetailRow(Icons.description, 'Description', transaction.description!),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatScreen()),
                      );
                    },
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Contact Support'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text("No transaction details available"));
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: isAmount ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class Transaction {
  final int id;
  final String? bankName;
  final String createdDate;
  final String? receiverName;
  final String? senderName;
  final double totalMoney;
  final String? description;
  final String type;

  Transaction({
    required this.id,
    required this.bankName,
    required this.createdDate,
    required this.receiverName,
    required this.senderName,
    required this.totalMoney,
    required this.description,
    required this.type,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      bankName: json['bankName'],
      createdDate: json['createdDate'],
      receiverName: json['receiverName'],
      senderName: json['senderName'],
      totalMoney: json['totalMoney'],
      description: json['description'],
      type: json['type'],
    );
  }
}
