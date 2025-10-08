import 'dart:convert';

/// Token model for MeshPay tokenized wallet transfers
/// Represents a payment token that can be relayed across mesh network
class Token {
  final String txId; // Unique transaction ID (UUID)
  final String from; // Sender device ID
  final String to; // Recipient device ID
  final int amount; // Token amount
  final String nonce; // Base64-encoded AES-GCM nonce (12 bytes)
  final String ephemeralPub; // Base64-encoded ephemeral public key for ECDH
  final String cipher; // Base64-encoded encrypted payload
  final String sig; // Base64-encoded Ed25519 signature
  final int timestamp; // Unix timestamp in milliseconds
  final int ttl; // Time-to-live / hop count
  final Map<String, dynamic>?
      metadata; // Additional encrypted data (e.g., API tokens)

  Token({
    required this.txId,
    required this.from,
    required this.to,
    required this.amount,
    required this.nonce,
    required this.ephemeralPub,
    required this.cipher,
    required this.sig,
    required this.timestamp,
    required this.ttl,
    this.metadata,
  });

  /// Create Token from JSON
  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      txId: json['tx_id'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      amount: json['amount'] as int,
      nonce: json['nonce'] as String,
      ephemeralPub: json['ephemeral_pub'] as String,
      cipher: json['cipher'] as String,
      sig: json['sig'] as String,
      timestamp: json['timestamp'] as int,
      ttl: json['ttl'] as int,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert Token to JSON
  Map<String, dynamic> toJson() {
    final json = {
      'tx_id': txId,
      'from': from,
      'to': to,
      'amount': amount,
      'nonce': nonce,
      'ephemeral_pub': ephemeralPub,
      'cipher': cipher,
      'sig': sig,
      'timestamp': timestamp,
      'ttl': ttl,
    };

    if (metadata != null) {
      json['metadata'] = metadata!;
    }

    return json;
  }

  /// Serialize to compact base64 for BLE advertisement
  /// Note: This may exceed BLE advertising payload limits (~22 bytes)
  /// In production, use token_ref (tx_id hash) + GATT read for full token
  String toCompactBase64() {
    final jsonStr = jsonEncode(toJson());
    final bytes = utf8.encode(jsonStr);
    return base64Encode(bytes);
  }

  /// Deserialize from compact base64
  static Token fromCompactBase64(String base64Str) {
    final bytes = base64Decode(base64Str);
    final jsonStr = utf8.decode(bytes);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    return Token.fromJson(json);
  }

  /// Create a copy with modified fields
  Token copyWith({
    String? txId,
    String? from,
    String? to,
    int? amount,
    String? nonce,
    String? ephemeralPub,
    String? cipher,
    String? sig,
    int? timestamp,
    int? ttl,
  }) {
    return Token(
      txId: txId ?? this.txId,
      from: from ?? this.from,
      to: to ?? this.to,
      amount: amount ?? this.amount,
      nonce: nonce ?? this.nonce,
      ephemeralPub: ephemeralPub ?? this.ephemeralPub,
      cipher: cipher ?? this.cipher,
      sig: sig ?? this.sig,
      timestamp: timestamp ?? this.timestamp,
      ttl: ttl ?? this.ttl,
    );
  }

  /// Decrement TTL for relay
  Token decrementTtl() {
    return copyWith(ttl: ttl - 1);
  }

  @override
  String toString() {
    return 'Token(txId: $txId, from: $from, to: $to, amount: $amount, ttl: $ttl)';
  }
}

/// Transaction status for UI display
enum TxStatus {
  pending, // Created but not yet relayed
  relayed, // Broadcasted to mesh network
  uploaded, // Received by gateway
  confirmed, // Confirmed by server/gateway
  failed, // Failed to process
}

/// Transaction record for local tracking
class TxRecord {
  final Token token;
  final TxStatus status;
  final int hops; // Number of relays observed
  final DateTime createdAt;
  final DateTime? confirmedAt;

  TxRecord({
    required this.token,
    required this.status,
    this.hops = 0,
    required this.createdAt,
    this.confirmedAt,
  });

  TxRecord copyWith({
    Token? token,
    TxStatus? status,
    int? hops,
    DateTime? createdAt,
    DateTime? confirmedAt,
  }) {
    return TxRecord(
      token: token ?? this.token,
      status: status ?? this.status,
      hops: hops ?? this.hops,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token.toJson(),
      'status': status.toString().split('.').last,
      'hops': hops,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'confirmedAt': confirmedAt?.millisecondsSinceEpoch,
    };
  }

  factory TxRecord.fromJson(Map<String, dynamic> json) {
    return TxRecord(
      token: Token.fromJson(json['token'] as Map<String, dynamic>),
      status: TxStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TxStatus.pending,
      ),
      hops: json['hops'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['confirmedAt'] as int)
          : null,
    );
  }
}
