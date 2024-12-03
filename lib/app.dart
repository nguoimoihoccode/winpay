import 'package:flutter/material.dart';
import 'package:winpay/ui/splash/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Hiển thị màn hình Splash Screen trước
    );
  }
}