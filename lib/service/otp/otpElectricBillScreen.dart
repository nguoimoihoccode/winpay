import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/env/app_env.dart';
import 'package:winpay/ui/home/navigationBar.dart';
import '../../global/global.dart';

class OtpElectricScreen extends StatefulWidget {
  const OtpElectricScreen({super.key});

  @override
  State<OtpElectricScreen> createState() => _OtpElectricScreenState();
}

class _OtpElectricScreenState extends State<OtpElectricScreen> {
  final TextEditingController _otpInput = TextEditingController();
  bool sendMoneyResults = false;
  bool _isLoading = false;

  Future<void> sendValidation(String otp) async {
    final url = '${AppEnv.baseURL}consumer/electric-bill/pay-done';
    final token = Global.token;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'otp': otp,
        }),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      Navigator.pop(context); // Đóng hộp thoại loading

      if (response.statusCode == 204) {
        showSuccessDialog();
      } else if (response.statusCode == 400) {
        showErrorDialog('Wrong OTP! Please try again.');
      } else if (response.statusCode == 500) {
        showErrorDialog('Not enough money. Please try again.');
      }
    } catch (e) {
      debugPrint("Failed to send validation request: $e");
      showErrorDialog('An error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('PAYMENT SUCCESS'),
          content: const Text('YOU COMPLETE PAYMENT ELECTRIC BILL!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const NavigationBarScreen(0)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Otp Input"),
      ),
      body: Padding(
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: InkWell(
          onTap: () async {
            if (_otpInput.text.isEmpty) {
              showErrorDialog('Please enter the OTP.');
              return;
            }

            // Hiển thị dialog loading
            setState(() {
              _isLoading = true;
            });
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return const Dialog(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Processing payment..."),
                      ],
                    ),
                  ),
                );
              },
            );

            await sendValidation(_otpInput.text);
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
