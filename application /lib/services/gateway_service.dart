import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/token_model.dart';
import 'crypto_service.dart';

/// GatewayService handles Wi-Fi detection and token upload to server
/// Simulates a local HTTP endpoint for demo purposes
class GatewayService {
  final CryptoService _cryptoService;
  final Connectivity _connectivity = Connectivity();

  bool _isGatewayMode = false;
  final Set<String> _confirmedTxIds = {};

  // Stream controller for gateway events
  final _gatewayEventsController = StreamController<GatewayEvent>.broadcast();
  Stream<GatewayEvent> get gatewayEvents => _gatewayEventsController.stream;

  StreamSubscription? _connectivitySubscription;

  GatewayService(this._cryptoService);

  /// Initialize gateway service
  Future<void> initialize() async {
    await _loadConfirmedTxIds();
    await _checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      // connectivity_plus 5.x returns ConnectivityResult, not List
      _onConnectivityChanged([result]);
    });
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _gatewayEventsController.close();
  }

  /// Load confirmed transaction IDs from storage
  Future<void> _loadConfirmedTxIds() async {
    final prefs = await SharedPreferences.getInstance();
    final confirmed = prefs.getStringList('confirmed_tx_ids') ?? [];
    _confirmedTxIds.addAll(confirmed);
  }

  /// Save confirmed transaction IDs to storage
  Future<void> _saveConfirmedTxIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('confirmed_tx_ids', _confirmedTxIds.toList());
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    // connectivity_plus 5.x returns ConnectivityResult, not List
    _onConnectivityChanged([result]);
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    // Check if we have Wi-Fi or mobile connectivity
    final hasWifi = results.contains(ConnectivityResult.wifi);
    final hasMobile = results.contains(ConnectivityResult.mobile);
    final hasEthernet = results.contains(ConnectivityResult.ethernet);

    final hasConnectivity = hasWifi || hasMobile || hasEthernet;

    // Prefer Wi-Fi for gateway mode (hotspot/local network)
    if (hasWifi && _isGatewayMode) {
      _gatewayEventsController.add(
        GatewayEvent(
          type: GatewayEventType.connected,
          message: 'Gateway online - WiFi connected',
        ),
      );
    } else if (!hasConnectivity && _isGatewayMode) {
      _gatewayEventsController.add(
        GatewayEvent(
          type: GatewayEventType.disconnected,
          message: 'Gateway offline - No connectivity',
        ),
      );
    }
  }

  /// Enable or disable gateway mode
  Future<void> setGatewayMode(bool enabled) async {
    _isGatewayMode = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gateway_mode', enabled);

    if (enabled) {
      await _checkConnectivity();
      _gatewayEventsController.add(
        GatewayEvent(
          type: GatewayEventType.modeChanged,
          message: 'Gateway mode enabled',
        ),
      );
    } else {
      _gatewayEventsController.add(
        GatewayEvent(
          type: GatewayEventType.modeChanged,
          message: 'Gateway mode disabled',
        ),
      );
    }
  }

  /// Check if device is in gateway mode
  bool get isGatewayMode => _isGatewayMode;

  /// Check if gateway has connectivity
  Future<bool> hasConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    // connectivity_plus 5.x returns ConnectivityResult, not List
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet;
  }

  /// Upload token to server (simulated)
  ///
  /// In production, this would:
  /// 1. Make HTTP POST to server endpoint
  /// 2. Server decrypts token, validates, and processes transaction
  /// 3. Server returns confirmation
  ///
  /// For demo:
  /// 1. Decrypt token locally (simulating server decryption)
  /// 2. Validate payload
  /// 3. Mark as confirmed
  Future<bool> uploadToken(Token token) async {
    try {
      // Check if gateway mode is enabled
      if (!_isGatewayMode) {
        print('Gateway mode is disabled - cannot upload');
        return false;
      }

      // Check connectivity
      final hasConn = await hasConnectivity();
      if (!hasConn) {
        print('No connectivity - cannot upload');
        _gatewayEventsController.add(
          GatewayEvent(
            type: GatewayEventType.uploadFailed,
            message: 'Upload failed: No connectivity',
            txId: token.txId,
          ),
        );
        return false;
      }

      // Check if already confirmed
      if (_confirmedTxIds.contains(token.txId)) {
        print('Token already confirmed: ${token.txId}');
        return true;
      }

      print('Uploading token to server: ${token.txId}');

      // Simulate server processing
      // In production, this would be:
      // final response = await http.post('https://server.com/tokens', body: token.toJson());

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Decrypt token (simulating server-side decryption)
      final payload = await _cryptoService.decryptTokenForServer(token);

      if (payload == null) {
        print('Failed to decrypt token');
        _gatewayEventsController.add(
          GatewayEvent(
            type: GatewayEventType.uploadFailed,
            message: 'Upload failed: Invalid token',
            txId: token.txId,
          ),
        );
        return false;
      }

      // Validate payload
      if (payload['tx_id'] != token.txId) {
        print('Token ID mismatch');
        return false;
      }

      // TODO: In production, server would:
      // 1. Verify signature with sender's public key
      // 2. Check sender has sufficient balance
      // 3. Update balances in database
      // 4. Return confirmation

      // Mark as confirmed
      _confirmedTxIds.add(token.txId);
      await _saveConfirmedTxIds();

      print('Token confirmed: ${token.txId}');

      _gatewayEventsController.add(
        GatewayEvent(
          type: GatewayEventType.tokenConfirmed,
          message: 'Token uploaded and confirmed',
          txId: token.txId,
          amount: token.amount,
        ),
      );

      return true;
    } catch (e) {
      print('Error uploading token: $e');
      _gatewayEventsController.add(
        GatewayEvent(
          type: GatewayEventType.uploadFailed,
          message: 'Upload failed: $e',
          txId: token.txId,
        ),
      );
      return false;
    }
  }

  /// Check if a token is already confirmed
  bool isTokenConfirmed(String txId) {
    return _confirmedTxIds.contains(txId);
  }

  /// Get list of confirmed transaction IDs
  List<String> getConfirmedTxIds() {
    return _confirmedTxIds.toList();
  }
}

/// Gateway event types
enum GatewayEventType {
  connected,
  disconnected,
  modeChanged,
  tokenConfirmed,
  uploadFailed,
}

/// Gateway event
class GatewayEvent {
  final GatewayEventType type;
  final String message;
  final String? txId;
  final int? amount;

  GatewayEvent({
    required this.type,
    required this.message,
    this.txId,
    this.amount,
  });

  @override
  String toString() {
    return 'GatewayEvent(type: $type, message: $message, txId: $txId)';
  }
}
