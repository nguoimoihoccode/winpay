import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/env/app_env.dart';
import 'dart:convert';

import '../../global/global.dart';
import '../SavingWallet.dart';

class DepositWithdrawScreen extends StatefulWidget {
  const DepositWithdrawScreen({super.key});

  @override
  _DepositWithdrawScreenState createState() => _DepositWithdrawScreenState();
}

class _DepositWithdrawScreenState extends State<DepositWithdrawScreen> {
  double currentBalance = 0.0; // Khởi tạo giá trị ban đầu cho currentBalance
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData(); // Gọi hàm để lấy dữ liệu từ API khi StatefulWidget được khởi tạo
  }

  // Hàm để gửi yêu cầu GET đến API và cập nhật currentBalance từ response
  Future<void> fetchData() async {
    final token = Global.token;
    final response = await http.get(Uri.parse('${AppEnv.baseURL}consumer/wallet/my-money'),
      headers: {
        'Authorization': 'Bearer $token',
      },);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        currentBalance = jsonData['totalMoney'];
      });
    } else {
      throw Exception('Failed to load balance');
    }
  }

  // Hàm để cập nhật giá trị vào TextField khi nhấn nút
  void updateAmount(String value) {
    setState(() {
      amountController.text = value;
    });
  }

  // Hàm để gọi API để thêm tiền vào ví
  Future<void> addMoneyToWallet(double amount) async {
    final token = Global.token;
    final url = Uri.parse('${AppEnv.baseURL}consumer/saving-wallet/add-money');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'moneyAdd': amount,
      }),
    );

    if (response.statusCode == 204) {
      // Xử lý response thành công
      showSuccessDialog();

      print('Money added successfully');
      // Thực hiện các hành động cần thiết sau khi thêm tiền vào ví
    }
    else if(response.statusCode==400) {
      showErrorDialog();
    }
    else if(response.statusCode ==500) {
      show500ErrorDialog();
    }
    else {
      // Xử lý lỗi khi gọi API
      throw Exception('Failed to add money');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Handle more button
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Current Balance: \$${currentBalance.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.lock, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Saving Wallet Limit: \$100,000',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount to Deposit',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    updateAmount('100000');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Set background color here
                  ),
                  child: const Text('\$100,000',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    updateAmount('500000');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Set background color here
                  ),
                  child: const Text('\$500,000',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    updateAmount('1000000');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Set background color here
                  ),
                  child: const Text('\$1,000,000',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  amountController.text = currentBalance.toStringAsFixed(2);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Set background color here
              ),
              child: const Text('Use WinPay Balance',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
            ),
            const Spacer(),
            const Divider(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Lấy giá trị số tiền cần nạp từ amountController
                final amount = double.tryParse(amountController.text);
                if (amount != null) {
                  addMoneyToWallet(amount);
                } else {
                  // Xử lý khi giá trị nhập vào không hợp lệ
                  print('Invalid amount');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Set background color here
              ),
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: const Text('Continue',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ADD MONEY TO SAVING WALLET SUCCESS'),
          content: const Text('YOU COMPLETE ADD MONEY TO SAVING WALLET SUCCESS'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SavingWalletScreen()),
                      (Route<dynamic> route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ADD MONEY FAILED'),
          content: const Text('YOU ARE NOT ENOUGH MONEY'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const DepositWithdrawScreen()),
                      (Route<dynamic> route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  void show500ErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ADD MONEY FAILED'),
          content: const Text('YOUR SAVING WALLET LIMIT MONEY'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const DepositWithdrawScreen()),
                      (Route<dynamic> route) => false,
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
