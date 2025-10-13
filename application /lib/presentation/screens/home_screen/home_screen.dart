import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../services/crypto_service.dart';
import '../../../services/ble_service.dart';
import '../../../services/gateway_service.dart';
import '../../../models/token_model.dart';
import '../../../models/payment_category.dart';
import '../../../app/theme/neon_theme.dart';
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
  bool _isBalanceVisible = false; // Balance visibility toggle

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
      return Scaffold(
        backgroundColor: NeonBlueTheme.offWhite,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: NeonBlueTheme.neonGradient,
                  shape: BoxShape.circle,
                  boxShadow: NeonBlueTheme.neonGlow,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: NeonBlueTheme.offWhite,
      extendBody: true,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 120, // Space for floating button
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Balance Card with Visibility Toggle
                  _buildNeonBalanceCard(),
                  const SizedBox(height: 24),

                  // Payment Categories Grid
                  _buildPaymentCategories(),
                  const SizedBox(height: 24),

                  // Recent Transaction History (if any)
                  if (_transactions.isNotEmpty) ...[
                    _buildNeonTransactionHistory(),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),

            // Animated Floating QR Button
            _buildAnimatedQRButton(),
          ],
        ),
      ),
    );
  }

  // Neon Balance Card with Gradient and Visibility Toggle
  Widget _buildNeonBalanceCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: NeonBlueTheme.neonGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: NeonBlueTheme.neonGlow,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isBalanceVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          _isBalanceVisible = !_isBalanceVisible;
                        });
                      }
                    },
                    iconSize: 22,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadBalance,
                    iconSize: 20,
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: _handleLogout,
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Colors.white70],
            ).createShader(bounds),
            child: Text(
              _isBalanceVisible ? '\$${_balance.toStringAsFixed(2)}' : 'XXXXX',
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isOnline ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _isOnline ? 'ONLINE' : 'OFFLINE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Payment Categories Grid
  Widget _buildPaymentCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Services',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: NeonBlueTheme.almostBlack,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: paymentCategories.length,
          itemBuilder: (context, index) {
            final category = paymentCategories[index];
            return _buildCategoryCard(category);
          },
        ),
      ],
    );
  }

  // Category Card
  Widget _buildCategoryCard(PaymentCategory category) {
    return GestureDetector(
      onTap: () => _showCategoryServices(category),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: category.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: category.gradientColors[0].withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show Category Services Bottom Sheet
  void _showCategoryServices(PaymentCategory category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header with icon
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: category.gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category.icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Services list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: category.services.length,
                itemBuilder: (context, index) {
                  final service = category.services[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Navigate to service
                          Navigator.pop(context);
                          _handleServiceSelection(category, service);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[200]!,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: category.gradientColors
                                        .map((c) => c.withOpacity(0.2))
                                        .toList(),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.payment,
                                  color: category.gradientColors[0],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  service,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle Service Selection
  void _handleServiceSelection(PaymentCategory category, String service) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected: $service from ${category.title}'),
          backgroundColor: category.gradientColors[0],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    // TODO: Navigate to payment screen with service details
  }

  // Status Badge
  Widget _buildStatusBadge() {
    return Container(
      decoration: NeonBlueTheme.statusBadge(isOnline: _isOnline),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _isOnline
                  ? NeonBlueTheme.neonGreen
                  : NeonBlueTheme.neonOrange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isOnline
                          ? NeonBlueTheme.neonGreen
                          : NeonBlueTheme.neonOrange)
                      .withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline ? 'ONLINE MODE' : 'OFFLINE MODE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isOnline ? 'Connected • Max \$1000' : 'BLE Mesh • Max \$10',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _isOnline ? Icons.wifi : Icons.bluetooth,
                  color: Colors.white,
                  size: 16,
                ),
                if (_isOnline) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.bluetooth,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Quick Stats
  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: NeonBlueTheme.glassCard(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: NeonBlueTheme.successGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_downward,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_transactions.where((t) => t.status == TxStatus.confirmed).length}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: NeonBlueTheme.almostBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Received',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: NeonBlueTheme.glassCard(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: NeonBlueTheme.neonGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '0',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: NeonBlueTheme.almostBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sent',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Neon Transaction History
  Widget _buildNeonTransactionHistory() {
    if (_transactions.isEmpty) {
      return Container(
        decoration: NeonBlueTheme.glassCard(),
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: NeonBlueTheme.neonBlueLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long,
                size: 48,
                color: NeonBlueTheme.neonBlue.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: NeonBlueTheme.glassCard(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: NeonBlueTheme.neonGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.history,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: NeonBlueTheme.almostBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._transactions.take(5).map((tx) => _buildTransactionItem(tx)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TxRecord tx) {
    final dollarAmount = tx.token.amount / 100.0;
    final isReceived = tx.token.to == _deviceId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: NeonBlueTheme.neonBlue.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: isReceived
                  ? NeonBlueTheme.successGradient
                  : NeonBlueTheme.neonGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isReceived ? Icons.arrow_downward : Icons.arrow_upward,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isReceived ? 'Received' : 'Sent',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tx.createdAt.toString().substring(11, 16),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isReceived ? '+' : '-'}\$${dollarAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isReceived
                      ? NeonBlueTheme.neonGreen
                      : NeonBlueTheme.neonBlue,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: NeonBlueTheme.neonGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Confirmed',
                  style: TextStyle(
                    fontSize: 10,
                    color: NeonBlueTheme.neonGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Animated QR Button with Drop-down Style
  Widget _buildAnimatedQRButton() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 20,
      child: Center(
        child: GestureDetector(
          onTap: _showQRBottomSheet,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: NeonBlueTheme.neonGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: NeonBlueTheme.neonBlue.withOpacity(0.6),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }

  // QR Bottom Sheet
  void _showQRBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QRBottomSheet(
        deviceId: _deviceId,
        onQRScanned: (qrData) {
          Navigator.pop(context);
          _processScannedQR(qrData);
        },
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

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _balance = prefs.getDouble('balance') ?? 100.0;
    });
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
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => controller.switchCamera(),
          ),
          IconButton(
            icon: const Icon(Icons.flashlight_on),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (!hasScanned && barcode.rawValue != null) {
                  setState(() {
                    hasScanned = true;
                  });
                  Navigator.pop(context, barcode.rawValue);
                  break;
                }
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              color: Colors.black54,
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// QR Bottom Sheet with Scanner and My QR Toggle
class _QRBottomSheet extends StatefulWidget {
  final String deviceId;
  final Function(String) onQRScanned;

  const _QRBottomSheet({
    required this.deviceId,
    required this.onQRScanned,
  });

  @override
  State<_QRBottomSheet> createState() => _QRBottomSheetState();
}

class _QRBottomSheetState extends State<_QRBottomSheet> {
  bool _showMyQR = false;
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.65;

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, NeonBlueTheme.offWhite],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: NeonBlueTheme.neonBlue.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar with neon glow
          Container(
            margin: const EdgeInsets.only(top: 16),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              gradient: NeonBlueTheme.neonGradient,
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: NeonBlueTheme.neonBlue.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Toggle buttons (no text, just icons)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_showMyQR) ...[
                // Camera flip button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: NeonBlueTheme.softShadow,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.flip_camera_ios),
                    color: NeonBlueTheme.neonBlue,
                    onPressed: () => _scannerController.switchCamera(),
                  ),
                ),
                const SizedBox(width: 16),
                // Torch button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: NeonBlueTheme.softShadow,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.flashlight_on),
                    color: NeonBlueTheme.neonOrange,
                    onPressed: () => _scannerController.toggleTorch(),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              // Toggle button (scanner/my QR)
              Container(
                decoration: BoxDecoration(
                  gradient: NeonBlueTheme.neonGradient,
                  shape: BoxShape.circle,
                  boxShadow: NeonBlueTheme.neonGlow,
                ),
                child: IconButton(
                  icon: Icon(
                    _showMyQR ? Icons.qr_code_scanner : Icons.qr_code_2,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _showMyQR = !_showMyQR;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20), // Content area
          Expanded(
            child: _showMyQR ? _buildMyQRView() : _buildScannerView(),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  widget.onQRScanned(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
        ),
        // Scanning frame overlay
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: NeonBlueTheme.neonBlue,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: NeonBlueTheme.neonBlue.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Corner decorations
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: NeonBlueTheme.neonGradient,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(17),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: NeonBlueTheme.neonGradient,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(17),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: NeonBlueTheme.neonGradient,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(17),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: NeonBlueTheme.neonGradient,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(17),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyQRView() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                NeonBlueTheme.neonBlueLight.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: NeonBlueTheme.neonBlue.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: NeonBlueTheme.neonBlue.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: QrImageView(
            data: widget.deviceId,
            version: QrVersions.auto,
            size: 280,
            backgroundColor: Colors.transparent,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: NeonBlueTheme.almostBlack,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: NeonBlueTheme.almostBlack,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}
