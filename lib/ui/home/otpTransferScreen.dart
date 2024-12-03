import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/env/app_env.dart';
import 'package:winpay/ui/home/navigationBar.dart';

import '../../global/global.dart';

class OtpTransferScreen extends StatefulWidget {
  const OtpTransferScreen({super.key});

  @override
  State<OtpTransferScreen> createState() => _OtpTransferScreenState();
}

class _OtpTransferScreenState extends State<OtpTransferScreen> {
  final TextEditingController _otpInput = TextEditingController();
  bool sendMoneyResults = false;
  bool _isLoading = false;

  Future<bool> sendValidation(String otp) async {
    setState(() {
      _isLoading = true;
    });

    final url =
        '${AppEnv.baseURL}consumer/wallet/transfer-money';
    final token = Global.token;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "moneyAdd": Global.transferMoneyRequest.moneyAdd,
          "email": Global.transferMoneyRequest.email,
          "otp": otp,
          "description": Global.transferMoneyRequest.description
        }),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      setState(() {
        _isLoading = false;
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
        _isLoading = false;
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();  // Dismiss the keyboard
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
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
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        FocusScope.of(context).unfocus();  // Dismiss the keyboard
                      },
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
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
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
