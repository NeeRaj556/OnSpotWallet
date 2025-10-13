import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/theme/neon_theme.dart';
import '../../../core/services/bluetooth_mesh_service.dart';

class InitialSetupScreen extends StatefulWidget {
  final VoidCallback onSetupComplete;

  const InitialSetupScreen({
    super.key,
    required this.onSetupComplete,
  });

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  final BluetoothMeshService _bluetoothService = BluetoothMeshService();
  bool _isLoading = false;
  String _statusMessage = 'Welcome to OnSpotWallet';

  @override
  void initState() {
    super.initState();
    _checkIfAlreadySetup();
  }

  Future<void> _checkIfAlreadySetup() async {
    final prefs = await SharedPreferences.getInstance();
    final isSetupComplete = prefs.getBool('initial_setup_complete') ?? false;

    if (isSetupComplete && mounted) {
      widget.onSetupComplete();
    }
  }

  Future<void> _startSetup() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Initializing Bluetooth...';
    });

    // Step 1: Initialize Bluetooth
    final initialized = await _bluetoothService.initialize();
    if (!initialized) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Bluetooth not available on this device';
        _isLoading = false;
      });
      await Future.delayed(const Duration(seconds: 2));
      _completeSetup();
      return;
    }

    // Step 2: Request Permissions
    if (!mounted) return;
    setState(() {
      _statusMessage = 'Requesting Bluetooth permissions...';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    final permissionsGranted = await _bluetoothService.requestPermissions();

    if (!mounted) return;
    setState(() {
      _statusMessage = permissionsGranted
          ? '✅ Permissions granted'
          : '⚠️ Some permissions denied';
    });

    await Future.delayed(const Duration(seconds: 1));

    // Step 3: Enable Bluetooth
    if (permissionsGranted) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Enabling Bluetooth...';
      });

      await Future.delayed(const Duration(milliseconds: 500));
      final bluetoothEnabled = await _bluetoothService.enableBluetooth();

      if (!mounted) return;
      setState(() {
        _statusMessage = bluetoothEnabled
            ? '✅ Bluetooth enabled'
            : '⚠️ Please enable Bluetooth manually';
      });

      await Future.delayed(const Duration(seconds: 1));
    }

    // Step 4: Complete Setup
    if (!mounted) return;
    setState(() {
      _statusMessage = '✅ Setup complete!';
    });

    await Future.delayed(const Duration(seconds: 1));
    _completeSetup();
  }

  Future<void> _completeSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('initial_setup_complete', true);

    if (mounted) {
      widget.onSetupComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              NeonBlueTheme.neonBlue,
              NeonBlueTheme.electricBlue,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        NeonBlueTheme.neonGradient.createShader(bounds),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // App Name
              const Text(
                'OnSpotWallet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Next Generation Digital Wallet',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(flex: 1),

              // Status Message
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _statusMessage,
                    key: ValueKey(_statusMessage),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Loading Indicator
              if (_isLoading)
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: CircularProgressIndicator(
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),

              const Spacer(flex: 1),

              // Setup Button
              if (!_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startSetup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: NeonBlueTheme.neonBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

              // Skip Button
              if (!_isLoading)
                TextButton(
                  onPressed: _completeSetup,
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
