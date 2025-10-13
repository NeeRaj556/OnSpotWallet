// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String? ?? 'user',
      email: json['email'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String,
      profilePicture: json['profilePicture'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationUpdatedAt: json['locationUpdatedAt'] == null
          ? null
          : DateTime.parse(json['locationUpdatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      type: json['type'] as String?,
      currency: json['currency'] as String? ?? '\$',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      offlineLimit: (json['offlineLimit'] as num?)?.toDouble() ?? 100.0,
      onlineLimit: (json['onlineLimit'] as num?)?.toDouble() ?? 1000.0,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'role': instance.role,
      'email': instance.email,
      'address': instance.address,
      'phone': instance.phone,
      'profilePicture': instance.profilePicture,
      'created_at': instance.createdAt.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'locationUpdatedAt': instance.locationUpdatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'type': instance.type,
      'currency': instance.currency,
      'balance': instance.balance,
      'offlineLimit': instance.offlineLimit,
      'onlineLimit': instance.onlineLimit,
    };
