import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../services/crypto_service.dart';
import '../../../services/ble_service.dart';
import '../../../services/gateway_service.dart';
import '../../../models/token_model.dart';
import '../payment_screen/payment_confirmation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // User data
  String _userName = 'User';
  String _userEmail = '';
  String _deviceId = '';
  double _balance = 100.0; // Start with $100
  bool _isLoading = true;
  bool _isOnline = false; // Track online/offline status

  // MeshPay services
  late CryptoService _cryptoService;
  late GatewayService _gatewayService;
  late BLEService _bleService;

  // Settings
  bool _isGatewayMode = false;
  bool _allowRelay = false;
  bool _bleInitialized = false;

  // Transaction history
  final List<TxRecord> _transactions = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _checkConnectivity() async {
    if (!mounted) return;
    final hasConnectivity = await _gatewayService.hasConnectivity();
    if (mounted) {
      setState(() {
        _isOnline = hasConnectivity;
      });
    }
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize crypto service
      _cryptoService = CryptoService();
      await _cryptoService.initialize();

      // Get device ID
      _deviceId = await _cryptoService.getDeviceId();

      // Initialize gateway service
      _gatewayService = GatewayService(_cryptoService);
      await _gatewayService.initialize();

      // Check initial connectivity
      await _checkConnectivity();

      // Listen to gateway events
      _gatewayService.gatewayEvents.listen((event) {
        _handleGatewayEvent(event);
      });

      // Initialize BLE service
      _bleService = BLEService(_cryptoService, _gatewayService);
      await _bleService.initialize();
      _bleInitialized = true;

      // Listen to BLE events
      _bleService.bleEvents.listen((event) {
        _handleBLEEvent(event);
      });

      // Start BLE scanning
      await _bleService.startScanning();

      // Periodically check connectivity
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 30));
        if (mounted) {
          await _checkConnectivity();
          return true;
        }
        return false;
      });

      // Load user data
      await _loadUserData();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing services: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
      _userEmail = prefs.getString('user_email') ?? 'demo@example.com';
      _balance = prefs.getDouble('meshpay_balance') ?? 1000.0;
      _isGatewayMode = prefs.getBool('gateway_mode') ?? false;
      _allowRelay = prefs.getBool('allow_relay') ?? false;
    });

    // Apply settings
    if (_isGatewayMode) {
      await _gatewayService.setGatewayMode(true);
    }
    if (_allowRelay) {
      _bleService.setAllowRelay(true);
    }
  }

  Future<void> _saveBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('meshpay_balance', _balance);
  }

  void _handleGatewayEvent(GatewayEvent event) {
    if (!mounted) return;

    if (event.type == GatewayEventType.tokenConfirmed && event.txId != null) {
      // Find transaction and mark as confirmed
      final txIndex =
          _transactions.indexWhere((tx) => tx.token.txId == event.txId);
      if (txIndex != -1) {
        setState(() {
          _transactions[txIndex] = _transactions[txIndex].copyWith(
            status: TxStatus.confirmed,
            confirmedAt: DateTime.now(),
          );
        });

        // Play receive sound
        _playSound('assets/sounds/recv.mp3');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment confirmed: ${event.amount} tokens'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _handleBLEEvent(BLEEvent event) async {
    if (!mounted) return;

    if (event.type == BLEEventType.tokenReceived && event.token != null) {
      final token = event.token!;

      // Check if this is for us
      if (token.to == _deviceId) {
        // Decrypt and process encrypted API token if present
        if (token.metadata != null &&
            token.metadata!.containsKey('encrypted_api_token')) {
          try {
            final encryptedApiToken =
                token.metadata!['encrypted_api_token'] as String;
            final decryptedPayload =
                await _cryptoService.decryptApiToken(encryptedApiToken);

            if (decryptedPayload != null) {
              final apiData = jsonDecode(decryptedPayload);
              print('Received API data: ${apiData['endpoint']}');
              // In production, send this to your backend
              // await _sendToBackend(apiData);
            }
          } catch (e) {
            print('Error decrypting API token: $e');
          }
        }

        // Incoming payment - update balance with dollar amount
        final dollarAmount = token.amount.toDouble();

        setState(() {
          _balance += dollarAmount;
          _saveBalance();

          _transactions.add(TxRecord(
            token: token,
            status: TxStatus.confirmed,
            createdAt: DateTime.now(),
            confirmedAt: DateTime.now(),
          ));
        });

        _playSound('assets/sounds/receive.mp3');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Received \$${dollarAmount.toStringAsFixed(2)}!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Future<void> _playSound(String path) async {
    try {
      await _audioPlayer.play(AssetSource(path.replaceFirst('assets/', '')));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MeshPay Wallet'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.monitor),
            onPressed: () {
              // TODO: Navigate to network monitor
            },
            tooltip: 'Network Monitor',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Device Info Card
              _buildDeviceInfoCard(),
              const SizedBox(height: 16),

              // Balance Card
              _buildBalanceCard(),
              const SizedBox(height: 16),

              // Settings Card
              _buildSettingsCard(),
              const SizedBox(height: 16),

              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 24),

              // Transaction History
              _buildTransactionHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.devices,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Device Info',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('User', _userName),
            _buildInfoRow('Email', _userEmail),
            _buildInfoRow('Device ID', _deviceId),
            if (_bleInitialized)
              _buildInfoRow('BLE Status', '🟢 Active', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Balance',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isOnline ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isOnline ? 'ONLINE' : 'OFFLINE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${_balance.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 42,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Limit: \$${(_isOnline ? 1000 : 10).toStringAsFixed(2)} per transaction',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MeshPay Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Act as Gateway'),
              subtitle: const Text('Upload tokens to server when online'),
              value: _isGatewayMode,
              onChanged: (value) async {
                setState(() {
                  _isGatewayMode = value;
                });
                await _gatewayService.setGatewayMode(value);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('gateway_mode', value);
              },
            ),
            SwitchListTile(
              title: const Text('Allow Relay'),
              subtitle: const Text('Relay tokens to other devices'),
              value: _allowRelay,
              onChanged: (value) async {
                setState(() {
                  _allowRelay = value;
                });
                _bleService.setAllowRelay(value);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('allow_relay', value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showGenerateInvoiceDialog,
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Generate QR'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _scanQRCode,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _showMyQRCode,
          icon: const Icon(Icons.account_balance_wallet),
          label: const Text('My Wallet QR'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory() {
    if (_transactions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...(_transactions.reversed
            .take(10)
            .map((tx) => _buildTransactionTile(tx))),
      ],
    );
  }

  Widget _buildTransactionTile(TxRecord tx) {
    final isIncoming = tx.token.to == _deviceId;
    final statusColor = tx.status == TxStatus.confirmed
        ? Colors.green
        : tx.status == TxStatus.failed
            ? Colors.red
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncoming ? Colors.green[100] : Colors.blue[100],
          child: Icon(
            isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncoming ? Colors.green : Colors.blue,
          ),
        ),
        title: Text(
          '${isIncoming ? '+' : '-'}${tx.token.amount} tokens',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isIncoming ? Colors.green : Colors.red,
          ),
        ),
        subtitle: Text(
          '${isIncoming ? 'From' : 'To'}: ${isIncoming ? tx.token.from : tx.token.to}\n'
          '${tx.createdAt.toString().substring(0, 19)}',
        ),
        trailing: Chip(
          label: Text(
            tx.status.toString().split('.').last.toUpperCase(),
            style: const TextStyle(fontSize: 10),
          ),
          backgroundColor: statusColor.withValues(alpha: 0.2),
          labelStyle: TextStyle(color: statusColor),
        ),
        isThreeLine: true,
      ),
    );
  }

  // Generate Invoice Dialog
  Future<void> _showGenerateInvoiceDialog() async {
    final amountController = TextEditingController();
    final toController = TextEditingController();
    final ttlController = TextEditingController(text: '10');
    String? generatedQR;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Generate Payment QR'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (generatedQR != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: generatedQR!,
                        version: QrVersions.auto,
                        size: 200,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Show this QR to receive payment'),
                  ] else ...[
                    TextField(
                      controller: toController,
                      decoration: const InputDecoration(
                        labelText: 'To (Device ID)',
                        hintText: 'Leave blank for demo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: ttlController,
                      decoration: const InputDecoration(
                        labelText: 'TTL (Hops)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              if (generatedQR == null)
                ElevatedButton(
                  onPressed: () async {
                    final amount = int.tryParse(amountController.text) ?? 0;
                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter valid amount')),
                      );
                      return;
                    }

                    final to = toController.text.isEmpty
                        ? _deviceId
                        : toController.text;
                    final ttl = int.tryParse(ttlController.text) ?? 10;

                    // Create invoice data
                    final invoiceData = {
                      'type': 'invoice',
                      'from': _deviceId,
                      'to': to,
                      'amount': amount,
                      'ttl': ttl,
                    };

                    setDialogState(() {
                      generatedQR = jsonEncode(invoiceData);
                    });
                  },
                  child: const Text('Generate'),
                ),
            ],
          );
        },
      ),
    );
  }

  // Scan QR Code
  Future<void> _scanQRCode() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _QRScannerScreen(),
        ),
      );

      if (result != null && result is String) {
        await _processScannedQR(result);
      }
    } catch (e) {
      print('Error scanning QR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning QR: $e')),
        );
      }
    }
  }

  Future<void> _processScannedQR(String qrData) async {
    try {
      // Try to parse as JSON first (invoice)
      if (qrData.startsWith('{')) {
        final data = jsonDecode(qrData) as Map<String, dynamic>;

        if (data['type'] == 'invoice') {
          // Navigate to payment confirmation screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentConfirmationScreen(
                scannedData: qrData,
                deviceToken: _deviceId,
              ),
            ),
          );

          if (result != null &&
              result is Map<String, dynamic> &&
              result['success'] == true) {
            // Payment successful
            final token = result['token'] as Token;
            final amount = result['amount'] as double;
            final newBalance = result['newBalance'] as double;

            // Update local balance
            setState(() {
              _balance = newBalance;
            });

            // Broadcast token via BLE
            await _bleService.broadcastToken(token);

            // Play send sound
            _playSound('assets/sounds/send.mp3');

            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Payment of \$${amount.toStringAsFixed(2)} sent successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }

            // If gateway mode, try to upload
            if (_isGatewayMode) {
              final uploaded = await _gatewayService.uploadToken(token);
              if (uploaded) {
                print('Token uploaded to gateway');
              }
            }
          }
        }
      } else {
        // Try to parse as base64 token
        try {
          final token = Token.fromCompactBase64(qrData);
          // Broadcast this token
          await _bleService.broadcastToken(token);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Token broadcasted to network')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invalid QR code: $e')),
            );
          }
        }
      }
    } catch (e) {
      print('Error processing QR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _createAndSendToken({
    required String to,
    required int amount,
    required int ttl,
  }) async {
    // Check balance
    if (_balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Create token
      final token = await _cryptoService.createToken(
        from: _deviceId,
        to: to,
        amount: amount,
        ttl: ttl,
      );

      // Optimistic update - deduct balance
      setState(() {
        _balance -= amount;
        _saveBalance();

        _transactions.add(TxRecord(
          token: token,
          status: TxStatus.pending,
          createdAt: DateTime.now(),
        ));
      });

      // Play send sound
      _playSound('assets/sounds/send.mp3');

      // Broadcast token via BLE
      await _bleService.broadcastToken(token);

      // Update status to relayed
      final txIndex =
          _transactions.indexWhere((tx) => tx.token.txId == token.txId);
      if (txIndex != -1) {
        setState(() {
          _transactions[txIndex] = _transactions[txIndex].copyWith(
            status: TxStatus.relayed,
          );
        });
      }

      // If gateway mode, try to upload
      if (_isGatewayMode) {
        final uploaded = await _gatewayService.uploadToken(token);
        if (uploaded && txIndex != -1) {
          setState(() {
            _transactions[txIndex] = _transactions[txIndex].copyWith(
              status: TxStatus.uploaded,
            );
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment sent: $amount tokens'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error creating token: $e');
      // Refund balance on error
      setState(() {
        _balance += amount;
        _saveBalance();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMyQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('My Wallet QR'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: _deviceId,
                version: QrVersions.auto,
                size: 200,
              ),
            ),
            const SizedBox(height: 16),
            Text('Device ID: $_deviceId'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Stop services
      await _bleService.stopScanning();
      _gatewayService.dispose();
      _bleService.dispose();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _bleService.dispose();
    _gatewayService.dispose();
    super.dispose();
  }
}

// QR Scanner Screen
class _QRScannerScreen extends StatefulWidget {
  @override
  State<_QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<_QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Theme.of(context).colorScheme.primary,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black87,
              child: const Center(
                child: Text(
                  'Align QR code within frame',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!hasScanned && scanData.code != null) {
        hasScanned = true;
        controller.pauseCamera();
        Navigator.pop(context, scanData.code);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
