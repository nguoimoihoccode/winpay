import 'package:flutter/material.dart';
import 'package:winpay/ui/login/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Đợi 1 giây sau đó chuyển đến trang đăng nhập
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3E7),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Image.asset(
              'assets/img.png', // Đường dẫn của hình ảnh trong thư mục assets
              fit: BoxFit.cover, // Thay đổi để hình ảnh phù hợp với màn hình
            ),
          ),
          const Positioned(
            bottom: 35.0, // Khoảng cách dưới cùng của màn hình
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'SOLVE YOUR MONEY PROBLEM',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
