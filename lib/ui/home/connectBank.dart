import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/env/app_env.dart';
import 'package:winpay/global/http_helper.dart';
import '../../global/global.dart';
import 'navigationBar.dart';

class Bank {
  final int id;
  final String code;
  final String name;
  final String logo;

  Bank({required this.id, required this.code, required this.name, required this.logo});

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      logo: json['logo'],
    );
  }
}

class BankAccountCreationScreen extends StatefulWidget {
  const BankAccountCreationScreen({super.key});

  @override
  _BankAccountCreationScreenState createState() => _BankAccountCreationScreenState();
}

class _BankAccountCreationScreenState extends State<BankAccountCreationScreen> {
  Future<List<Bank>>? _banks;
  List<Bank>? _bankDataAfterAPI;
  final TextEditingController _bankCodeController = TextEditingController();
  final TextEditingController _filterResultsController = TextEditingController();
  String? _selectedBankCode;
  String? _selectedBankName;
  List<Bank>? _filteredBankData;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _banks = fetchBanks();
  }

  @override
  void dispose() {
    _bankCodeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<List<Bank>> fetchBanks() async {
    final String apiUrl = '${AppEnv.baseURL}consumer/bank/all';
    final token = Global.token;
    List<Bank> banks;
    List<dynamic>? response;

    try {
      response = await HttpHelper.invokeHttpList(Uri.parse(apiUrl), RequestType.get, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      }, body: null);
    } catch (e) {
      debugPrint("Failed to get list: $e");
    }

    if (response == null) {
      return [];
    }

    banks = response.map((dynamic i) => Bank.fromJson(i as Map<String, dynamic>)).toList();
    _bankDataAfterAPI = banks;
    _filteredBankData = _bankDataAfterAPI;
    return banks;
  }

  Future<void> createBankConnect(String bankBrand, String bankCode) async {
    final String apiUrl = '${AppEnv.baseURL}consumer/bank-connect';
    final token = Global.token;

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'bankBrand': bankBrand,
        'bankCode': bankCode,
      }),
    );

    if (response.statusCode == 200) {
      debugPrint("SUCCESS!");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NavigationBarScreen(0),
        ),
      );
    } else if (response.statusCode == 400) {
      print('API request successful! ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Bank already existed'),
        duration: Duration(seconds: 2),
      ));
    } else if (response.statusCode == 500) {
      print('API request successful! ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You can only create 5 bank connections'),
        duration: Duration(seconds: 2),
      ));
    } else {
      print('API request successful! ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to create bank connection'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  void _showBankSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter onSetState) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      labelText: 'Search Bank',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    onChanged: (data) {
                      onSetState(() {
                        _filteredBankData = _bankDataAfterAPI?.where((bank) {
                          final bankCode = bank.code.toLowerCase();
                          final bankName = bank.name.toLowerCase();
                          final input = data.toLowerCase();
                          return bankCode.contains(input) || bankName.contains(input);
                        }).toList();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredBankData?.length ?? 0,
                    itemBuilder: (context, index) {
                      final bank = _filteredBankData?[index];
                      return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bank?.code ?? "N/A", style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 1),
                            Text(bank?.name ?? "N/A", style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _selectedBankCode = bank?.code;
                            _selectedBankName = bank?.name;
                            _filterResultsController.text = bank?.code ?? "";
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Connect'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Bank>>(
          future: _banks,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 20),
                  const Text(
                    "Please choose a bank and fill in the bank code",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFF2C2C2C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  const Row(
                    children: [
                      Icon(Icons.security, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Advanced security measures\nEnsure safe money transfers from 01/07',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                      Text('Privacy', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  InkWell(
                    onTap: () {
                      _showBankSelectionSheet(context);
                    },
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text((_filterResultsController.text.isEmpty)
                              ? "Search Bank"
                              : _filterResultsController.text)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _bankCodeController,
                    decoration: InputDecoration(
                      hintText: 'Type bank code',
                      labelText: 'Bank code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Debug statements to check the values
                      print('Selected Bank Code: $_selectedBankCode');
                      print('Entered Bank Code: ${_bankCodeController.text}');
                      print('Selected Bank Name: $_selectedBankName');

                      if (_selectedBankCode != null && _bankCodeController.text.isNotEmpty) {
                        createBankConnect(_filterResultsController.text, _bankCodeController.text);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please choose a bank and bank code'),
                          duration: Duration(seconds: 2),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'SUBMIT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("${snapshot.error}"),
              );
            }
            return Container(); // Will not be reached
          },
        ),
      ),
    );
  }
}
