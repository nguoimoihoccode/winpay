import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:winpay/env/app_env.dart';
import '../../global/global.dart';

class BankAccount {
  final int id;
  final String bankCode;
  final double? totalMoney;
  final String createdDate;
  final String ownerId;
  final String ownerName;
  final String? walletId;
  final String logo;
  final String bankBrand;
  final String bankName;
  final String status;

  BankAccount({
    required this.id,
    required this.bankCode,
    this.totalMoney,
    required this.createdDate,
    required this.ownerId,
    required this.ownerName,
    this.walletId,
    required this.logo,
    required this.bankBrand,
    required this.bankName,
    required this.status,
  });

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(parsedDate);
  }

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    double? totalMoney;
    if (json['totalMoney'] != null) {
      if (json['totalMoney'] is String) {
        totalMoney = double.tryParse(json['totalMoney']);
      } else if (json['totalMoney'] is num) {
        totalMoney = json['totalMoney'].toDouble();
      }
    }

    return BankAccount(
      id: json['id'],
      bankCode: json['bankCode'],
      totalMoney: totalMoney,
      createdDate: json['createdDate'],
      ownerId: json['ownerId'],
      ownerName: json['ownerName'],
      walletId: json['walletId'],
      logo: json['logo'],
      bankBrand: json['bankBrand'],
      bankName: json['bankName'],
      status: json['status'],
    );
  }
}

Future<BankAccount> fetchBankDetail(int id) async {
  final String apiUrl = '${AppEnv.baseURL}consumer/bank-connect/$id';
  final token = Global.token;

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    final decodedResponse = utf8.decode(response.bodyBytes);
    return BankAccount.fromJson(jsonDecode(decodedResponse));
  } else {
    throw Exception('Failed to load bank detail');
  }
}

class BankDetailScreen extends StatelessWidget {
  final int bankId;

  const BankDetailScreen({super.key, required this.bankId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Detail'),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<BankAccount>(
        future: fetchBankDetail(bankId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No bank data found'));
          } else {
            final bankDetail = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.network(
                        '${AppEnv.baseURL}consumer/public/logo/${bankDetail.logo}',
                        width: 100,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bank Name: ${bankDetail.bankName}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Bank Code: ${bankDetail.bankCode}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Total Money: ${bankDetail.totalMoney != null ? '\$${bankDetail.totalMoney!.toStringAsFixed(2)}' : '0'}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Status: ${bankDetail.status}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Owner Name: ${bankDetail.ownerName}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Created Date: ${bankDetail._formatDate(bankDetail.createdDate)}         \t                       \t ',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
