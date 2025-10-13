import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'transaction_model.g.dart';

enum TransactionMode {
  @JsonValue('offline')
  offline,
  @JsonValue('online')
  online,
}

@JsonSerializable()
class TransactionModel {
  final String id;
  final String senderId;
  final String receiverId;
  final UserModel? sender;
  final UserModel? receiver;
  final double? latitude;
  final double? longitude;
  final DateTime? receivedAt;
  final DateTime? sentAt;
  final DateTime? transactedAt;
  final TransactionMode mode;
  final String? updatedBy;
  final double amount;
  final String? purpose;
  final String? status;

  const TransactionModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.sender,
    this.receiver,
    this.latitude,
    this.longitude,
    this.receivedAt,
    this.sentAt,
    this.transactedAt,
    required this.mode,
    this.updatedBy,
    required this.amount,
    this.purpose,
    this.status,
  });

  // From JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  // To JSON
  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  // CopyWith method
  TransactionModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    UserModel? sender,
    UserModel? receiver,
    double? latitude,
    double? longitude,
    DateTime? receivedAt,
    DateTime? sentAt,
    DateTime? transactedAt,
    TransactionMode? mode,
    String? updatedBy,
    double? amount,
    String? purpose,
    String? status,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      receivedAt: receivedAt ?? this.receivedAt,
      sentAt: sentAt ?? this.sentAt,
      transactedAt: transactedAt ?? this.transactedAt,
      mode: mode ?? this.mode,
      updatedBy: updatedBy ?? this.updatedBy,
      amount: amount ?? this.amount,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
    );
  }

  // Mock transactions for development
  static List<TransactionModel> get mockTransactions => [
        TransactionModel(
          id: 'tx_001',
          senderId: 'user_123456789',
          receiverId: 'user_987654321',
          sender: UserModel.mockUser,
          receiver: null,
          latitude: 40.7128,
          longitude: -74.0060,
          receivedAt: DateTime.now().subtract(const Duration(hours: 2)),
          sentAt: DateTime.now().subtract(const Duration(hours: 2)),
          transactedAt: DateTime.now().subtract(const Duration(hours: 2)),
          mode: TransactionMode.online,
          amount: 250.0,
          purpose: 'Payment for lunch',
          status: 'completed',
        ),
        TransactionModel(
          id: 'tx_002',
          senderId: 'user_987654321',
          receiverId: 'user_123456789',
          sender: null,
          receiver: UserModel.mockUser,
          latitude: 40.7128,
          longitude: -74.0060,
          receivedAt: DateTime.now().subtract(const Duration(days: 1)),
          sentAt: DateTime.now().subtract(const Duration(days: 1)),
          transactedAt: DateTime.now().subtract(const Duration(days: 1)),
          mode: TransactionMode.offline,
          amount: 500.0,
          purpose: 'Grocery shopping',
          status: 'completed',
        ),
        TransactionModel(
          id: 'tx_003',
          senderId: 'user_123456789',
          receiverId: 'user_111222333',
          sender: UserModel.mockUser,
          receiver: null,
          latitude: null,
          longitude: null,
          receivedAt: DateTime.now().subtract(const Duration(days: 2)),
          sentAt: DateTime.now().subtract(const Duration(days: 2)),
          transactedAt: DateTime.now().subtract(const Duration(days: 2)),
          mode: TransactionMode.online,
          amount: 1200.0,
          purpose: 'Bill payment',
          status: 'completed',
        ),
      ];

  @override
  String toString() {
    return 'TransactionModel(id: $id, amount: $amount, mode: $mode, status: $status)';
  }
}
