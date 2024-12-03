import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:winpay/env/app_env.dart';
import 'package:winpay/ui/auth/checkotpResetPassword.dart';
import 'package:winpay/global/global.dart';
import 'package:http/http.dart' as http;

class InitOtpResetPassword extends StatefulWidget {
  const InitOtpResetPassword({super.key});

  @override
  _InitOtpResetPasswordState createState() => _InitOtpResetPasswordState();
}

class _InitOtpResetPasswordState extends State<InitOtpResetPassword> {
  final TextEditingController _emailController = TextEditingController();
  final bool _isChecked = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay trở lại trang trước đó
          },
        ), // Tiêu đề của trang
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // <- Correct placement of padding constructor
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: const Text(
                  'Forgot password or Change password',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
              Container(
                alignment: Alignment.center,
                child: const Text(
                  'Enter the email you registered with and we will send a verification code to receive your phone number',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF2C2C2C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFFBDBDBD)),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE8E8E8), width: 2.0),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF6F6F6),
                ),
              ),
              const SizedBox(height: 20.0),

              InkWell(
                onTap: () async {

                    String email = _emailController.text;
                    Global.email = email;
                    Map<String, dynamic> resetPasswordData = {
                      'login': email,
                    };

                    // Chuyển map thành JSON string
                    String resetPasswordDataJson = jsonEncode(resetPasswordData);

                    // Gọi API
                    var url = Uri.parse('${AppEnv.baseURL}consumer/reset-password/init');
                    var response = await http.post(
                      url,
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: resetPasswordDataJson,
                    );
                    if (response.statusCode == 204) {
                      // Yêu cầu thành công, bạn có thể xử lý dữ liệu trả về ở đây (nếu có)
                      print('API request successful!');

                      // Sau đó chuyển đến trang mới
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CheckOtpResetPassword()),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Email fail'),
                            content: const Text("Can't find this email"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                      // Yêu cầu thất bại, hiển thị thông báo lỗi
                      print('API request failed with status: ${response.statusCode}');
                    }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 51,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: const Color(0xFF269947),
                    ),
                    child: const Center(
                      child: Text(
                        'NEXT',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}