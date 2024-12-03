import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/env/app_env.dart';
import 'package:winpay/ui/home/navigationBar.dart';
import 'dart:convert';

import '../global/global.dart';
import 'depositAndWithDraw/WithdrawSavingWallet.dart';
import 'depositAndWithDraw/depositToSavingWallet.dart';

class SavingWalletScreen extends StatefulWidget {
  const SavingWalletScreen({super.key});

  @override
  _SavingWalletScreenState createState() => _SavingWalletScreenState();
}

class _SavingWalletScreenState extends State<SavingWalletScreen> {
  final token = Global.token;

  Future<Map<String, dynamic>> fetchSavingWalletData() async {
    final response = await http.get(
      Uri.parse('${AppEnv.baseURL}consumer/saving-wallet'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> receiveMoney() async {
    final response = await http.post(
      Uri.parse('${AppEnv.baseURL}consumer/saving-wallet/receive-money'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 204) {
      // Handle success response
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SavingWalletScreen()),
            (Route<dynamic> route) => false,
      );

      setState(() {
        fetchSavingWalletData();
      });
    } else {
      throw Exception('Failed to receive money');
    }
  }


  void showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Terms and Benefits of WinPay Savings Wallet'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interest Rate:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'The WinPay Savings Wallet generates x% interest annually. This rate may be adjusted as per WinPay company policies.',
                ),
                SizedBox(height: 10),
                Text(
                  'Term and Conditions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'The Savings Wallet has applicable terms and conditions, including specific details on deposit time, withdrawal, and other conditions.',
                ),
                SizedBox(height: 10),
                Text(
                  'Benefits:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Customers will benefit from depositing money into the WinPay Savings Wallet, including attractive interest rates and additional services such as interest notifications, data security, and customer support.',
                ),
                SizedBox(height: 10),
                Text(
                  'Risk:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Investing in the Savings Wallet may involve risks, and customers need to understand and accept the risks associated with financial markets and other factors.',
                ),
                SizedBox(height: 10),
                Text(
                  'Terms Changes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'WinPay reserves the right to adjust the terms and conditions of the WinPay Savings Wallet over time, notifying customers before implementing such changes.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NavigationBarScreen(0)),
            );
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchSavingWalletData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Money in Wallet 👁',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${data['savingMoney']}\$',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Interest received today: 0\$',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: receiveMoney,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text('Receive +${data['profit']} \$ '),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Accumulated balance ${data['totalProfit']}\$',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Interest rate up to: ${data['percentProfit']}%/year',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ActionButton(
                          icon: Icons.sync_alt,
                          label: 'Deposit',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DepositWithdrawScreen()),
                            );
                          },
                        ),
                        ActionButton(
                          icon: Icons.privacy_tip_outlined,
                          label: 'Terms',
                          onTap: showPrivacyDialog, // Call showPrivacyDialog when tapped
                        ),
                        ActionButton(
                          icon: Icons.receipt,
                          label: 'Withdraw',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const WithdrawScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey.shade100,
                    child: Row(
                      children: [
                        const Icon(Icons.card_giftcard, color: Colors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Receive money into Savings Wallet \nMoney received from transactions will automatically go into the Wallet, earning interest at ${data['percentProfit']}%/year.',
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add more sections as needed
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.greenAccent.shade100,
            child: Icon(
              icon,
              size: 30,
              color: const Color(0xFF32513B),
            ),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
