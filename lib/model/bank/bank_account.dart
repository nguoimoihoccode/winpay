import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:winpay/env/app_env.dart';
import 'package:winpay/global/global.dart';

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