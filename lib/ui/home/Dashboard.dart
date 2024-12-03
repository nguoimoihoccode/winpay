import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:winpay/env/app_env.dart';
import 'package:winpay/ui/chat/chatScreen.dart';
import 'package:winpay/ui/home/DepositScreen.dart';
import 'package:winpay/service/InternetBill.dart';
import 'package:winpay/service/SavingWallet.dart';
import 'package:winpay/service/waterBill.dart';
import 'package:winpay/service/wincoin.dart';
import 'package:winpay/service/withdraw.dart';
import '../../global/global.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

import '../../global/http_helper.dart';
import '../../service/electricBill.dart';
import 'BankDetailScreen.dart';
import 'TransferMoney.dart';
import 'connectBank.dart';
import 'navigationBar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

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

class Wallet {
  final int id;
  final String ownerId;
  final String ownerName;
  final double totalMoney;
  final String createdDate;
  final String code;
  final String codeWallet;

  Wallet({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.totalMoney,
    required this.createdDate,
    required this.code,
    required this.codeWallet,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      ownerId: json['ownerId'],
      ownerName: json['ownerName'],
      totalMoney: json['totalMoney'].toDouble(),
      createdDate: json['createdDate'],
      code: json['code'],
      codeWallet: json['codeWallet'],
    );
  }
}

class BankAccount {
  final int id;
  final String bankCode;
  final double totalMoney;
  final String createdDate;
  final String ownerId;
  final String ownerName;
  final String? walletId;
  final String logo;
  final String bankBrand;
  final String bankName;

