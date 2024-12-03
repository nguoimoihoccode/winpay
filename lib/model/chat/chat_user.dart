
class ChatUser {
  final int id;
  final String email;
  final String name;
  final String phone;
  final String avatar;
  final String? accountNumber;

  ChatUser({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.avatar,
    this.accountNumber,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      avatar: json['avatar'],
      accountNumber: json['accountNumber'],
    );
  }
}