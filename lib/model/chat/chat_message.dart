class ChatMessage {
  final int id;
  final String senderId;
  final String receiptId;
  final String message;
  final bool read;
  final int chatId;
  final String createdDate;
  final String senderName;
  final String receiptName;
  final String status;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiptId,
    required this.message,
    required this.read,
    required this.chatId,
    required this.createdDate,
    required this.senderName,
    required this.receiptName,
    required this.status,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'],
      receiptId: json['receiptId'],
      message: json['message'],
      read: json['read'],
      chatId: json['chatId'],
      createdDate: json['createdDate'],
      senderName: json['senderName'] ?? '',
      receiptName: json['receiptName'] ?? '',
      status: json['status'],
    );
  }
}