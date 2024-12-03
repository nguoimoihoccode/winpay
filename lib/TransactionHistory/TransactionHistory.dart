import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/TransactionHistory/transactionDetail.dart';
import 'package:winpay/env/app_env.dart';
import 'dart:convert';

import '../global/global.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  late Future<List<Transaction>> futureTransactions;
  late String currentFilter = ''; // Biến lưu trữ loại hiện tại đang được lọc
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureTransactions = fetchTransactions();
  }

  Future<List<Transaction>> fetchTransactions({String? type, String? keyword}) async {
    final token = Global.token;
    final url = Uri.parse('${AppEnv.baseURL}consumer/transaction-history');
    final Map<String, String> queryParams = {};

    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }
    if (keyword != null && keyword.isNotEmpty) {
      queryParams['keyword'] = keyword;
    }

    final response = await http.get(url.replace(queryParameters: queryParams), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((transaction) => Transaction.fromJson(transaction)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Số lượng tab, tương ứng với số loại giao dịch
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green,
          title: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search transactions...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    style: const TextStyle(color: Colors.black),
                    onSubmitted: (keyword) {
                      setState(() {
                        futureTransactions = fetchTransactions(
                          type: currentFilter.isNotEmpty ? currentFilter : null,
                          keyword: keyword,
                        );
                      });
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  setState(() {
                    futureTransactions = fetchTransactions(
                      type: currentFilter.isNotEmpty ? currentFilter : null,
                      keyword: _searchController.text,
                    );
                  });
                },
              ),
            ],
          ),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Recharge'),
              Tab(text: 'Transfer'),
              Tab(text: 'Service'),
            ],
            onTap: (index) {
              // Xử lý khi người dùng chọn tab
              switch (index) {
                case 0:
                  setState(() {
                    currentFilter = ''; // Lọc tất cả
                    futureTransactions = fetchTransactions(keyword: _searchController.text);
                  });
                  break;
                case 1:
                  setState(() {
                    currentFilter = 'RECHARGE'; // Lọc theo loại RECHARGE
                    futureTransactions = fetchTransactions(
                      type: 'RECHARGE',
                      keyword: _searchController.text,
                    );
                  });
                  break;
                case 2:
                  setState(() {
                    currentFilter = 'TRANSFER_MONEY'; // Lọc theo loại TRANSFER_MONEY
                    futureTransactions = fetchTransactions(
                      type: 'TRANSFER_MONEY',
                      keyword: _searchController.text,
                    );
                  });
                  break;
                case 3:
                  setState(() {
                    currentFilter = 'USE_SERVICE'; // Lọc theo loại USE_SERVICE
                    futureTransactions = fetchTransactions(
                      type: 'USE_SERVICE',
                      keyword: _searchController.text,
                    );
                  });
                  break;
                case 4:
                  setState(() {
                    currentFilter = 'WITHDRAW'; // Lọc theo loại USE_SERVICE
                    futureTransactions = fetchTransactions(
                      type: 'USE_SERVICE',
                      keyword: _searchController.text,
                    );
                  });
                  break;
                default:
              }
            },
          ),
        ),
        body: FutureBuilder<List<Transaction>>(
          future: futureTransactions,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight + 35.0), // Thêm 20 đơn vị khoảng trống
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: index.isEven ? Colors.transparent : Colors.grey[200],
                    child: TransactionItem(transaction: snapshot.data![index]),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("${snapshot.error}"));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
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
class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    String description;

    if (transaction.type == 'RECHARGE') {
      icon = Icons.account_balance_wallet;
      iconColor = Colors.red;
      description =
      'Refill into wallet from bank ${transaction.bankName}: \n +${transaction.totalMoney}\$';
    } else if (transaction.type == 'TRANSFER_MONEY') {
      icon = Icons.swap_horiz;
      iconColor = Colors.blue;
      description =
      'Transfer money to ${transaction.receiverName}: \n -${transaction.totalMoney}\$';
    } else if (transaction.type == 'USE_SERVICE') {
      icon = Icons.design_services;
      iconColor = Colors.green;
      description =
      'Use service ${transaction.description}: ${transaction.totalMoney}\$';
    } else if (transaction.type == 'GET_MONEY') {
      icon = Icons.receipt;
      iconColor = Colors.greenAccent;
      description =
      'Receiver money from ${transaction.senderName}: \n +${transaction.totalMoney}\$';
    }
    else if (transaction.type == 'WITHDRAW') {
      icon = Icons.account_balance_wallet_outlined;
      iconColor = Colors.greenAccent;
      description =
      'Withdraw to ${transaction.bankName}: \n +${transaction.totalMoney}\$';
    }else {
      icon = Icons.help_outline;
      iconColor = Colors.grey;
      description = 'Unknown transaction type';
    }

    DateTime dateTime = DateTime.parse(transaction.createdDate);
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        description,
        style: const TextStyle(color: Colors.black),
      ),
      subtitle: Text(formattedDate),
      trailing: Text(
        '${transaction.totalMoney}đ',
        style: TextStyle(
          color: transaction.type == 'RECHARGE' ? Colors.green : Colors.red,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailScreen(transactionId: transaction.id),
          ),
        );
      },
    );
  }
}


