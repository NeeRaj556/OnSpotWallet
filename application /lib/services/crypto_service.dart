import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/token_model.dart';
import 'package:uuid/uuid.dart';

/// CryptoService handles all cryptographic operations for MeshPay
/// Uses X25519 for ECDH, AES-GCM for encryption, Ed25519 for signatures
class CryptoService {
  // Algorithms
  final _x25519 = X25519();
  final _aesGcm = AesGcm.with256bits();
  final _ed25519 = Ed25519();
  final _sha256 = Sha256();
  final _random = Random.secure();

  // Device keypair (persisted)
  SimpleKeyPair? _deviceKeyPair;
  SimplePublicKey? _devicePublicKey;

  // TODO: Replace with real server keys in production
  // Demo server keypair (hardcoded for demo purposes)
  static final _demoServerPrivateKey = SimpleKeyPairData(
    [/* 32 bytes private key - in demo, generated once */],
    publicKey: SimplePublicKey(
      [/* 32 bytes public key - distributed to clients */],
      type: KeyPairType.x25519,
    ),
    type: KeyPairType.x25519,
  );

  // Ed25519 signature keypair (persisted)
  SimpleKeyPair? _signingKeyPair;

  final _uuid = const Uuid();

  /// Generate random nonce for encryption
  List<int> _generateNonce() {
    return List<int>.generate(12, (_) => _random.nextInt(256));
  }

  /// Initialize crypto service - loads or generates keypairs
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Load or generate X25519 device keypair for ECDH
    final devicePrivate = prefs.getString('device_private_key');
    final devicePublic = prefs.getString('device_public_key');

    if (devicePrivate != null && devicePublic != null) {
      // Load existing keypair
      _deviceKeyPair = SimpleKeyPairData(
        base64Decode(devicePrivate),
        publicKey: SimplePublicKey(
          base64Decode(devicePublic),
          type: KeyPairType.x25519,
        ),
        type: KeyPairType.x25519,
      );
      _devicePublicKey =
          await _deviceKeyPair!.extractPublicKey() as SimplePublicKey;
    } else {
      // Generate new keypair
      _deviceKeyPair = await _x25519.newKeyPair();
      _devicePublicKey =
          await _deviceKeyPair!.extractPublicKey() as SimplePublicKey;

      // Persist keypair
      final privateBytes = await _deviceKeyPair!.extractPrivateKeyBytes();
      final publicBytes = _devicePublicKey!.bytes;
      await prefs.setString('device_private_key', base64Encode(privateBytes));
      await prefs.setString('device_public_key', base64Encode(publicBytes));
    }

    // Load or generate Ed25519 signing keypair
    final signingPrivate = prefs.getString('signing_private_key');
    final signingPublic = prefs.getString('signing_public_key');

