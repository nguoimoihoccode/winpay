import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:winpay/env/app_env.dart';
import 'package:winpay/global/global.dart';
import 'package:http/http.dart' as http;

import 'changePassword.dart';

class CheckOtpResetPassword extends StatefulWidget {
  const CheckOtpResetPassword({super.key});


  @override
  _CheckOtpResetPassword createState() => _CheckOtpResetPassword();
}

class _CheckOtpResetPassword extends State<CheckOtpResetPassword> {
  final TextEditingController _otp = TextEditingController();


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
              const SizedBox(height: 100.0),
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
              const SizedBox(height: 20.0),
              Container(
                alignment: Alignment.center,
                child:  const Text(
                  "We have sent a 6-digit confirmation code to your phone number",
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
                child:  Text(
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
                  String email = Global.email;
                  String otpText = _otp.text;

                  // Kiểm tra xem người dùng đã nhập OTP vào ô văn bản hay chưa
                  if (otpText.isNotEmpty) {
                    // Chuyển đổi giá trị được nhập từ ô văn bản thành số nguyên
                    int? otp = int.tryParse(otpText);

                    // Kiểm tra xem giá trị OTP có hợp lệ không
                    if (otp != null) {
                      // Tạo một map chứa dữ liệu OTP
                      Map<String, dynamic> otpData = {
                        'otp': otp,
                        'login': email
                      };


                      // Chuyển map thành JSON string
                      String otpJson = jsonEncode(otpData);

                      // Gọi API
                      var url = Uri.parse('${AppEnv.baseURL}consumer/reset-password/check-otp');
                      var response = await http.post(
                        url,
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: otpJson,
                      );

                      // Kiểm tra xem yêu cầu có thành công không
                      if (response.statusCode == 200) {
                        // Yêu cầu thành công, bạn có thể xử lý dữ liệu trả về ở đây (nếu có)
                        print('API request successful!');
                        // Sau khi gọi API và nhận được phản hồi thành công
                        var responseData = jsonDecode(response.body);

                        // Gán giá trị activatedKey cho biến global
                        Global.activatedKey = responseData['activatedKey'];
                        print(Global.activatedKey);

                        // Sau đó chuyển đến trang mới
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ChangePasswordForm()),
                        );
                      } else {
                        // Yêu cầu thất bại, hiển thị thông báo lỗi
                        print('API request failed with status: ${response.statusCode}');
                        // Hiển thị popup thông báo lỗi
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Invalid OTP. Please try again.'),
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
                      // Hiển thị thông báo nếu giá trị nhập không phải là số nguyên
                      print('Invalid OTP');
                      // Hiển thị popup thông báo lỗi
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Invalid OTP'),
                            content: const Text('Invalid OTP. Please enter a valid number.'),
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
                    // Hiển thị thông báo nếu người dùng không nhập OTP
                    print('Please enter OTP');
                    // Hiển thị popup thông báo lỗi
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('YOU HAVE NOT ENTER OTP'),
                          content: const Text('Please enter OTP.'),
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
                    'NEXT', // Nội dung của nút
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
      ),
    );
  }
}