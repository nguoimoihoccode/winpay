import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:winpay/env/app_env.dart';

import 'package:winpay/global/global.dart';
import 'package:winpay/model/user/user_profile.dart';
import 'package:winpay/ui/login/login_screen.dart';
import 'package:winpay/mainScreen/address_form.dart';
import 'package:winpay/mainScreen/editProfile.dart';
import 'package:winpay/mainScreen/help_screen.dart';

import '../ui/auth/initotpResetPassword.dart';
import '../term.dart';

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

Future<Uint8List> fetchUserAvatar(String avatar) async {
  final token = Global.token;
  final apiUrl = '${AppEnv.baseURL}consumer/download/$avatar';
  print('API URL: $apiUrl');

  final response = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw Exception('Failed to load avatar');
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> futureUserProfile;
  // int _selectedIndex = 4;
  final ImagePicker _picker = ImagePicker();


  @override
  void initState() {
    super.initState();
    futureUserProfile = fetchUserProfile();
  }

  Future<void> _uploadAvatar(File image) async {
    final token = Global.token;
    final apiUrl = '${AppEnv.baseURL}consumer/upload'; // Đường dẫn API tải lên avatar
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(apiUrl),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        futureUserProfile = fetchUserProfile();
      });
    } else {
      throw Exception('Failed to upload avatar');
    }
  }


  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _uploadAvatar(imageFile); // Gọi hàm để tải lên avatar
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<UserProfile>(
        future: futureUserProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final userProfile = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _showImageSourceActionSheet,
                          child: FutureBuilder<Uint8List>(
                            future: fetchUserAvatar(userProfile.avatar),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.grey,
                                );
                              } else if (snapshot.hasError) {
                                return const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.grey,
                                  child: Icon(Icons.error, color: Colors.red),
                                );
                              } else if (snapshot.hasData) {
                                return CircleAvatar(
                                  radius: 40,
                                  backgroundImage: MemoryImage(snapshot.data!),
                                  child: const Align(
                                    alignment: Alignment.bottomRight,
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.green,
                                      child: Icon(Icons.camera_alt,
                                          size: 15, color: Colors.white),
                                    ),
                                  ),
                                );
                              } else {
                                return const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.grey,
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Hello,', style: TextStyle(fontSize: 16)),
                              Text(userProfile.name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              Text(userProfile.email,
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UpdateProfileScreen()),
                            );
                          },
                          child: const Text('Edit Profile'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 70),
                  buildListTile(Icons.location_on, 'My Address'),
                  const SizedBox(height: 40),
                  buildListTile(Icons.lock, 'Change Password'),
                  const SizedBox(height: 40),
                  buildListTile(Icons.help_outline, 'Help'),
                  const SizedBox(height: 40),
                  buildListTile(Icons.privacy_tip, 'Privacy'),
                  const SizedBox(height: 40),
                  buildListTile(Icons.logout, 'Log Out'),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget buildListTile(IconData icon, String title) {
    return Container(
      width: 370,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        onTap: () {
          if (icon == Icons.logout) {
            Global.clearToken();

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
            );
          }
          else if (icon == Icons.lock) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InitOtpResetPassword()),
            );
          }
          else if(icon == Icons.help_outline) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpScreen()),
            );
          }
          else if(icon == Icons.privacy_tip) {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Term()),
            );
          }
          else if (icon == Icons.location_on) {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddressForm()),
            );
          }
        },
      ),
    );
  }
}