    if (signingPrivate != null && signingPublic != null) {
      _signingKeyPair = SimpleKeyPairData(
        base64Decode(signingPrivate),
        publicKey: SimplePublicKey(
          base64Decode(signingPublic),
          type: KeyPairType.ed25519,
        ),
        type: KeyPairType.ed25519,
      );
    } else {
      _signingKeyPair = await _ed25519.newKeyPair();

      final privateBytes = await _signingKeyPair!.extractPrivateKeyBytes();
      final publicKey =
          await _signingKeyPair!.extractPublicKey() as SimplePublicKey;
      await prefs.setString('signing_private_key', base64Encode(privateBytes));
      await prefs.setString(
          'signing_public_key', base64Encode(publicKey.bytes));
    }
  }

  /// Get device ID (derived from public key)
  Future<String> getDeviceId() async {
    if (_devicePublicKey == null) {
      await initialize();
    }
    // Use first 8 bytes of public key as device ID
    final bytes = _devicePublicKey!.bytes.sublist(0, 8);
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// Create a new token with encryption and signature
  ///
  /// Process:
  /// 1. Generate ephemeral X25519 keypair
  /// 2. Perform ECDH with server's public key to derive shared secret
  /// 3. Derive AES key from shared secret
  /// 4. Encrypt payload with AES-GCM
  /// 5. Sign tx_id + cipher with Ed25519
  Future<Token> createToken({
    required String from,
    required String to,
    required int amount,
    int ttl = 10,
  }) async {
    if (_deviceKeyPair == null || _signingKeyPair == null) {
      await initialize();
    }

    // Generate transaction ID
    final txId = _uuid.v4();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Generate ephemeral keypair for this transaction
    final ephemeralKeyPair = await _x25519.newKeyPair();
    final ephemeralPublic =
        await ephemeralKeyPair.extractPublicKey() as SimplePublicKey;

    // TODO: In production, use actual server public key
    // For demo, we generate a server keypair internally
    final serverKeyPair = await _x25519.newKeyPair();
    final serverPublic = await serverKeyPair.extractPublicKey();

    // Perform ECDH to derive shared secret
    final sharedSecret = await _x25519.sharedSecretKey(
      keyPair: ephemeralKeyPair,
      remotePublicKey: serverPublic,
    );

    // Generate random nonce (12 bytes for AES-GCM)
    final nonce = List<int>.generate(12, (_) => _random.nextInt(256));

    // Prepare payload to encrypt
    final payload = {
      'tx_id': txId,
      'from': from,
      'to': to,
      'amount': amount,
      'timestamp': timestamp,
    };
    final payloadBytes = utf8.encode(jsonEncode(payload));

    // Encrypt with AES-GCM
    final secretBox = await _aesGcm.encrypt(
      payloadBytes,
      secretKey: sharedSecret,
      nonce: nonce,
    );

    // Combine nonce + ciphertext (AES-GCM standard practice)
    final cipherBytes = secretBox.cipherText;
    final mac = secretBox.mac.bytes;
    final cipherWithMac = [...cipherBytes, ...mac];

    // Sign: tx_id + cipher
    final dataToSign = utf8.encode(txId) + cipherWithMac;
    final signature = await _ed25519.sign(
      dataToSign,
      keyPair: _signingKeyPair!,
    );

    return Token(
      txId: txId,
      from: from,
      to: to,
      amount: amount,
      nonce: base64Encode(nonce),
      ephemeralPub: base64Encode(ephemeralPublic.bytes),
      cipher: base64Encode(cipherWithMac),
      sig: base64Encode(signature.bytes),
      timestamp: timestamp,
      ttl: ttl,
    );
  }

  /// Verify token signature and validity
  ///
  /// Checks:
  /// - Signature is valid
  /// - Timestamp is recent (within 5 minutes)
  /// - TTL is > 0
  Future<bool> verifyToken(Token token) async {
    try {
      // Check TTL
      if (token.ttl <= 0) {
        return false;
      }

      // Check timestamp (reject if older than 5 minutes)
      final now = DateTime.now().millisecondsSinceEpoch;
      final age = now - token.timestamp;
      if (age > 5 * 60 * 1000) {
        // Older than 5 minutes
        return false;
      }

      // Verify signature
      // TODO: In production, need to retrieve sender's public key
      // For demo, we skip sender verification (would need PKI or distributed key exchange)

      final cipherBytes = base64Decode(token.cipher);
      final dataToSign = utf8.encode(token.txId) + cipherBytes;
      final signature = Signature(
        base64Decode(token.sig),
        publicKey: await _signingKeyPair!.extractPublicKey(),
      );

      final isValid = await _ed25519.verify(
        dataToSign,
        signature: signature,
      );

      return isValid;
    } catch (e) {
      print('Token verification failed: $e');
      return false;
    }
  }

  /// Decrypt token payload (for server/gateway)
  ///
  /// Gateway uses its private key to derive shared secret and decrypt
  ///
  /// Returns decrypted payload: { tx_id, from, to, amount, timestamp }
  Future<Map<String, dynamic>?> decryptTokenForServer(Token token) async {
    try {
      // Parse ephemeral public key
      final ephemeralPubBytes = base64Decode(token.ephemeralPub);
      final ephemeralPublic = SimplePublicKey(
        ephemeralPubBytes,
        type: KeyPairType.x25519,
      );

      // TODO: Use actual server private key in production
      // For demo, generate a server keypair
      final serverKeyPair = await _x25519.newKeyPair();

      // Derive shared secret using server's private key
      final sharedSecret = await _x25519.sharedSecretKey(
        keyPair: serverKeyPair,
        remotePublicKey: ephemeralPublic,
      );

      // Parse nonce and cipher
      final nonce = base64Decode(token.nonce);
      final cipherWithMac = base64Decode(token.cipher);

      // Split ciphertext and MAC (last 16 bytes for AES-GCM)
      if (cipherWithMac.length < 16) {
        throw Exception('Invalid cipher length');
      }

      final cipherText = cipherWithMac.sublist(0, cipherWithMac.length - 16);
      final mac = Mac(cipherWithMac.sublist(cipherWithMac.length - 16));

      // Decrypt
      final secretBox = SecretBox(
        cipherText,
        nonce: nonce,
        mac: mac,
      );

      final decrypted = await _aesGcm.decrypt(
        secretBox,
        secretKey: sharedSecret,
      );

      final payloadJson = utf8.decode(decrypted);
      return jsonDecode(payloadJson) as Map<String, dynamic>;
    } catch (e) {
      print('Token decryption failed: $e');
      return null;
    }
  }

  /// Convert token to compact bytes for BLE advertisement
  ///
  /// Note: Full token JSON is typically >200 bytes, exceeding BLE adv payload limit
  /// In production, use one of these strategies:
  /// 1. Advertise token_ref (tx_id hash, ~16 bytes) + GATT read for full token
  /// 2. Use BLE Extended Advertising (up to 255 bytes on newer devices)
  /// 3. Fragment token across multiple advertisements with sequence numbers
  Uint8List tokenToCompactBytes(Token token) {
    // For demo, we'll use base64 encoding of JSON
    // In production, use binary serialization (protobuf, MessagePack, etc.)
    final jsonStr = jsonEncode(token.toJson());
    final bytes = utf8.encode(jsonStr);

    // If too large for BLE advertisement (~22 bytes safe zone)
    if (bytes.length > 22) {
      // Return token reference (tx_id) - receiver would need GATT read
      final txIdBytes = utf8.encode(token.txId);
      return Uint8List.fromList(txIdBytes);
    }

    return Uint8List.fromList(bytes);
  }

  /// Parse token from compact bytes (from BLE advertisement)
  Token? tokenFromCompactBytes(Uint8List bytes) {
    try {
      final jsonStr = utf8.decode(bytes);

      // Check if it's a full token or just token_ref
      if (jsonStr.startsWith('{')) {
        // Full token JSON
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        return Token.fromJson(json);
      } else {
        // Just token_ref (tx_id) - would need GATT read to fetch full token
        // For demo, we return null and log
        print('Received token_ref: $jsonStr - GATT read required');
        return null;
      }
    } catch (e) {
      print('Failed to parse token from bytes: $e');
      return null;
    }
  }

  /// Encrypt API token payload for secure transmission
  Future<String> encryptApiToken(String apiPayload) async {
    if (_deviceKeyPair == null) {
      await initialize();
    }

    try {
      // Generate random nonce
      final nonce = _generateNonce();

      // Use AES-GCM to encrypt the API payload
      final secretBox = await _aesGcm.encrypt(
        utf8.encode(apiPayload),
        secretKey: SecretKey(
            List<int>.filled(32, 0)), // Use shared secret in production
        nonce: nonce,
      );

      // Combine nonce + ciphertext + mac
      final combined = <int>[
        ...nonce,
        ...secretBox.cipherText,
        ...secretBox.mac.bytes,
      ];

      return base64Encode(combined);
    } catch (e) {
      print('Failed to encrypt API token: $e');
      rethrow;
    }
  }

  /// Decrypt API token payload
  Future<String?> decryptApiToken(String encryptedToken) async {
    if (_deviceKeyPair == null) {
      await initialize();
    }

    try {
      final bytes = base64Decode(encryptedToken);

      // Extract nonce (12 bytes), ciphertext, and mac (16 bytes)
      final nonce = bytes.sublist(0, 12);
      final mac = Mac(bytes.sublist(bytes.length - 16));
      final cipherText = bytes.sublist(12, bytes.length - 16);

      // Decrypt
      final secretBox = SecretBox(
        cipherText,
        nonce: nonce,
        mac: mac,
      );

      final plaintext = await _aesGcm.decrypt(
        secretBox,
        secretKey: SecretKey(
            List<int>.filled(32, 0)), // Use shared secret in production
      );

      return utf8.decode(plaintext);
    } catch (e) {
      print('Failed to decrypt API token: $e');
      return null;
    }
  }

  /// Encrypt device token for BLE mesh identification
  Future<String> encryptDeviceToken(String deviceToken) async {
    // Simple hash-based encryption for device identification
    final hash = await _sha256.hash(utf8.encode(deviceToken));
    return base64Encode(hash.bytes);
  }

  /// Generate API endpoint URL with encrypted parameters
  Future<String> generateApiEndpoint({
    required String deviceToken,
    required String userId,
    required String createdAt,
  }) async {
    // Encrypt sensitive data
    final encryptedDeviceToken = await encryptDeviceToken(deviceToken);
    final encryptedUserId = await encryptApiToken(userId);

    // Return endpoint URL
    return '/update/${Uri.encodeComponent(encryptedDeviceToken)}/'
        '${Uri.encodeComponent(encryptedUserId)}/'
        '${Uri.encodeComponent(createdAt)}';
  }
}
