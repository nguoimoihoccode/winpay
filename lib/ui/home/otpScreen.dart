import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/env/app_env.dart';
import 'package:winpay/ui/home/navigationBar.dart';

import '../../global/global.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpInput = TextEditingController();
  bool sendMoneyResults = false;
  bool _isLoading = false; // Add this line

  Future<bool> sendValidation(String otp) async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final url =
        '${AppEnv.baseURL}consumer/wallet/add-money/into-wallet';
    final token = Global.token;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'bankId': Global.moneyRequest.bankId,
          'moneyAdd': Global.moneyRequest.moneyAdd,
          'otp': otp,
        }),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      setState(() {
        _isLoading = false; // Stop loading
      });

      if (response.statusCode == 500) {
        showErrorDialog('Not enough money. Please try again.');
        sendMoneyResults = false;
        return false;
      }

      debugPrint("CALLED VALIDATION SUCCESS!");
      sendMoneyResults = true;
      return true;
    } catch (e) {
      debugPrint("Failed to send validation request: $e");
      setState(() {
        _isLoading = false; // Stop loading
      });
      sendMoneyResults = false;
      return false;
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Otp Input"),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const SizedBox(height: 60.0),
                const Text(
                  "We have sent a 6-digit confirmation code to your email number",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF2C2C2C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: _otpInput,
                  decoration: const InputDecoration(
                    labelText: 'Enter OTP',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 100.0), // Adjust size as needed
                const Icon(
                  Icons.attach_money_outlined,
                  size: 300,
                  color: Colors.green,
                ),
              ],
            ),
          ),
          if (_isLoading) // Show loading indicator when _isLoading is true
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: InkWell(
          onTap: () async {
            if (_otpInput.text.isEmpty) {
              showErrorDialog('Please enter the OTP.');
              return;
            }

            sendMoneyResults = await sendValidation(_otpInput.text);
            if (!sendMoneyResults) {
              showErrorDialog('Not enough money. Please try again.');
              return;
            }

            // Xử lý khi gửi tiền thành công
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('SEND MONEY SUCCESS'),
                  content: const Text('MONEY SEND SUCCESS!'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NavigationBarScreen(0)),
                        );
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 45),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                "SUBMIT",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
