import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../app/utils/logger_utils.dart';

class BluetoothGuard extends StatefulWidget {
  final Widget child;

  const BluetoothGuard({
    super.key,
    required this.child,
  });

  @override
  State<BluetoothGuard> createState() => _BluetoothGuardState();
}

class _BluetoothGuardState extends State<BluetoothGuard> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  bool _isCheckingBluetooth = true;

  @override
  void initState() {
    super.initState();
    _checkBluetooth();
  }

  Future<void> _checkBluetooth() async {
    try {
      // Get initial state
      _adapterState = await FlutterBluePlus.adapterState.first;

      // Listen for state changes
      _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
        if (mounted) {
          setState(() {
            _adapterState = state;
          });
        }
      });

      setState(() {
        _isCheckingBluetooth = false;
      });
    } catch (e) {
      logger.e('Error checking Bluetooth: $e');
      setState(() {
        _isCheckingBluetooth = false;
      });
    }
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    super.dispose();
  }

  void _showBluetoothDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Prevent back button
        child: AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.bluetooth_disabled,
                color: Colors.red[700],
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Oops!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This is a Bluetooth related app. Please enable Bluetooth to continue using the app.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                'The app cannot function without Bluetooth.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Try to turn on Bluetooth (only works on Android)
                try {
                  if (await FlutterBluePlus.isSupported) {
                    await FlutterBluePlus.turnOn();
                  }
                } catch (e) {
                  logger.e('Error turning on Bluetooth: $e');
                  // Show message to enable manually
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please enable Bluetooth manually from settings'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text(
                'Enable Bluetooth',
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

  @override
  Widget build(BuildContext context) {
    if (_isCheckingBluetooth) {
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
                  'Checking Bluetooth...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If Bluetooth is not on, show dialog and block app
    if (_adapterState != BluetoothAdapterState.on) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showBluetoothDialog();
        }
      });

      // Return a blocked screen
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.grey[300],
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bluetooth_disabled,
                  size: 100,
                  color: Colors.red[700],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bluetooth Required',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'This app requires Bluetooth to function. Please enable Bluetooth and restart the app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
