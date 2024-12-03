import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:winpay/env/app_env.dart';
import 'package:winpay/global/global.dart';
import 'package:http/http.dart' as http;
import 'register.dart';

class CheckOtp extends StatefulWidget {
  const CheckOtp({super.key});

  @override
  _CheckOtp createState() => _CheckOtp();
}

class _CheckOtp extends State<CheckOtp> {
  final TextEditingController _otp = TextEditingController();
  bool _isLoading = false; // Add this line

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ), // Title of the page
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0), // Correct placement of padding constructor
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 100.0),
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'REGISTER',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "We have sent a 6-digit confirmation code to your email",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Color(0xFF2C2C2C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      Global.email,
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Color(0xFF2C2C2C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _otp,
                    decoration: const InputDecoration(
                      labelText: 'Verification codes',
                      labelStyle: TextStyle(color: Color(0xFFBDBDBD)),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFE8E8E8), width: 2.0),
                      ),
                      filled: true,
                      fillColor: Color(0xFFF6F6F6),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        _isLoading = true; // Start loading
                      });

                      String email = Global.email;
                      String otpText = _otp.text;

                      if (otpText.isNotEmpty) {
                        int? otp = int.tryParse(otpText);

                        if (otp != null) {
                          Map<String, dynamic> otpData = {
                            'otp': otp,
                          };
                          debugPrint("otp: $otp");

                          String otpJson = jsonEncode(otpData);

                          var url = Uri.parse('${AppEnv.baseURL}consumer/otp/validate/$email');
                          var response = await http.post(
                            url,
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: otpJson,
                          );

                          setState(() {
                            _isLoading = false; // Stop loading
                          });

                          if (response.statusCode == 200) {
                            print('API request successful!');
                            var responseData = jsonDecode(response.body);
                            Global.activatedKey = responseData['activatedKey'];
                            print(Global.activatedKey);

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          } else {
                            print('API request failed with status: ${response.statusCode}');
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text('Invalid OTP. Please try again.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close popup
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        } else {
                          setState(() {
                            _isLoading = false; // Stop loading if invalid OTP
                          });

                          print('Invalid OTP');
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Invalid OTP'),
                                content: const Text('Invalid OTP. Please enter a valid number.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close popup
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } else {
                        setState(() {
                          _isLoading = false; // Stop loading if OTP not entered
                        });

                        print('Please enter OTP');
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('YOU HAVE NOT ENTERED OTP'),
                              content: const Text('Please enter OTP.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close popup
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 150.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF269947), // Button background color
                        borderRadius: BorderRadius.circular(30.0), // Button border radius
                      ),
                      child: const Text(
                        'NEXT', // Button text
                        style: TextStyle(
                          color: Colors.white, // Button text color
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
          if (_isLoading) // Show loading indicator if _isLoading is true
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
