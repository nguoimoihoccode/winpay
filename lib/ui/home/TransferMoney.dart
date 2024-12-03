import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/env/app_env.dart';
import 'package:winpay/ui/home/otpTransferScreen.dart';
import 'dart:convert';

import '../../global/global.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String _codeWallet = '';
  double _totalMoney = 0.0;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchWalletData();
    _emailFocusNode.addListener(_onEmailFocusChange);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _accountNumberController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> fetchWalletData() async {
    setState(() {
      _isLoading = true;
    });

    final token = Global.token;
    final response = await http.get(
      Uri.parse('${AppEnv.baseURL}consumer/wallet/my-wallet'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _codeWallet = data['codeWallet'];
        _totalMoney = data['totalMoney'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load wallet data');
    }
  }

  void _onEmailFocusChange() {
    if (!_emailFocusNode.hasFocus) {
      _fetchAccountNumber(_emailController.text);
    }
  }

  Future<void> _fetchAccountNumber(String email) async {
    setState(() {
      _isLoading = true;
    });

    final token = Global.token;
    final response = await http.get(
      Uri.parse('${AppEnv.baseURL}consumer/profiles/$email'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _accountNumberController.text = data['accountNumber'];
        _isLoading = false;
      });
    } else if (response.statusCode == 400) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("Can't find this wallet user");
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load profile data');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
        );
      },
    );
  }

  Future<void> _submitTransfer() async {
    setState(() {
      _isLoading = true;
    });

    final token = Global.token;
    final moneyAdd = double.tryParse(_amountController.text) ?? 0;
    final email = _emailController.text;
    final description = _descriptionController.text;

    Global.transferMoneyRequest.email = email;
    Global.transferMoneyRequest.description = description;
    Global.transferMoneyRequest.moneyAdd = moneyAdd;

    final response = await http.post(
      Uri.parse('${AppEnv.baseURL}consumer/wallet/init-transfer'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'moneyAdd': moneyAdd,
        'email': email
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 204) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OtpTransferScreen()),
      );
    } else if(response.statusCode == 500) {
      _showErrorDialog("Not enough money");
    } else if(response.statusCode == 400) {
      _showErrorDialog("Wallet of receiver was limit");
    } else {
      _showErrorDialog("Failed to initiate transfer");
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Money'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Select Source Account',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: padding),
                        Container(
                          padding: EdgeInsets.all(padding),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.credit_card, color: Colors.green),
                              SizedBox(width: padding),
                              Text(_codeWallet.isNotEmpty ? _codeWallet : 'Loading...'),
                            ],
                          ),
                        ),
                        SizedBox(height: padding),
                        const Text(
                          'Available Balance',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: padding),
                        Text(_totalMoney != 0.0 ? '${_totalMoney.toStringAsFixed(2)}đ' : 'Loading...'),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  TextField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Recipient Account Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _accountNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Recipient Account Number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: scanBarcode,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount to Transfer',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _submitTransfer,
                      child: const Text('SUBMIT'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
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
    );
  }

  Future<void> scanBarcode() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      debugPrint(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (barcodeScanRes.isNotEmpty && barcodeScanRes != "-1") {
      setState(() {
        _emailController.text = barcodeScanRes;
      });
    }
  }
}
