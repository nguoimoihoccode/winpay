import 'package:flutter/material.dart';

class Term extends StatelessWidget {
  const Term({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TERM AND POLICY'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context); // Quay trở lại trang trước đó
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          _buildTermItem(
              'Account:', 'You need to create an account and provide correct and complete information.'),
          _buildTermItem('Security:',
              'Secure your personal information and password. Do not share with others.'),
          _buildTermItem(
              'Use:', 'Use e-wallets only for legal purposes and in compliance with legal regulations.'),
          _buildTermItem('Transfer:', 'Trade carefully and be responsible with the trades you make.'),
          _buildTermItem(
              'Fee:', 'Fees may apply to some transactions. Check before doing.'),
          _buildTermItem('Transaction security:',
              'Always use a secure connection and do not share your transaction information with anyone.'),
          _buildTermItem('Take risks:',
              'You accept all risks related to the use of e-wallets and online transactions.'),
          _buildTermItem('End:',
              'You have the right to terminate your account in accordance with the terms of the service.'),
          _buildTermItem('Accept terms:',
              'Using an e-wallet means you accept all terms and conditions of the service.'),
          _buildTermItem('Change terms:',
              'Terms and conditions may change from time to time. You need to check and understand clearly before continuing to use.'),
          _buildTermItem(
              'Make sure you carefully read and understand the terms before using the e-wallet.', '',
              fontSize: 18.0,
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(String title, String content, {double fontSize = 15.0}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0),
          Text(
            content,
            style: TextStyle(fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}
