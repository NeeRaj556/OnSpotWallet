import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/token_model.dart';
import 'crypto_service.dart';
import 'gateway_service.dart';

/// BLEService handles Bluetooth Low Energy mesh networking
/// Implements token broadcasting and scanning for mesh relay
///
/// IMPORTANT NOTES:
/// - BLE advertising payload is limited to ~22-31 bytes (manufacturer data)
/// - iOS has additional restrictions on background BLE
/// - Android 5.0+ supports BLE peripheral mode (advertising)
/// - Some devices may not support simultaneous scanning and advertising
class BLEService {
  final CryptoService _cryptoService;
  final GatewayService _gatewayService;

  bool _isScanning = false;
  bool _isAdvertising = false;
  bool _allowRelay = false;

  // Seen cache for deduplication (expires after 5 minutes)
  final Map<String, DateTime> _seenTokens = {};
  static const _seenCacheDuration = Duration(minutes: 5);

  // Stream controller for BLE events
  final _bleEventsController = StreamController<BLEEvent>.broadcast();
  Stream<BLEEvent> get bleEvents => _bleEventsController.stream;

  StreamSubscription? _scanSubscription;

  BLEService(this._cryptoService, this._gatewayService);

  /// Initialize BLE service
  Future<void> initialize() async {
    // Check if Bluetooth is available
    try {
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        print('BLE not supported on this device');
        _bleEventsController.add(
          BLEEvent(
            type: BLEEventType.error,
            message: 'BLE not supported',
          ),
        );
        return;
      }

      // Check Bluetooth adapter state
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        print('Bluetooth is off');
        _bleEventsController.add(
          BLEEvent(
            type: BLEEventType.error,
            message: 'Bluetooth is off - please enable it',
          ),
        );
      }
    } catch (e) {
      print('Error initializing BLE: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    stopScanning();
    _bleEventsController.close();
  }

  /// Set relay mode
  void setAllowRelay(bool allow) {
    _allowRelay = allow;
    _bleEventsController.add(
      BLEEvent(
        type: BLEEventType.modeChanged,
        message: allow ? 'Relay enabled' : 'Relay disabled',
      ),
    );
  }

  /// Check if relay is allowed
  bool get allowRelay => _allowRelay;

  /// Start scanning for BLE advertisements
  Future<void> startScanning() async {
    if (_isScanning) {
      print('Already scanning');
      return;
    }

    try {
      _isScanning = true;

      // Start scanning
      // Note: iOS requires specific service UUIDs to scan in background
      await FlutterBluePlus.startScan(
        timeout: const Duration(hours: 1), // Long scan for demo
      );

      // Listen to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (var result in results) {
          _processScanResult(result);
        }
      });

      _bleEventsController.add(
        BLEEvent(
          type: BLEEventType.scanStarted,
          message: 'BLE scanning started',
        ),
      );
    } catch (e) {
      print('Error starting BLE scan: $e');
      _isScanning = false;
      _bleEventsController.add(
        BLEEvent(
          type: BLEEventType.error,
          message: 'Failed to start scanning: $e',
        ),
      );
    }
  }

  /// Stop scanning
  Future<void> stopScanning() async {
    if (!_isScanning) {
      return;
    }

    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _isScanning = false;

      _bleEventsController.add(
        BLEEvent(
          type: BLEEventType.scanStopped,
          message: 'BLE scanning stopped',
        ),
      );
    } catch (e) {
      print('Error stopping BLE scan: $e');
    }
  }

  /// Process a scan result
  void _processScanResult(ScanResult result) {
    try {
      // Extract manufacturer data (where we store token data)
      final manufacturerData = result.advertisementData.manufacturerData;

      if (manufacturerData.isEmpty) {
        return;
      }

      // For demo, we use company ID 0xFFFF (reserved for demos)
      // In production, use your assigned company ID
      final tokenBytes = manufacturerData[0xFFFF];
      if (tokenBytes == null || tokenBytes.isEmpty) {
        return;
      }

      // Try to parse token
      final token =
          _cryptoService.tokenFromCompactBytes(Uint8List.fromList(tokenBytes));

      if (token == null) {
        // Might be token_ref - would need GATT read
        print('Received token_ref - GATT read not implemented in demo');
        return;
      }

      // Process received token
      _processReceivedToken(token);
    } catch (e) {
      print('Error processing scan result: $e');
    }
  }

  /// Process a received token
  Future<void> _processReceivedToken(Token token) async {
    // Check if already seen (deduplication)
    if (_seenTokens.containsKey(token.txId)) {
      final seenTime = _seenTokens[token.txId]!;
      if (DateTime.now().difference(seenTime) < _seenCacheDuration) {
        // Already seen recently, ignore
        return;
      }
    }

    // Mark as seen
    _seenTokens[token.txId] = DateTime.now();
    _cleanupSeenCache();

    print('Received token via BLE: ${token.txId}');

    // Verify token
    final isValid = await _cryptoService.verifyToken(token);
    if (!isValid) {
      print('Invalid token signature or expired');
      _bleEventsController.add(
        BLEEvent(
          type: BLEEventType.tokenReceived,
          message: 'Received invalid token',
          txId: token.txId,
        ),
      );
      return;
    }

    _bleEventsController.add(
      BLEEvent(
        type: BLEEventType.tokenReceived,
        message: 'Valid token received',
        token: token,
        txId: token.txId,
      ),
    );

    // If device is gateway, try to upload
    if (_gatewayService.isGatewayMode) {
      final uploaded = await _gatewayService.uploadToken(token);
      if (uploaded) {
        print('Token uploaded to gateway: ${token.txId}');
      }
    }

    // If relay is enabled and TTL > 0, rebroadcast
    if (_allowRelay && token.ttl > 0) {
      final relayToken = token.decrementTtl();
      await broadcastToken(relayToken);

      _bleEventsController.add(
        BLEEvent(
          type: BLEEventType.tokenRelayed,
          message: 'Token relayed (TTL: ${relayToken.ttl})',
          token: relayToken,
          txId: relayToken.txId,
        ),
      );
    }
  }

  /// Broadcast a token via BLE advertising
  ///
  /// NOTE: BLE advertising limitations:
  /// - Payload size: ~22-31 bytes for manufacturer data (varies by device)
  /// - iOS: Cannot advertise in background without MFi license
  /// - Android: Requires peripheral mode support (Android 5.0+)
  ///
  /// Strategies for large tokens:
  /// 1. Advertise token_ref (tx_id hash), full token via GATT read
  /// 2. Use BLE Extended Advertising (255 bytes, newer devices)
  /// 3. Fragment token across multiple advertisements with sequence numbers
  Future<void> broadcastToken(Token token) async {
    try {
      final tokenBytes = _cryptoService.tokenToCompactBytes(token);
      if (tokenBytes.length > 22) {
        print(
            'WARNING: Token size (${tokenBytes.length} bytes) exceeds safe BLE advertising limit');
        print('Consider using token_ref + GATT read strategy for production');

        // For demo, we'll proceed anyway, but note this may not work on all devices
        _bleEventsController.add(
          BLEEvent(
            type: BLEEventType.warning,
            message: 'Token size exceeds BLE advertising limit',
            txId: token.txId,
          ),
        );
      }

      // NOTE: flutter_blue_plus doesn't support advertising (peripheral mode) directly
      // This is a platform limitation:
      // - iOS: No peripheral mode support without MFi
      // - Android: Requires flutter_ble_peripheral plugin
      //
      // For this demo, we simulate advertising by emitting events
      // In production, use:
      // - Android: flutter_ble_peripheral package
      // - iOS: Limited options, consider Multipeer Connectivity as alternative

      _isAdvertising = true;

      _bleEventsController.add(
        BLEEvent(
          type: BLEEventType.tokenBroadcast,
          message: 'Token broadcast (simulated)',
          token: token,
          txId: token.txId,
        ),
      );

      // Simulate advertising duration
      await Future.delayed(const Duration(seconds: 2));

      _isAdvertising = false;

      print('Token broadcast complete: ${token.txId}');
    } catch (e) {
      print('Error broadcasting token: $e');
      _isAdvertising = false;

      _bleEventsController.add(
        BLEEvent(
          type: BLEEventType.error,
          message: 'Broadcast failed: $e',
          txId: token.txId,
        ),
      );
    }
  }

  /// Clean up expired entries from seen cache
  void _cleanupSeenCache() {
    final now = DateTime.now();
    _seenTokens.removeWhere((key, value) {
      return now.difference(value) > _seenCacheDuration;
    });

    // Optional: Log cache size for debugging
    if (_seenTokens.length > 100) {
      print(
          'Seen cache size: ${_seenTokens.length} - consider bloom filter for production');
    }
  }

  /// Get count of seen tokens
  int get seenTokenCount => _seenTokens.length;

  /// Check if scanning
  bool get isScanning => _isScanning;

  /// Check if advertising
  bool get isAdvertising => _isAdvertising;
}

/// BLE event types
enum BLEEventType {
  scanStarted,
  scanStopped,
  tokenReceived,
  tokenBroadcast,
  tokenRelayed,
  modeChanged,
  warning,
  error,
}

/// BLE event
class BLEEvent {
  final BLEEventType type;
  final String message;
  final Token? token;
  final String? txId;

  BLEEvent({
    required this.type,
    required this.message,
    this.token,
    this.txId,
  });

  @override
  String toString() {
    return 'BLEEvent(type: $type, message: $message, txId: $txId)';
  }
}
