import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import '../../../services/crypto_service.dart';
import '../../../models/token_model.dart';
import '../../../app/theme/neon_theme.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final String scannedData;
  final String deviceToken;

  const PaymentConfirmationScreen({
    super.key,
    required this.scannedData,
    required this.deviceToken,
  });

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  bool _isOnline = false;
  double _currentBalance = 0.0;
  String _userId = '';

  // Limits
  static const double OFFLINE_LIMIT = 10.0;
  static const double ONLINE_LIMIT = 1000.0;
  static const double INITIAL_BALANCE = 100.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkConnectivity();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Initialize balance if first time
    if (!prefs.containsKey('wallet_balance')) {
      await prefs.setDouble('wallet_balance', INITIAL_BALANCE);
    }

    setState(() {
      _currentBalance = prefs.getDouble('wallet_balance') ?? INITIAL_BALANCE;
      _userId = prefs.getString('user_id') ??
          'user_${DateTime.now().millisecondsSinceEpoch}';
    });

    // Save userId if new
    if (!prefs.containsKey('user_id')) {
      await prefs.setString('user_id', _userId);
    }
  }

  Future<void> _checkConnectivity() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();

    setState(() {
      _isOnline = result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet;
    });
  }

  double get _maxAmount => _isOnline ? ONLINE_LIMIT : OFFLINE_LIMIT;

  Future<void> _processPayment() async {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    if (amount > _maxAmount) {
      _showError(
        'Amount exceeds ${_isOnline ? "online" : "offline"} limit of \$${_maxAmount.toStringAsFixed(2)}',
      );
      return;
    }

    if (amount > _currentBalance) {
      _showError(
          'Insufficient balance. Current balance: \$${_currentBalance.toStringAsFixed(2)}');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse scanned data
      Map<String, dynamic> invoiceData;
      try {
        invoiceData = jsonDecode(widget.scannedData);
      } catch (e) {
        _showError('Invalid QR code format');
        setState(() => _isLoading = false);
        return;
      }

      final recipientId =
          invoiceData['to'] as String? ?? invoiceData['device_id'] as String?;

      if (recipientId == null) {
        _showError('Invalid recipient information');
        setState(() => _isLoading = false);
        return;
      }

      // Create encrypted API token
      final apiToken = await _createEncryptedApiToken(
        deviceToken: widget.deviceToken,
        userId: _userId,
        amount: amount,
        recipientId: recipientId,
      );

      // Create payment token
      final cryptoService = CryptoService();
      await cryptoService.initialize();

      final paymentToken = await cryptoService.createToken(
        from: widget.deviceToken,
        to: recipientId,
        amount: amount.toInt(),
        ttl: 10,
      );

      // Add encrypted API token to payload
      final enhancedToken = await _enhanceTokenWithApiData(
        paymentToken,
        apiToken,
      );

      // Deduct balance locally
      final newBalance = _currentBalance - amount;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('wallet_balance', newBalance);

      // Save transaction
      await _saveTransaction(
        amount: amount,
        recipientId: recipientId,
        tokenId: paymentToken.txId,
        status: 'pending',
      );

      // Broadcast via BLE mesh
      // Note: BLEService will be used from parent widget context
      // For now, we'll return the token to parent

      if (mounted) {
        Navigator.pop(context, {
          'success': true,
          'token': enhancedToken,
          'amount': amount,
          'newBalance': newBalance,
        });
      }
    } catch (e) {
      print('Payment error: $e');
      _showError('Payment failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String> _createEncryptedApiToken({
    required String deviceToken,
    required String userId,
    required double amount,
    required String recipientId,
  }) async {
    final createdAt = DateTime.now().toUtc().toIso8601String();

    // Create API token payload
    final apiPayload = {
      'device_token': deviceToken,
      'user_id': userId,
      'amount': amount,
      'recipient_id': recipientId,
      'created_at': createdAt,
      'endpoint': '/update/$deviceToken/$userId/$createdAt',
    };

    // Encrypt the API token
    final cryptoService = CryptoService();
    await cryptoService.initialize();

    final encryptedApiToken = await cryptoService.encryptApiToken(
      jsonEncode(apiPayload),
    );

    return encryptedApiToken;
  }

  Future<Token> _enhanceTokenWithApiData(
      Token token, String encryptedApiToken) async {
    // Add encrypted API token to the token's metadata
    // This will be transmitted via BLE mesh
    return Token(
      txId: token.txId,
      from: token.from,
      to: token.to,
      amount: token.amount,
      nonce: token.nonce,
      ephemeralPub: token.ephemeralPub,
      cipher: token.cipher,
      sig: token.sig,
      timestamp: token.timestamp,
      ttl: token.ttl,
      metadata: {
        'encrypted_api_token': encryptedApiToken,
      },
    );
  }

  Future<void> _saveTransaction({
    required double amount,
    required String recipientId,
    required String tokenId,
    required String status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final transactions = prefs.getStringList('transactions') ?? [];

    final transaction = {
      'id': tokenId,
      'amount': amount,
      'recipient_id': recipientId,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'debit',
    };

    transactions.add(jsonEncode(transaction));
    await prefs.setStringList('transactions', transactions);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonBlueTheme.offWhite,
      appBar: AppBar(
        title: const Text('CONFIRM PAYMENT'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: NeonBlueTheme.neonGradient,
          ),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: NeonBlueTheme.neonGradient,
                      shape: BoxShape.circle,
                      boxShadow: NeonBlueTheme.neonGlow,
                    ),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Processing Payment...',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: NeonBlueTheme.neonBlue,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Connection Status - Neon Style
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: NeonBlueTheme.statusBadge(isOnline: _isOnline),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isOnline ? Icons.wifi : Icons.wifi_off,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isOnline ? 'ONLINE MODE' : 'OFFLINE MODE',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Max: \$${_maxAmount.toStringAsFixed(2)} per transaction',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _isOnline ? 'BLE + WiFi' : 'BLE Only',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Current Balance - Glass Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: NeonBlueTheme.glassCard(),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: NeonBlueTheme.neonGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Available Balance',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: NeonBlueTheme.mediumGray,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              NeonBlueTheme.neonGradient.createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: Text(
                            '\$${_currentBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Amount Input
                  TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$ ',
                      hintText: '0.00',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Amount Buttons
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildQuickAmountButton(5),
                      _buildQuickAmountButton(10),
                      if (_isOnline) ...[
                        _buildQuickAmountButton(20),
                        _buildQuickAmountButton(50),
                        _buildQuickAmountButton(100),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Pay Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text(
                      'Confirm Payment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cancel Button
                  OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickAmountButton(double amount) {
    final isDisabled = amount > _maxAmount || amount > _currentBalance;

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              _amountController.text = amount.toStringAsFixed(2);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: isDisabled
              ? null
              : LinearGradient(
                  colors: [
                    NeonBlueTheme.neonBlueLight.withOpacity(0.8),
                    NeonBlueTheme.neonBlue.withOpacity(0.8),
                  ],
                ),
          color: isDisabled ? NeonBlueTheme.lightGray : null,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: NeonBlueTheme.neonBlue.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Text(
          '\$$amount',
          style: TextStyle(
            color: isDisabled ? NeonBlueTheme.mediumGray : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
