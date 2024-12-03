import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:winpay/env/app_env.dart';
import 'package:winpay/global/global.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/ui/login/login_screen.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  _ChangePasswordFormState createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false; // Add this line

  Future<void> _submitOTP() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    String login = Global.email;
    String password = _passwordController.text;
    String activatedKey = Global.activatedKey;
    String rePassword = _rePasswordController.text;

    if (password != rePassword) {
      setState(() {
        _isLoading = false; // Stop loading if passwords don't match
      });
      _showErrorDialog('password not match. your password and retype password does not same.');
      return;
    }

    if (password.isNotEmpty) {
      Map<String, dynamic> otpData = {
        'password': password,
        'login': login,
        'activatedKey': activatedKey
      };
      String otpJson = jsonEncode(otpData);

      var url = Uri.parse('${AppEnv.baseURL}consumer/reset-password/change-password');
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: otpJson,
      );

      setState(() {
        _isLoading = false; // Stop loading
      });

      if (response.statusCode == 204) {
        _showErrorDialog('Change password success. You changed your password now let login again.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        _showErrorDialog('Invalid password. Please try again.');
      }
    } else {
      setState(() {
        _isLoading = false; // Stop loading if password is empty
      });
      _showErrorDialog('Invalid password. Please enter password.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 100.0),
                  const Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    "please enter new password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Color(0xFF2C2C2C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    Global.email,
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Color(0xFF2C2C2C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 60.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText, // Sử dụng trạng thái `_obscureText` để quyết định xem mật khẩu có hiển thị hay không
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEAF3E7), width: 1.0), // Định dạng border khi TextField được focus
                      ),
                      filled: true, // Bật chế độ fill cho TextField
                      fillColor: const Color(0xFFF6F6F6), // Màu xám nhạt
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText; // Đảo ngược trạng thái của `_obscureText` khi người dùng nhấn vào biểu tượng
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  TextField(
                    controller: _rePasswordController,
                    obscureText: _obscureText, // Sử dụng trạng thái `_obscureText` để quyết định xem mật khẩu có hiển thị hay không
                    decoration: InputDecoration(
                      labelText: 'Retype Password',
                      labelStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFEAF3E7), width: 1.0), // Định dạng border khi TextField được focus
                      ),
                      filled: true, // Bật chế độ fill cho TextField
                      fillColor: const Color(0xFFF6F6F6), // Màu xám nhạt
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText; // Đảo ngược trạng thái của `_obscureText` khi người dùng nhấn vào biểu tượng
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  InkWell(
                    onTap: _submitOTP,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 150.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF269947),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: const Text(
                        'NEXT',
                        style: TextStyle(
                          color: Colors.white,
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
          if (_isLoading) // Show loading indicator when _isLoading is true
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
