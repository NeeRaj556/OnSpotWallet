import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String role;
  final String email;
  final String? address;
  final String phone;
  final String? profilePicture;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final DateTime? locationUpdatedAt;
  final DateTime? deletedAt;
  final DateTime updatedAt;
  final String? type;
  final String currency;
  final double balance;
  final double offlineLimit;
  final double onlineLimit;

  const UserModel({
    required this.id,
    required this.name,
    this.role = 'user',
    required this.email,
    this.address,
    required this.phone,
    this.profilePicture,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.locationUpdatedAt,
    this.deletedAt,
    required this.updatedAt,
    this.type,
    this.currency = '\$',
    this.balance = 0.0,
    this.offlineLimit = 100.0,
    this.onlineLimit = 1000.0,
  });

  // From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // To JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // CopyWith method for immutability
  UserModel copyWith({
    String? id,
    String? name,
    String? role,
    String? email,
    String? address,
    String? phone,
    String? profilePicture,
    DateTime? createdAt,
    double? latitude,
    double? longitude,
    DateTime? locationUpdatedAt,
    DateTime? deletedAt,
    DateTime? updatedAt,
    String? type,
    String? currency,
    double? balance,
    double? offlineLimit,
    double? onlineLimit,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationUpdatedAt: locationUpdatedAt ?? this.locationUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      offlineLimit: offlineLimit ?? this.offlineLimit,
      onlineLimit: onlineLimit ?? this.onlineLimit,
    );
  }

  // Static mock data for development
  static UserModel get mockUser => UserModel(
        id: 'user_123456789',
        name: 'John Doe',
        role: 'user',
        email: 'john.doe@onspot.com',
        address: '123 Main Street, New York, NY 10001',
        phone: '+1234567890',
        profilePicture: null,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        latitude: 40.7128,
        longitude: -74.0060,
        locationUpdatedAt: DateTime.now(),
        deletedAt: null,
        updatedAt: DateTime.now(),
        type: 'premium',
        currency: '\$',
        balance: 1000.0,
        offlineLimit: 100.0,
        onlineLimit: 1000.0,
      );

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, balance: $currency$balance)';
  }
}
