import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/env/app_env.dart';
import 'package:winpay/ui/login/login_screen.dart';

import 'checkotp.dart';
import '../../term.dart';
import 'package:winpay/global/global.dart';

class InitOtp extends StatefulWidget {
  const InitOtp({super.key});

  @override
  _InitOtpState createState() => _InitOtpState();
}

class _InitOtpState extends State<InitOtp> {
  final TextEditingController _emailController = TextEditingController();
  bool _isChecked = false;
  bool _isLoading = false; // Biến để xác định trạng thái loading

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay trở lại trang trước đó
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                  'Please enter email',
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
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: _isChecked,
                activeColor: const Color(0xFF387770),
                onChanged: (bool? value) {
                  setState(() {
                    _isChecked = value ?? false;
                  });
                },
                title: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Term()),
                    );
                  },
                  child: const Text(
                    'I have read and agree to the Term of service and Privacy policy.',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Color(0xFF323232),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              InkWell(
                onTap: () async {
                  if (_isChecked) {
                    setState(() {
                      _isLoading = true; // Bắt đầu hiển thị loading khi bắt đầu gọi API
                    });
                    Global.email = _emailController.text;
                    String email = Global.email;

                    var url = Uri.parse('${AppEnv.baseURL}consumer/otp/init/$email');
                    var response = await http.post(url);

                    if (response.statusCode == 204) {
                      print('API request successful!');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CheckOtp()),
                      );
                    } else {
                      print('API request failed with status: ${response.statusCode}');
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Failed to Register'),
                            content: const Text('Please try again later.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('YOU HAVE NOT AGREED TO THE TERMS'),
                          content: const Text('Please agree to the Terms of Service and Privacy Policy to register.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  setState(() {
                    _isLoading = false; // Tắt loading sau khi gọi API xong (hoặc khi có lỗi)
                  });
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
                    child: _isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Center(
                      child: Text(
                        'REGISTER',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF428079),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
