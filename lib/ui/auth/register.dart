import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/env/app_env.dart';
import 'package:winpay/global/global.dart';
import 'package:winpay/ui/login/login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
      body: const RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false; // Add this line

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
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
                  "Proceed to enter the following operations to complete registration",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Color(0xFF2C2C2C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
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
              const SizedBox(height: 20.0),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(color: Color(0xFFBDBDBD)), // Màu xanh dương
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE8E8E8), width: 2.0),
                  ),
                  filled: true, // Bật chế độ fill cho TextField
                  fillColor: Color(0xFFF6F6F6), // Màu xám nhạt
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Color(0xFFBDBDBD)), // Màu xanh dương
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE8E8E8), width: 2.0),
                  ),
                  filled: true, // Bật chế độ fill cho TextField
                  fillColor: Color(0xFFF6F6F6), // Màu xám nhạt
                ),
              ),
              const SizedBox(height: 50.0),
              InkWell(
                onTap: () async {
                  setState(() {
                    _isLoading = true; // Start loading
                  });

                  // Kiểm tra trạng thái của checkbox trước khi đăng ký
                  String email = Global.email;
                  String password = _passwordController.text;
                  String phone = _phoneController.text;
                  String name = _nameController.text;
                  String username = Global.email;
                  String activatedKey = Global.activatedKey;

                  // Kiểm tra xem người dùng đã nhập OTP vào ô văn bản hay chưa
                  if (email.isNotEmpty && password.isNotEmpty && phone.isNotEmpty && name.isNotEmpty && username.isNotEmpty) {

                    // Tạo một map chứa dữ liệu OTP
                    Map<String, dynamic> registerData = {
                      'email': email,
                      'password': password,
                      'phone': phone,
                      'name': name,
                      'username': username,
                      'activatedKey': activatedKey
                    };

                    // Chuyển map thành JSON string
                    String registerJson = jsonEncode(registerData);

                    // Gọi API
                    var url = Uri.parse('${AppEnv.baseURL}consumer/register');
                    var response = await http.post(
                      url,
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: registerJson,
                    );

                    setState(() {
                      _isLoading = false; // Stop loading
                    });

                    // Kiểm tra xem yêu cầu có thành công không
                    if (response.statusCode == 200) {
                      // Yêu cầu thành công, bạn có thể xử lý dữ liệu trả về ở đây (nếu có)
                      print('API request successful!');

                      // Sau đó chuyển đến trang mới
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('REGISTER SUCCESS'),
                            content: const Text('Welcome you become winpay member'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Đóng popup
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // Yêu cầu thất bại, hiển thị thông báo lỗi
                      print('API request failed with status: ${response.statusCode}');
                      // Hiển thị popup thông báo lỗi
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('SORRY'),
                            content: const Text('We have a error, we will try to fix it.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Đóng popup
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
                      _isLoading = false; // Stop loading if fields are not filled
                    });

                    // Hiển thị thông báo nếu người dùng không nhập OTP
                    print('Please enter OTP');
                    // Hiển thị popup thông báo lỗi
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('YOU MUST FILL ALL DATA'),
                          content: const Text('Please enter all field data.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Đóng popup
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
                    color: const Color(0xFF269947), // Màu nền của nút
                    borderRadius: BorderRadius.circular(30.0), // Độ bo góc của nút
                  ),
                  child: const Text(
                    'REGISTER', // Nội dung của nút
                    style: TextStyle(
                      color: Colors.white, // Màu chữ của nút
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
        if (_isLoading) // Show loading indicator if _isLoading is true
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