  BankAccount({
    required this.id,
    required this.bankCode,
    required this.totalMoney,
    required this.createdDate,
    required this.ownerId,
    required this.ownerName,
    this.walletId,
    required this.logo,
    required this.bankBrand,
    required this.bankName,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    double parsedTotalMoney = json['totalMoney'] != null ? double.tryParse(json['totalMoney'].toString()) ?? 0.0 : 0.0;

    return BankAccount(
      id: json['id'],
      bankCode: json['bankCode'],
      totalMoney: parsedTotalMoney,
      createdDate: json['createdDate'],
      ownerId: json['ownerId'],
      ownerName: json['ownerName'],
      walletId: json['walletId'],
      logo: json['logo'],
      bankBrand: json['bankBrand'],
      bankName: json['bankName'],
    );
  }
}


Future<Wallet> fetchWalletData() async {
  final token = Global.token;
  final response = await http.get(
    Uri.parse('${AppEnv.baseURL}consumer/wallet/my-wallet'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return Wallet.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load wallet');
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

Future<bool> deleteBankAccount(int id) async {
  final String apiUrl = '${AppEnv.baseURL}consumer/bank-connect/{bankId}';
  final token = Global.token;
  dynamic response;

  try {
    response = await HttpHelper.invokeHttp(Uri.parse(apiUrl.replaceAll("{bankId}", id.toString())), RequestType.delete,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: null);
  } catch (e) {
    debugPrint("Failed to get list: $e");
  }

  if (response == null) {
    return false;
  }

  return true;
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<UserProfile> futureUserProfile;
  late Future<Wallet> futureWallet;
  late Future<List<BankAccount>> futureBankAccountHistory;
  List<BankAccount>? dataAfterCallingAPIBankAccount;
  int bankAccountId = -1;

  get webSocketService => null;

  @override
  void initState() {
    super.initState();
    futureUserProfile = fetchUserProfile();
    futureBankAccountHistory = fetchBankAccountHistory();
    debugPrint("Trying data: ${dataAfterCallingAPIBankAccount?[0].id ?? "false"}");
  }

  void _removeAccount(int id) {
    setState(() {
      dataAfterCallingAPIBankAccount?.removeWhere((account) => account.id == id);
      didChangeDependencies();
    });
  }

  Future<List<BankAccount>> fetchBankAccountHistory() async {
    final String apiUrl = '${AppEnv.baseURL}consumer/bank-connect';
    final token = Global.token;
    List<BankAccount> bankAccounts;
    List<dynamic>? response;

    try {
      response = await HttpHelper.invokeHttpList(Uri.parse(apiUrl), RequestType.get,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: null);
    } catch (e) {
      debugPrint("Failed to get list: $e");
    }

    if (response == null) {
      return [];
    }

    bankAccounts = response.map((dynamic i) => BankAccount.fromJson(i as Map<String, dynamic>)).toList();
    dataAfterCallingAPIBankAccount = bankAccounts;
    return bankAccounts;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    futureBankAccountHistory = fetchBankAccountHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              // Chuyển đến trang chat
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FutureBuilder<UserProfile>(
          future: futureUserProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No user data found'));
            } else {
              final userProfile = snapshot.data!;
              return FutureBuilder<Wallet>(
                future: fetchWalletData(), // Hàm này để fetch dữ liệu từ API
                builder: (context, walletSnapshot) {
                  if (walletSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (walletSnapshot.hasError) {
                    return Center(child: Text('Error: ${walletSnapshot.error}'));
                  } else if (!walletSnapshot.hasData) {
                    return const Center(child: Text('No wallet data found'));
                  } else {
                    final walletData = walletSnapshot.data!;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
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
                                          child: Icon(Icons.error,
                                              color: Colors.red),
                                        );
                                      } else if (snapshot.hasData) {
                                        return CircleAvatar(
                                          radius: 40,
                                          backgroundImage:
                                              MemoryImage(snapshot.data!),
                                          child: const Align(
                                            alignment: Alignment.bottomRight,
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
                                      const Text('Hello,',
                                          style: TextStyle(fontSize: 16)),
                                      Text(userProfile.name,
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      Text(userProfile.email,
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.green[700],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2, // Phần của tiền chiếm 2/3 không gian
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '\$${walletData.totalMoney.toStringAsFixed(2)}', // Sử dụng dữ liệu từ API
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        // Thêm các phần tử khác của phần tiền ở đây nếu cần
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 20), // Khoảng cách giữa hai phần
                                  Expanded(
                                    flex:
                                        1, // Phần của mã QR chiếm 1/3 không gian
                                    child: QrImageView(
                                      data: userProfile.email, // walletData là đối tượng Wallet từ API
                                      version: QrVersions.auto,
                                      size: 100.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    String refresh = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const BankAccountCreationScreen()),
                                    );
                                    if (refresh == 'onBackRefresh') {
                                      // Trigger refresh of bank account history
                                      didChangeDependencies();
                                    }
                                  },
                                  child: const ActionButton(icon: Icons.add, label: 'Add bank'),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    String refresh = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const TransferScreen()),
                                    );
                                    if (refresh == 'onBackRefresh') {
                                      // Trigger refresh of bank account history
                                      didChangeDependencies();
                                    }
                                  },
                                  child:  const ActionButton(icon: Icons.send, label: 'Send money'),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    String refresh = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const DepositScreen()),
                                    );
                                    if (refresh == 'onBackRefresh') {
                                      // Trigger refresh of bank account history
                                      didChangeDependencies();
                                    }
                                  },
                                  child:  const ActionButton(icon: Icons.attach_money, label: 'Refill wallet'),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            const Text(
                              'Frequent Actions',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                FrequentActionButton(
                                    icon: Icons.flash_on, label: 'Electricity', onTap: ()
                                {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ElectricityBillScreen()),
                                  );
                                }),
                                FrequentActionButton(
                                    icon: Icons.water, label: 'Water',onTap: ()
                                {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const WaterBillScreen()),
                                  );
                                }),
                                FrequentActionButton(
                                    icon: Icons.wifi, label: 'Internet',onTap: ()
                                {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const InternetBillScreen()),
                                  );
                                }),
                                FrequentActionButton(
                                    icon: Icons.currency_bitcoin, label: 'WinCoin',onTap: ()
                                {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const WinCoinScreen()),
                                  );
                                }),
                                FrequentActionButton(
                                    icon: Icons.account_balance_wallet,
                                    label: 'Withdrawal',onTap: ()
                                {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const WithdrawMainScreen()),
                                  );
                                }),
                                FrequentActionButton(
                                    icon: Icons.wallet, label: 'Swallet',onTap: ()
                                {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SavingWalletScreen()),
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.green[100],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Account Limit | Monthly'),
                                  const SizedBox(height: 10),
                                  LinearProgressIndicator(
                                    value: walletData.totalMoney / 100000, // Phần trăm của totalMoney so với 100,000
                                    backgroundColor: Colors.grey[300],
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('\$0.00'),
                                      Text('\$${walletData.totalMoney.toStringAsFixed(2)}'),
                                      const Text('\$100,000.00'),
                                    ],
                                  ),
                                ],
                              ),
                            ),


                            const SizedBox(height: 20),
                            const Text(
                              'Account History',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            FutureBuilder<List<BankAccount>>(
                              future: futureBankAccountHistory,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                      child:
                                          Text('No bank account history found'));
                                } else {
                                  return Column(
                                    children: snapshot.data!.map((account) {
                                      return AccountHistoryCard(
                                        date: account.createdDate,
                                        amount: account.totalMoney,
                                        logo: account.logo,
                                        id: account.id,
                                        onDismissed: () => _removeAccount(account.id),
                                      );
                                    }).toList(),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const ActionButton({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.green[100],
          child: Icon(icon, size: 30, color: Colors.green[700]),
        ),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}

class FrequentActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const FrequentActionButton({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.green[100],
            child: Icon(icon, size: 25, color: Colors.green[700]),
          ),
          const SizedBox(height: 5),
          Text(label),
        ],
      ),
    );
  }
}

class AccountHistoryCard extends StatelessWidget {
  final int id;
  final String date;
  final double amount;
  final String logo;
  final VoidCallback onDismissed;

  const AccountHistoryCard({super.key, 
    required this.id,
    required this.date,
    required this.amount,
    required this.logo,
    required this.onDismissed,
  });

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(8),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) {
        return showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: const Text("Delete confirmation"),
            content: const Text("Are you certain you want to delete this bank account?"),
            actions: [
              ElevatedButton(onPressed: (){
                Navigator.of(context).pop(false);
              }, child: const Text("Cancel")),
              ElevatedButton(onPressed: (){
                deleteBankAccount(id);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NavigationBarScreen(0)),
                );
              }, child: const Text("Delete")),
            ],
          );
        });
      },
      onDismissed: (direction) {
        onDismissed();
      },
      child: Card(
        child: ListTile(
          leading: Image.network(
              '${AppEnv.baseURL}consumer/public/logo/$logo',
              width: 50),
          title: Text('\$${amount.toStringAsFixed(2)}'),
          subtitle: Text(_formatDate(date)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BankDetailScreen(bankId: id),
              ),
            );
          },
        ),
      ),
    );
  }
}


