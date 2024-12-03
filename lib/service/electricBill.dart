import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/env/app_env.dart';
import 'package:winpay/service/otp/otpElectricBillScreen.dart';

import '../global/global.dart';

class ElectricityBillScreen extends StatefulWidget {
  const ElectricityBillScreen({super.key});

  @override
  _ElectricityBillScreenState createState() => _ElectricityBillScreenState();
}

class _ElectricityBillScreenState extends State<ElectricityBillScreen> {
  final String apiUrl = '${AppEnv.baseURL}consumer/electric-bill';
  final String payInitUrl = '${AppEnv.baseURL}consumer/electric-bill/pay-init';

  // Define nullable variables to hold fetched data
  int? id;
  DateTime? createdDate;
  DateTime? paymentDate;
  double? price;
  String? companyName;
  bool? isPaid;
  String? avatarUrl;
  bool isProcessingPayment = false;

  Future<void> fetchData() async {
    final token = Global.token;
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        setState(() {
          id = jsonData['id'];
          createdDate = DateTime.parse(jsonData['createdDate']);
          paymentDate = jsonData['paymentDate'] != null ? DateTime.parse(jsonData['paymentDate']) : null;
          price = jsonData['price'].toDouble();
          companyName = jsonData['companyName'];
          isPaid = jsonData['isPay'];
          avatarUrl = '${AppEnv.baseURL}consumer/public/logo/${jsonData['avatarCompany']}';
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error gracefully (show error message, retry logic, etc.)
    }
  }

  Future<void> handlePayment() async {
    setState(() {
      isProcessingPayment = true; // Set state to indicate payment processing
    });

    final token = Global.token;
    try {
      final response = await http.post(
        Uri.parse(payInitUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 204) {
        // Payment successful
        setState(() {
          isPaid = true; // Update payment status
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OtpElectricScreen()),
        );
      } else if (response.statusCode == 400) {
        // Show dialog if payment was already done
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("You've Already Paid"),
            content: const Text("This bill has already been paid."),
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
      } else if (response.statusCode == 500) {
        // Show dialog if payment was already done
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Not enough money"),
            content: const Text("Your wallet is not enough money to pay."),
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
      } else {
        throw Exception('Failed to initiate payment');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error gracefully (show error message, retry logic, etc.)
    } finally {
      setState(() {
        isProcessingPayment = false; // Reset state after payment attempt
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electricity Bill'),
        backgroundColor: Colors.green,
      ),
      body: id == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.lightGreen[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(),
            _buildInfoRow('ID', id.toString()),
            _buildInfoRow('Billing Month', '${createdDate!.month}/${createdDate!.year}'),
            _buildPaymentDateRow(),
            _buildInfoRow('Price', '${price.toString()} VND'),
            _buildInfoRow('Company Name', companyName!),
            _buildPaymentStatusRow(),
            const Spacer(), // To center the payment button
            _buildPaymentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return avatarUrl != null
        ? Center(
      child: Image.network(
        avatarUrl!,
        height: 200,
        width: 200,
        fit: BoxFit.contain,
      ),
    )
        : const SizedBox.shrink();
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPaymentDateRow() {
    bool isPaid = paymentDate != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isPaid ? '${paymentDate!.day}/${paymentDate!.month}/${paymentDate!.year}' : 'Not paid',
          style: TextStyle(
            fontSize: 18,
            color: isPaid ? Colors.blue : Colors.red,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPaymentStatusRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isPaid! ? 'Paid' : 'Not Paid',
          style: TextStyle(
            fontSize: 18,
            color: isPaid! ? Colors.blue : Colors.red,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPaymentButton() {
    return Container(
      width: double.infinity, // Ensure button takes full width
      padding: const EdgeInsets.symmetric(vertical: 16.0), // Button padding
      child: ElevatedButton(
        onPressed: isProcessingPayment ? null : (

            ) => handlePayment(),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
          padding: const EdgeInsets.all(20.0), // Button padding
        ),
        child: isProcessingPayment
            ? const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )
            : const Text('PAYMENT'),
      ),
    );
  }
}
