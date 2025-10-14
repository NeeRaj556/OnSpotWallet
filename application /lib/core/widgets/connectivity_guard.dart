import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../app/utils/logger_utils.dart';

/// ConnectivityGuard ensures the app has either Bluetooth OR Internet/WiFi connectivity
/// Only blocks the app if BOTH are unavailable
class ConnectivityGuard extends StatefulWidget {
  final Widget child;

  const ConnectivityGuard({
    super.key,
    required this.child,
  });

  @override
  State<ConnectivityGuard> createState() => _ConnectivityGuardState();
}

class _ConnectivityGuardState extends State<ConnectivityGuard> {
  BluetoothAdapterState _bluetoothState = BluetoothAdapterState.unknown;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;

  StreamSubscription<BluetoothAdapterState>? _bluetoothSubscription;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool _isCheckingConnectivity = true;
  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    try {
      // Check Bluetooth state
      _bluetoothState = await FlutterBluePlus.adapterState.first;
      _bluetoothSubscription = FlutterBluePlus.adapterState.listen((state) {
        if (mounted) {
          setState(() {
            _bluetoothState = state;
            _hasShownDialog = false; // Reset dialog flag when state changes
          });
        }
      });

      // Check Internet/WiFi connectivity
      _connectivityResult = await Connectivity().checkConnectivity();
      _connectivitySubscription =
          Connectivity().onConnectivityChanged.listen((result) {
        if (mounted) {
          setState(() {
            _connectivityResult = result;
            _hasShownDialog = false; // Reset dialog flag when state changes
          });
        }
      });

      setState(() {
        _isCheckingConnectivity = false;
      });
    } catch (e) {
      logger.e('Error checking connectivity: $e');
      setState(() {
        _isCheckingConnectivity = false;
      });
    }
  }

  @override
  void dispose() {
    _bluetoothSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  bool get _hasBluetoothConnectivity {
    return _bluetoothState == BluetoothAdapterState.on;
  }

  bool get _hasInternetConnectivity {
    return _connectivityResult == ConnectivityResult.wifi ||
        _connectivityResult == ConnectivityResult.mobile ||
        _connectivityResult == ConnectivityResult.ethernet ||
        _connectivityResult == ConnectivityResult.vpn;
  }

  bool get _hasAnyConnectivity {
    return _hasBluetoothConnectivity || _hasInternetConnectivity;
  }

  String get _connectivityMessage {
    if (!_hasBluetoothConnectivity && !_hasInternetConnectivity) {
      return 'Please enable either Bluetooth or WiFi/Internet to continue using the app.';
    } else if (!_hasBluetoothConnectivity) {
      return 'Bluetooth is disabled. Some features may be limited.';
    } else if (!_hasInternetConnectivity) {
      return 'No internet connection. Some features may be limited.';
    }
    return 'Connected';
  }

  IconData get _connectivityIcon {
    if (!_hasBluetoothConnectivity && !_hasInternetConnectivity) {
      return Icons.signal_wifi_off;
    } else if (!_hasBluetoothConnectivity) {
      return Icons.bluetooth_disabled;
    } else if (!_hasInternetConnectivity) {
      return Icons.wifi_off;
    }
    return Icons.check_circle;
  }

  void _showConnectivityDialog() {
    if (_hasShownDialog) return;
    _hasShownDialog = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Prevent back button
        child: AlertDialog(
          title: Row(
            children: [
              Icon(
                _connectivityIcon,
                color: Colors.red[700],
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'No Connectivity',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _connectivityMessage,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'MeshPay requires at least one connectivity method:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildConnectivityStatus('Bluetooth', _hasBluetoothConnectivity),
              const SizedBox(height: 8),
              _buildConnectivityStatus(
                  'WiFi/Internet', _hasInternetConnectivity),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _hasShownDialog = false;

                // Try to enable Bluetooth if it's the only missing one
                if (!_hasBluetoothConnectivity && _hasInternetConnectivity) {
                  try {
                    if (await FlutterBluePlus.isSupported) {
                      await FlutterBluePlus.turnOn();
                    }
                  } catch (e) {
                    logger.e('Error turning on Bluetooth: $e');
                  }
                }
              },
              child: const Text(
                'Open Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _hasShownDialog = false;
              },
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectivityStatus(String label, bool isConnected) {
    return Row(
      children: [
        Icon(
          isConnected ? Icons.check_circle : Icons.cancel,
          color: isConnected ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isConnected ? Colors.green[700] : Colors.red[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking connectivity
    if (_isCheckingConnectivity) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  'Checking connectivity...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Block app ONLY if BOTH Bluetooth AND Internet are unavailable
    if (!_hasAnyConnectivity) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasShownDialog) {
          _showConnectivityDialog();
        }
      });

      // Return blocked screen
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.grey[300],
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.signal_wifi_off,
                  size: 100,
                  color: Colors.red[700],
                ),
                const SizedBox(height: 20),
                const Text(
                  'No Connectivity',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'MeshPay requires either Bluetooth or WiFi/Internet to function. Please enable at least one connectivity method.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildConnectivityChip(
                        'Bluetooth', _hasBluetoothConnectivity),
                    const SizedBox(width: 16),
                    _buildConnectivityChip(
                        'WiFi/Internet', _hasInternetConnectivity),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Allow app to proceed if at least one connectivity method is available
    return widget.child;
  }

  Widget _buildConnectivityChip(String label, bool isConnected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConnected ? Icons.check_circle : Icons.cancel,
            color: isConnected ? Colors.green[700] : Colors.red[700],
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isConnected ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }
}
