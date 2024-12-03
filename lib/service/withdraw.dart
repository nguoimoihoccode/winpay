import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/env/app_env.dart';
import 'package:winpay/ui/home/navigationBar.dart';
import 'package:winpay/term.dart';

import '../global/global.dart'; // Ensure you have the term.dart file with the Term class defined.

class WithdrawMainScreen extends StatefulWidget {
  const WithdrawMainScreen({super.key});

  @override
  _WithdrawMainScreenState createState() => _WithdrawMainScreenState();
}

class _WithdrawMainScreenState extends State<WithdrawMainScreen> {
  double currentBalance = 0.0;
  TextEditingController withdrawAmountController = TextEditingController();
  String selectedBankId = ''; // Initialize with selected bankId
  bool isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final token = Global.token;
      final response = await http.get(
        Uri.parse('${AppEnv.baseURL}consumer/wallet/my-money'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          currentBalance = double.parse(jsonData['totalMoney'].toString());
        });
      } else {
        throw Exception('Failed to load balance');
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error as needed
    }
  }

  Future<List<BankOption>> fetchBankOptions() async {
    try {
      final token = Global.token;
      final response = await http.get(
        Uri.parse('${AppEnv.baseURL}consumer/bank-connect/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<BankOption> bankOptions =
        data.map((json) => BankOption.fromJson(json)).toList();
        return bankOptions;
      } else {
        throw Exception('Failed to load bank options');
      }
    } catch (e) {
      print('Error fetching bank options: $e');
      throw e;
    }
  }

  Future<void> withdrawMoney(String bankId, double withdrawAmount) async {
    setState(() {
      isLoading = true; // Start loading indicator
    });

    try {
      final token = Global.token;
      final url =
      Uri.parse('${AppEnv.baseURL}consumer/wallet/withdraw-money');
      final body = jsonEncode({
        'bankId': bankId,
        'withdrawMoney': withdrawAmount,
      });

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode == 204) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WithdrawMainScreen()),
              (Route<dynamic> route) => false,
        );
        // Successful withdrawal, handle success scenario (e.g., show a success message)
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Withdrawal Successful'),
              content: const Text('Your withdrawal request has been processed.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // You can perform additional actions after withdrawal here
                  },
                ),
              ],
            );
          },
        );
      } else if (response.statusCode == 400) {
        // Successful withdrawal, handle success scenario (e.g., show a success message)
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Withdrawal Failed'),
              content: const Text('Your Wallet not money enough.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // You can perform additional actions after withdrawal here
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Handle API errors or non-204 status codes
        throw Exception('Failed to withdraw money');
      }
    } catch (e) {
      print('Error withdrawing money: $e');
      // Handle error as needed
    } finally {
      setState(() {
        isLoading = false; // Stop loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const NavigationBarScreen(0)),
                  (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSecurityNotification(context),
              const SizedBox(height: 16),
              _buildWithdrawFromSection(),
              const SizedBox(height: 16),
              _buildBankSelectionSection(),
              const SizedBox(height: 16),
              _buildWithdrawButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityNotification(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.security, color: Colors.green),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Advanced security measures\nEnsure safe money transfers from 01/07',
              style: TextStyle(color: Colors.green),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Term()),
              );
            },
            child: const Text('Learn More'),
            style: TextButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawFromSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Withdraw from',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.green,
                child: Text('WP', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Winpay Wallet', style: TextStyle(fontSize: 16)),
                    Text(
                      '${currentBalance.toStringAsFixed(2)}đ', // Display currentBalance here
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: withdrawAmountController,
          decoration: const InputDecoration(
            labelText: 'Amount to Withdraw',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildBankSelectionSection() {
    return FutureBuilder<List<BankOption>>(
      future: fetchBankOptions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No bank options available');
        } else {
          List<BankOption> bankOptions = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'To Bank',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                itemCount: bankOptions.length,
                itemBuilder: (context, index) {
                  return _buildBankOption(
                    bankOptions[index].bankName,
                    bankOptions[index].bankCode,
                    bankOptions[index].id,
                    bankOptions[index].isSelected,
                    onSelect: () {
                      setState(() {
                        selectedBankId = bankOptions[index].id; // Update selected bankId
                      });
                    },
                  );
                },
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildBankOption(String bankName, String bankCode, String bankid, bool isSelected, {required VoidCallback onSelect}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bankName, style: const TextStyle(fontSize: 16)),
                Text(bankCode, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          Radio<String>(
            value: bankid,
            groupValue: selectedBankId,
            onChanged: (value) {
              setState(() {
                selectedBankId = value ?? ''; // Update selectedBankId when radio button is selected
              });
              onSelect(); // Call onSelect to update isSelected or perform additional actions
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawButton() {
    return Center(
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
          double withdrawAmount = double.tryParse(withdrawAmountController.text) ?? 0.0;
          if (selectedBankId.isNotEmpty && withdrawAmount > 0) {
            withdrawMoney(selectedBankId, withdrawAmount);
          } else {
            // Handle invalid withdrawal attempt (e.g., show error message)
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Invalid Withdrawal'),
                  content: const Text('Please select a bank and enter a valid withdrawal amount.'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: isLoading
            ? const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )
            : const Text(
          'Withdraw',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class BankOption {
  final String id;
  final String bankName;
  final String bankCode;
  final bool isSelected;

  BankOption({
    required this.id,
    required this.bankName,
    required this.bankCode,
    required this.isSelected,
  });

  factory BankOption.fromJson(Map<String, dynamic> json) {
    return BankOption(
      id: json['id'].toString(),
      bankName: json['bankBrand'],
      bankCode: json['bankCode'],
      isSelected: false, // Initialize isSelected based on your logic
    );
  }
}
