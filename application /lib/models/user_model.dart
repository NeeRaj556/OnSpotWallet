import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final double balance;
  final double onlineBalance;
  final double offlineBalance;
  final String currency;
  final String? profilePicture;
  final String? address;
  final String? phone;
  final DateTime createdAt;

  // Transaction limits
  final double onlineLimit;
  final double offlineLimit;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.balance = 0.0,
    this.onlineBalance = 0.0,
    this.offlineBalance = 0.0,
    this.currency = '\$',
    this.profilePicture,
    this.address,
    this.phone,
    required this.createdAt,
    this.onlineLimit = 1000.0,
    this.offlineLimit = 100.0,
  });

  // From JSON - handles API response format
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'user',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      onlineBalance: (json['onlineBalance'] as num?)?.toDouble() ?? 0.0,
      offlineBalance: (json['offlineBalance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? '\$',
      profilePicture: json['profilePicture'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      onlineLimit: (json['onlineLimit'] as num?)?.toDouble() ?? 1000.0,
      offlineLimit: (json['offlineLimit'] as num?)?.toDouble() ?? 100.0,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'balance': balance,
      'onlineBalance': onlineBalance,
      'offlineBalance': offlineBalance,
      'currency': currency,
      'profilePicture': profilePicture,
      'address': address,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'onlineLimit': onlineLimit,
      'offlineLimit': offlineLimit,
    };
  }

  // CopyWith method for immutability
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    double? balance,
    double? onlineBalance,
    double? offlineBalance,
    String? currency,
    String? profilePicture,
    String? address,
    String? phone,
    DateTime? createdAt,
    double? onlineLimit,
    double? offlineLimit,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      balance: balance ?? this.balance,
      onlineBalance: onlineBalance ?? this.onlineBalance,
      offlineBalance: offlineBalance ?? this.offlineBalance,
      currency: currency ?? this.currency,
      profilePicture: profilePicture ?? this.profilePicture,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      onlineLimit: onlineLimit ?? this.onlineLimit,
      offlineLimit: offlineLimit ?? this.offlineLimit,
    );
  }

  // Static mock data for development
  static UserModel get mockUser => UserModel(
        id: 'user_123456789',
        name: 'Demo User',
        email: 'demo@onspot.com',
        role: 'user',
        balance: 1000.0,
        onlineBalance: 800.0,
        offlineBalance: 200.0,
        currency: '\$',
        profilePicture: null,
        address: '123 Main Street, New York, NY 10001',
        phone: '+1234567890',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        onlineLimit: 1000.0,
        offlineLimit: 100.0,
      );

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, balance: $currency$balance)';
  }
}
