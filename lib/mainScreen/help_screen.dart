import 'package:flutter/material.dart';
import 'package:winpay/ui/home/TransferMoney.dart';

import '../ui/home/DepositScreen.dart';
import '../ui/home/navigationBar.dart';


class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Instructions for using WinPay'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NavigationBarScreen(3)),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: const Center(

        child: Text(
            textAlign: TextAlign.center,
            'Welcome to WinPay! Select an item from the menu to get started.',

        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green, // Changed this line to green
            ),
            child: Text(
              'WinPay Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Introduce'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const IntroductionPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Deposit Money into Wallet'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TopUpPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Transfer money'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TransferPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Pay the bill'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BillPaymentPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Top Up Your Phone'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MobileTopUpPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Account Management'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountManagementPage()),
              );
            },
          ),
          ListTile(
            title: const Text('Contact help'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupportPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}


class IntroductionPage extends StatelessWidget {
  const IntroductionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Introduce'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Icon(
                Icons.account_balance_wallet,
                size: 100.0,
                color: Colors.green, // Changed this line to green
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'WINPAY',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Changed this line to green
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'WinPay is a convenient and safe e-wallet that helps you perform financial transactions anytime, anywhere. With WinPay, you can pay bills, top up your phone, transfer money, and many other services quickly and easily.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopUpPage extends StatelessWidget {
  const TopUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit Money into Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.account_balance_wallet,
                size: 100.0,
                color: Colors.green, // Changed this line to green
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Deposit Money into Wallet WINPAY',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Changed this line to green
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '1. Open the WinPay app on your mobile device.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10), // Reduced the height for better spacing
            const Text(
              '2. Navigate to the "Top Up" section from the home screen.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10), // Reduced the height for better spacing
            const Text(
              '3. Select your preferred payment method (e.g., bank transfer, credit card).',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10), // Reduced the height for better spacing
            const Text(
              '4. Enter the amount you wish to deposit.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10), // Reduced the height for better spacing
            const Text(
              '5. Confirm the transaction and complete the payment process.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Set the button color to green
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DepositScreen()),
                  );
                  // Add your onPressed code here!
                },
                child: const Text('Start Top-Up Process'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransferPage extends StatelessWidget {
  const TransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer money'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.send,
                size: 100.0,
                color: Colors.green, // Changed this line to green
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Instructions for transferring money with WinPay',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Changed this line to green
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '1. Open the WinPay app on your mobile device.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              '2. Navigate to "Money Transfer" from the home screen.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              '3. Enter the amount you want to transfer and recipient information.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              '4. Check information and confirm transaction.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              '5. Complete the money transfer process.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD0E3E5), // Set the background color to green
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TransferScreen()),
                  );
                  // Add your onPressed code here!
                },
                child: const Text(
                    style: TextStyle(
                      color: Colors.green
                    ),
                    'Start Top-Up Process'
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BillPaymentPage extends StatelessWidget {
  const BillPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.receipt_long,
                size: 100.0,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Guide to Paying Bills with WinPay',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '1. Open the WinPay app on your mobile device.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              '2. Navigate to the "Bill Payment" section from the home screen.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              '3. Select the type of bill you want to pay (e.g., electricity, water, internet).',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              '4. Enter the necessary information and the amount to be paid.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              '5. Confirm the transaction and complete the payment process.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NavigationBarScreen(0)),
                  );
                  // Add your onPressed code here!
                },
                child: const Text('Start Bill Payment Process'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MobileTopUpPage extends StatelessWidget {
  const MobileTopUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Top-Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.phone_android,
                size: 100.0,
                color: Colors.green, // Set the icon color to green
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Guide to Mobile Top-Up with WinPay',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Set the text color to green
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '1. Open the WinPay app on your mobile device.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              '2. Navigate to the "Mobile Top-Up" section from the home screen.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              '3. Enter your mobile phone number.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              '4. Select the top-up amount or plan.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 10),
            const Text(
              '5. Confirm the transaction and complete the payment process.',
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Set the button color to green
                ),
                onPressed: () {
                  // Add your onPressed code here!
                },
                child: const Text('Start Top-Up Process'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountManagementPage extends StatelessWidget {
  const AccountManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Management'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon or Avatar for account
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 100.0,
                    color: Colors.green,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'User Account',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0), // Vertical space between sections
            Text(
              'Guide to managing your WinPay account.',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0), // Vertical space between text blocks
            Text(
              '1. View account information: You can view detailed information about your account, including balance, transaction history, and personal details.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
            Text(
              '2. Update personal information: You can update your personal information such as name, address, and phone number.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
            Text(
              '3. Change password: To ensure the security of your account, you should regularly change your password and do not share it with others.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
            Text(
              '4. Verify account: Verifying your account enhances security and unlocks advanced features of WinPay.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
            Text(
              '5. Contact support: If you encounter any issues, you can contact the WinPay support team for assistance and answers to your questions.',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}



class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Support'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon or Avatar for support
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 100.0,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Support',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0), // Vertical space between sections
            Text(
              'Guide to contacting WinPay support.',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0), // Vertical space between text blocks
            Text(
              '1. Phone Support: You can reach our support team via phone at (123) 456-7890. Our lines are open from 9 AM to 6 PM, Monday to Friday.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
            Text(
              '2. Email Support: For any inquiries, you can email us at support@winpay.com. We aim to respond to all emails within 24 hours.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
            Text(
              '3. Live Chat: You can also use our live chat feature available on our website and mobile app for instant support.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
            Text(
              '4. Help Center: Visit our Help Center at www.winpay.com/help for FAQs, tutorials, and more resources.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10.0),
            Text(
              '5. Social Media: Follow us on our social media channels for updates and support: Facebook, Twitter, Instagram.',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
