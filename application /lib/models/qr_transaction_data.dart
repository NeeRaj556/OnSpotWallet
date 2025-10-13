import 'dart:convert';

class QRTransactionData {
  final String userId;
  final String userName;
  final double amount;
  final String purpose;
  final String transactionId;
  final DateTime timestamp;
  final String transactionType; // 'send', 'receive', 'request'

  const QRTransactionData({
    required this.userId,
    required this.userName,
    required this.amount,
    required this.purpose,
    required this.transactionId,
    required this.timestamp,
    this.transactionType = 'send',
  });

  // Convert to JSON for QR code generation
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'amount': amount,
        'purpose': purpose,
        'transactionId': transactionId,
        'timestamp': timestamp.toIso8601String(),
        'transactionType': transactionType,
      };

  // Convert to String for QR code
  String toQRString() => jsonEncode(toJson());

  // Parse from QR code string
  factory QRTransactionData.fromQRString(String qrString) {
    final Map<String, dynamic> json = jsonDecode(qrString);
    return QRTransactionData.fromJson(json);
  }

  // Create from JSON
  factory QRTransactionData.fromJson(Map<String, dynamic> json) {
    return QRTransactionData(
      userId: json['userId'] as String,
      userName: json['userName'] as String? ?? 'Unknown User',
      amount: (json['amount'] as num).toDouble(),
      purpose: json['purpose'] as String,
      transactionId: json['transactionId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      transactionType: json['transactionType'] as String? ?? 'send',
    );
  }

  // Create a copy with modifications
  QRTransactionData copyWith({
    String? userId,
    String? userName,
    double? amount,
    String? purpose,
    String? transactionId,
    DateTime? timestamp,
    String? transactionType,
  }) {
    return QRTransactionData(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      amount: amount ?? this.amount,
      purpose: purpose ?? this.purpose,
      transactionId: transactionId ?? this.transactionId,
      timestamp: timestamp ?? this.timestamp,
      transactionType: transactionType ?? this.transactionType,
    );
  }

  @override
  String toString() {
    return 'QRTransactionData(userId: $userId, userName: $userName, amount: ₹$amount, purpose: $purpose)';
  }
}
