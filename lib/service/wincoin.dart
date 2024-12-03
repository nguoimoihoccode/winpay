import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:winpay/env/app_env.dart';
import 'package:winpay/ui/home/navigationBar.dart';
import '../global/global.dart';

class WinCoinScreen extends StatefulWidget {
  const WinCoinScreen({super.key});

  @override
  _WinCoinScreenState createState() => _WinCoinScreenState();
}

class _WinCoinScreenState extends State<WinCoinScreen> {
  int? totalCoin;
  DateTime? lastModifiedDate;
  int? value;
  int? coinConfig;
  final TextEditingController _coinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final token = Global.token;
    final response = await http.get(
      Uri.parse('${AppEnv.baseURL}consumer/win-coin'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        totalCoin = data['totalCoin'];
        lastModifiedDate = DateTime.parse(data['lastModifiedDate']);
        value = data['value'];
        coinConfig = data['coinConfig'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _showConfirmationDialog(int coins) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text('Confirm Conversion',
              style: TextStyle(color: Colors.green)),
          content: Text('Do you want to convert $coins coins to money?',
              style: const TextStyle(color: Colors.green)),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      await convertCoins(coins);
    }
  }

  Future<void> _showErrorDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text('Invalid Input',
              style: TextStyle(color: Colors.green)),
          content: const Text(
              'Please enter the number of coins you want to convert.',
              style: TextStyle(color: Colors.green)),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialogNotEnough() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text('Not coin enough',
              style: TextStyle(color: Colors.green)),
          content: const Text(
              'Please enter the number coins you enough to convert.',
              style: TextStyle(color: Colors.green)),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDialogSuccess() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text('Success',
              style: TextStyle(color: Colors.green)),
          content: const Text(
              'You change coin to money success',
              style: TextStyle(color: Colors.green)),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> convertCoins(int coins) async {
    final token = Global.token;
    final response = await http.post(
      Uri.parse('${AppEnv.baseURL}consumer/win-coin'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'coinChange': coins,
      }),
    );

    if (response.statusCode == 204) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NavigationBarScreen(0)),
      ); // Refresh data after conversion
      _showDialogSuccess();
    }
    else if(response.statusCode==400) {
      _showErrorDialogNotEnough();
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to convert coins.',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _showPrivacyDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text('Privacy', style: TextStyle(color: Colors.green)),
          content: Text(
            'Wincoin is the currency of the WinPay application that is automatically generated when you use WinPay services such as paying for electricity, water, and internet. Once used, you will receive $coinConfig coin',
            style: const TextStyle(color: Colors.green),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WinCoin',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
              color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.green, fontSize: 16),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WinCoin'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: totalCoin == null || lastModifiedDate == null || value == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Your coin exchange amount 1 coin is ${value!} \$',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Quantity your wincoin',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      '$totalCoin coin',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'last modified date',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      formatDateTime(lastModifiedDate!),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 100),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              title: const Text('Change Coin to Money',
                                  style: TextStyle(color: Colors.green)),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  TextField(
                                    controller: _coinController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'Enter number of coins',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 150),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_coinController.text.isEmpty ||
                                          int.tryParse(_coinController.text) ==
                                              null) {
                                        Navigator.of(context).pop();
                                        _showErrorDialog();
                                      } else {
                                        int coins =
                                            int.parse(_coinController.text);
                                        Navigator.of(context).pop();
                                        _showConfirmationDialog(coins);
                                      }
                                    },
                                    child: const Text('Convert',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: const Text('Change Coin to Money',
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        _showPrivacyDialog();
                      },
                      child: const Text(
                        'Privacy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
