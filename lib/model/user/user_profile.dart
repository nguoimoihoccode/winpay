import 'dart:convert';

import 'package:winpay/env/app_env.dart';
import 'package:winpay/global/global.dart';
import 'package:http/http.dart' as http;

class UserProfile {
  final int id;
  final String email;
  final String name;
  final String phone;
  final String avatar;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      avatar: json['avatar'],
    );
  }
}

Future<UserProfile> fetchUserProfile() async {
  final token = Global.token;
  final response = await http.get(
    Uri.parse('${AppEnv.baseURL}consumer/profiles'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return UserProfile.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load profile');
  }
}
