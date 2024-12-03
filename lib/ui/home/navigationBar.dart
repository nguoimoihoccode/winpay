import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:winpay/env/app_env.dart';
import 'package:winpay/mainScreen/profile_screen.dart';
import '../../TransactionHistory/TransactionHistory.dart';
import '../../global/global.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../notification/notification.dart';
import 'Dashboard.dart';

class NavigationBarScreen extends StatefulWidget {
  final int tabIndex;

  const NavigationBarScreen(this.tabIndex, {super.key});

  @override
  _NavigationBarScreenState createState() => _NavigationBarScreenState(tabIndex);
}

class UserProfile {
  final int id;
  final String email;
  final String name;
  final String phone;
  final String avatar;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      avatar: json['avatar'],
    );
  }
}

class Wallet {
  final int id;
  final String ownerId;
  final String ownerName;
  final double totalMoney;
  final String createdDate;
  final String code;
  final String codeWallet;

  Wallet({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.totalMoney,
    required this.createdDate,
    required this.code,
    required this.codeWallet,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      ownerId: json['ownerId'],
      ownerName: json['ownerName'],
      totalMoney: json['totalMoney'].toDouble(),
      createdDate: json['createdDate'],
      code: json['code'],
      codeWallet: json['codeWallet'],
    );
  }
}

class BankAccount {
  final int id;
  final String bankCode;
  final double totalMoney;
  final String createdDate;
  final String ownerId;
  final String ownerName;
  final String? walletId;
  final String logo;
  final String bankBrand;
  final String bankName;

  BankAccount({
    required this.id,
    required this.bankCode,
    required this.totalMoney,
    required this.createdDate,
    required this.ownerId,
    required this.ownerName,
    this.walletId,
    required this.logo,
    required this.bankBrand,
    required this.bankName,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    double parsedTotalMoney = json['totalMoney'] != null ? double.tryParse(json['totalMoney'].toString()) ?? 0.0 : 0.0;

    return BankAccount(
      id: json['id'],
      bankCode: json['bankCode'],
      totalMoney: parsedTotalMoney,
      createdDate: json['createdDate'],
      ownerId: json['ownerId'],
      ownerName: json['ownerName'],
      walletId: json['walletId'],
      logo: json['logo'],
      bankBrand: json['bankBrand'],
      bankName: json['bankName'],
    );
  }
}


Future<Wallet> fetchWalletData() async {
  final token = Global.token;
  final response = await http.get(
    Uri.parse('${AppEnv.baseURL}consumer/wallet/my-wallet'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return Wallet.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load wallet');
  }
}

Future<UserProfile> fetchUserProfile() async {
  final token = Global.token;
  final response = await http.get(
    Uri.parse('${AppEnv.baseURL}consumer/profiles'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return UserProfile.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load profile');
  }
}

Future<List<BankAccount>> fetchBankAccountHistory() async {
  final token = Global.token;
  final response = await http.get(
    Uri.parse('${AppEnv.baseURL}consumer/bank-connect'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    List jsonResponse = jsonDecode(response.body);
    return jsonResponse.map((data) => BankAccount.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load bank account history');
  }
}

Future<Uint8List> fetchUserAvatar(String avatar) async {
  final token = Global.token;
  final apiUrl = '${AppEnv.baseURL}consumer/download/$avatar';
  print('API URL: $apiUrl');

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw Exception('Failed to load avatar');
  }
}

class _NavigationBarScreenState extends State<NavigationBarScreen> {
  int tabIndex;
  int _selectedIndex = 0;
  late Future<UserProfile> futureUserProfile;
  late Future<Wallet> futureWallet;
  late Future<List<BankAccount>> futureBankAccountHistory;
  List<Widget>? tabs;

  _NavigationBarScreenState(this.tabIndex);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedIndex = tabIndex;
    });
    futureUserProfile = fetchUserProfile();
    futureBankAccountHistory = fetchBankAccountHistory();
    tabs = [
      const DashboardScreen(),
      const TransactionHistoryScreen(),
      const NotificationScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      tabs![_selectedIndex],
      MediaQuery.of(context).orientation == Orientation.portrait ? Align(
        alignment: Alignment.bottomCenter,
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.transparent
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(30),
                topLeft: Radius.circular(30)
              ),
              child: Container(
                padding: const EdgeInsets.only(left: 6, right: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFFD0E3E5)
                ),
                child: BottomNavigationBar(
                      items: const [
                        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.history), label: ''),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.notifications), label: ''),
                        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
                      ],
                      currentIndex: _selectedIndex,
                      selectedItemColor: Colors.green,
                      showSelectedLabels: false,
                      showUnselectedLabels: false,
                      type: BottomNavigationBarType.fixed,
                      onTap: _onItemTapped,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                    ),
              ),
            ),
          )) : Container(),
      const Align()
    ]);
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const ActionButton({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.green[100],
          child: Icon(icon, size: 30, color: Colors.green[700]),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}

class FrequentActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const FrequentActionButton({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.green[100],
          child: Icon(icon, size: 25, color: Colors.green[700]),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}

class AccountHistoryCard extends StatelessWidget {
  final String date;
  final double amount;
  final String logo;

  const AccountHistoryCard({super.key, 
    required this.date,
    required this.amount,
    required this.logo,
  });

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(
            '${AppEnv.baseURL}consumer/public/logo/$logo',
            width: 50), // Replace with your image asset
        title: Text('\$${amount.toStringAsFixed(2)}'),
        subtitle: Text(_formatDate(date)),
      ),
    );
  }
}
