import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winpay/env/app_env.dart';
import 'package:winpay/global/global.dart';
import 'dart:convert';
import '../ui/home/navigationBar.dart';

class AddressForm extends StatefulWidget {
  const AddressForm({super.key});

  @override
  _AddressFormState createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  List<dynamic> provinces = [];
  List<dynamic> districts = [];
  List<dynamic> wards = [];
  String? selectedProvince;
  String? selectedDistrict;
  String? selectedWard;
  final token = Global.token; // Replace with your actual token

  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProvinces();
    fetchCurrentAddress();
  }


  Future<void> fetchCurrentAddress() async {
    final response = await http.get(
      Uri.parse('${AppEnv.baseURL}consumer/my-address'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));

      setState(() {
        addressController.text = data['address'];
        selectedProvince = data['province']['id'].toString();
        selectedDistrict = data['district']['id'].toString();
        selectedWard = data['wards']['id'].toString();
      });

      // Fetch districts and wards based on the initial province and district
      await fetchDistricts(selectedProvince!);
      await fetchWards(selectedDistrict!);
    } else {
      throw Exception('Failed to load current address');
    }
  }


  void saveAddress() async {
    // Construct the address object from the form fields
    Map<String, dynamic> addressData = {
      "address": addressController.text,
      "countryId": 241,
      "provinceId": int.parse(selectedProvince!),
      "districtId": int.parse(selectedDistrict!),
      "wardsId": int.parse(selectedWard!),
    };

    // Send POST request to save the address
    final response = await http.post(
      Uri.parse('${AppEnv.baseURL}consumer/address'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(addressData),
    );

    // Handle response
    if (response.statusCode == 200) {
      // Address saved successfully, show a success message or perform any other action
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Address saved successfully'),
        duration: Duration(seconds: 2),
      ));
    } else {
      // Failed to save address, show an error message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to save address'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> fetchProvinces() async {
    final response = await http.get(
      Uri.parse('${AppEnv.baseURL}consumer/provinces/241'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        provinces = json.decode(utf8.decode(response.bodyBytes));
      });
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  Future<void> fetchDistricts(String provinceId) async {
    final response = await http.get(
      Uri.parse('${AppEnv.baseURL}districts/$provinceId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        districts = json.decode(utf8.decode(response.bodyBytes));
        // Retain the selected district if it matches the current address
        if (!districts.any((district) => district['id'].toString() == selectedDistrict)) {
          selectedDistrict = null;
        }
      });
    } else {
      throw Exception('Failed to load districts');
    }
  }

  Future<void> fetchWards(String districtId) async {
    final response = await http.get(
      Uri.parse('${AppEnv.baseURL}wards/$districtId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        wards = json.decode(utf8.decode(response.bodyBytes));
        // Retain the selected ward if it matches the current address
        if (!wards.any((ward) => ward['id'].toString() == selectedWard)) {
          selectedWard = null;
        }
      });
    } else {
      throw Exception('Failed to load wards');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please enter your address in English characters as required by international service',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Street name, P.O. box, etc',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF5CAF21), width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Country',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE8E8E8), width: 2.0),
                ),
              ),
              items: ['Việt Nam'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                // Do nothing as only 'Vietnam' is allowed
              },
              value: 'Việt Nam',
            ),

            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Province',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF5CAF21), width: 2.0),
                ),
              ),
              items: provinces.map<DropdownMenuItem<String>>((province) {
                return DropdownMenuItem<String>(
                  value: province['id'].toString(),
                  child: Text(province['name']),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedProvince = newValue;
                  selectedDistrict = null; // Reset district when province changes
                  selectedWard = null; // Reset ward when province changes
                  wards = []; // Clear wards when province changes
                });
                fetchDistricts(newValue!);
              },
              value: selectedProvince,
            ),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'District',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF5CAF21), width: 2.0),
                ),
              ),
              items: districts.map<DropdownMenuItem<String>>((district) {
                return DropdownMenuItem<String>(
                  value: district['id'].toString(),
                  child: Text(district['name']),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedDistrict = newValue;
                  selectedWard = null; // Reset ward when district changes
                  wards = []; // Clear wards when district changes
                });
                fetchWards(newValue!);
              },
              value: selectedDistrict,
            ),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Ward',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF5CAF21), width: 2.0),
                ),
              ),
              items: wards.map<DropdownMenuItem<String>>((ward) {
                return DropdownMenuItem<String>(
                  value: ward['id'].toString(),
                  child: Text(ward['name']),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedWard = newValue;
                });
              },
              value: selectedWard,
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NavigationBarScreen(3)),
                  );
                  saveAddress();
                },
                child: const Text(
                  'SAVE',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
