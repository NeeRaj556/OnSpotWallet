// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      sender: json['sender'] == null
          ? null
          : UserModel.fromJson(json['sender'] as Map<String, dynamic>),
      receiver: json['receiver'] == null
          ? null
          : UserModel.fromJson(json['receiver'] as Map<String, dynamic>),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      receivedAt: json['receivedAt'] == null
          ? null
          : DateTime.parse(json['receivedAt'] as String),
      sentAt: json['sentAt'] == null
          ? null
          : DateTime.parse(json['sentAt'] as String),
      transactedAt: json['transactedAt'] == null
          ? null
          : DateTime.parse(json['transactedAt'] as String),
      mode: $enumDecode(_$TransactionModeEnumMap, json['mode']),
      updatedBy: json['updatedBy'] as String?,
      amount: (json['amount'] as num).toDouble(),
      purpose: json['purpose'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'sender': instance.sender,
      'receiver': instance.receiver,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'receivedAt': instance.receivedAt?.toIso8601String(),
      'sentAt': instance.sentAt?.toIso8601String(),
      'transactedAt': instance.transactedAt?.toIso8601String(),
      'mode': _$TransactionModeEnumMap[instance.mode]!,
      'updatedBy': instance.updatedBy,
      'amount': instance.amount,
      'purpose': instance.purpose,
      'status': instance.status,
    };

const _$TransactionModeEnumMap = {
  TransactionMode.offline: 'offline',
  TransactionMode.online: 'online',
};
