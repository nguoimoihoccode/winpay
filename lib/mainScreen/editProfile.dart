import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:winpay/env/app_env.dart';
import 'package:winpay/global/global.dart';

import '../ui/home/navigationBar.dart';

class ProfileService {
  final String baseUrl = '${AppEnv.baseURL}consumer/profiles';

  Future<Profile> fetchProfile(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Profile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<void> updateProfile(String token, Profile profile) async {
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profile.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }
}

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  Profile _profile = Profile(
    id: 0,
    email: '',
    name: '',
    phone: '',
    avatar: '',
    accountNumber: null,
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profileService = ProfileService();
      final token = Global.token; // Thay thế token ở đây
      final profile = await profileService.fetchProfile(token!);
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $error')),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final profileService = ProfileService();
        final token = Global.token; // Thay thế token ở đây
        await profileService.updateProfile(token!, _profile);
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UpdateProfileScreen()),
        );
      } catch (error) {
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NavigationBarScreen(3)),
            );
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _buildTextFormField(
                initialValue: _profile.name,
                labelText: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _profile.name = value!;
                },
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                initialValue: _profile.email,
                labelText: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _profile.email = value!;
                },
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                initialValue: _profile.phone,
                labelText: 'Phone',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _profile.phone = value!;
                },
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Màu nút là xanh lá cây
                ),
                child: const Text('Update Profile'),

              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String initialValue,
    required String labelText,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String>? validator,
    required IconData prefixIcon,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.green, // Màu icon là xanh lá cây
        ),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}

class Profile {
  int id;
  String email;
  String name;
  String phone;
  String avatar;
  String? accountNumber;

  Profile({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.avatar,
    this.accountNumber,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      avatar: json['avatar'],
      accountNumber: json['accountNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}
