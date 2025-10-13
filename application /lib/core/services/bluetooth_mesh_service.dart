import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:async';

class BluetoothMeshService {
  static final BluetoothMeshService _instance =
      BluetoothMeshService._internal();
  factory BluetoothMeshService() => _instance;
  BluetoothMeshService._internal();

  // Service UUID for OnSpotWallet P2P transactions
  static const String SERVICE_UUID = '0000ffe0-0000-1000-8000-00805f9b34fb';
  static const String CHARACTERISTIC_UUID =
      '0000ffe1-0000-1000-8000-00805f9b34fb';

  bool _isInitialized = false;
  bool _isScanning = false;
  StreamSubscription? _scanSubscription;
  List<BluetoothDevice> _discoveredDevices = [];

  final StreamController<List<BluetoothDevice>> _devicesController =
      StreamController<List<BluetoothDevice>>.broadcast();

  Stream<List<BluetoothDevice>> get devicesStream => _devicesController.stream;
  List<BluetoothDevice> get discoveredDevices => _discoveredDevices;

  /// Initialize Bluetooth service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Check if Bluetooth is available
      final isAvailable = await FlutterBluePlus.isAvailable;
      if (!isAvailable) {
        debugPrint('❌ Bluetooth not available on this device');
        return false;
      }

      _isInitialized = true;
      debugPrint('✅ Bluetooth service initialized');
      return true;
    } catch (e) {
      debugPrint('❌ Error initializing Bluetooth: $e');
      return false;
    }
  }

  /// Request Bluetooth permissions
  Future<bool> requestPermissions() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.location, // Required for Bluetooth scanning on Android
      ].request();

      final allGranted = statuses.values.every((status) => status.isGranted);

      if (allGranted) {
        debugPrint('✅ All Bluetooth permissions granted');
      } else {
        debugPrint('⚠️ Some Bluetooth permissions denied');
      }

      return allGranted;
    } catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
      return false;
    }
  }

  /// Enable Bluetooth automatically
  Future<bool> enableBluetooth() async {
    try {
      final isOn = await FlutterBluePlus.isOn;
      if (isOn) {
        debugPrint('✅ Bluetooth is already on');
        return true;
      }

      // Try to turn on Bluetooth
      await FlutterBluePlus.turnOn();

      // Wait for Bluetooth to turn on (with timeout)
      int attempts = 0;
      while (attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        final isNowOn = await FlutterBluePlus.isOn;
        if (isNowOn) {
          debugPrint('✅ Bluetooth turned on successfully');
          return true;
        }
        attempts++;
      }

      debugPrint('⚠️ Bluetooth did not turn on within timeout');
      return false;
    } catch (e) {
      debugPrint('❌ Error enabling Bluetooth: $e');
      // On some devices, we need to ask user to enable manually
      return false;
    }
  }

  /// Start scanning for nearby OnSpotWallet devices
  Future<void> startScanning(
      {Duration duration = const Duration(seconds: 15)}) async {
    if (_isScanning) {
      debugPrint('⚠️ Already scanning');
      return;
    }

    try {
      _isScanning = true;
      _discoveredDevices.clear();
      _devicesController.add(_discoveredDevices);

      debugPrint('🔍 Starting Bluetooth scan...');

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: duration,
        androidUsesFineLocation: true,
      );

      // Listen to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          final device = result.device;

          // Add device if not already in list
          if (!_discoveredDevices.any((d) => d.remoteId == device.remoteId)) {
            _discoveredDevices.add(device);
            debugPrint(
                '📱 Found device: ${device.platformName} (${device.remoteId})');
            _devicesController.add(_discoveredDevices);
          }
        }
      });

      // Stop scanning after duration
      Future.delayed(duration, () {
        stopScanning();
      });
    } catch (e) {
      debugPrint('❌ Error during scanning: $e');
      _isScanning = false;
    }
  }

  /// Stop scanning
  Future<void> stopScanning() async {
    if (!_isScanning) return;

    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      _isScanning = false;
      debugPrint('⏹️ Stopped Bluetooth scan');
    } catch (e) {
      debugPrint('❌ Error stopping scan: $e');
    }
  }

  /// Send transaction data to a device via Bluetooth
  Future<bool> sendTransaction({
    required BluetoothDevice device,
    required String userId,
    required double amount,
    required String purpose,
  }) async {
    try {
      debugPrint('📤 Connecting to ${device.platformName}...');

      // Connect to device
      await device.connect(timeout: const Duration(seconds: 10));
      debugPrint('✅ Connected to ${device.platformName}');

      // Discover services
      List<BluetoothService> services = await device.discoverServices();

      // Find our service and characteristic
      BluetoothCharacteristic? targetCharacteristic;
      for (var service in services) {
        if (service.uuid
            .toString()
            .toLowerCase()
            .contains(SERVICE_UUID.toLowerCase())) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid
                .toString()
                .toLowerCase()
                .contains(CHARACTERISTIC_UUID.toLowerCase())) {
              targetCharacteristic = characteristic;
              break;
            }
          }
        }
      }

      if (targetCharacteristic == null) {
        debugPrint('❌ Target characteristic not found');
        await device.disconnect();
        return false;
      }

      // Prepare transaction data
      final transactionData = {
        'userId': userId,
        'amount': amount,
        'purpose': purpose,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'bluetooth_transfer',
      };

      final jsonData = jsonEncode(transactionData);
      final bytes = utf8.encode(jsonData);

      // Write data
      await targetCharacteristic.write(bytes);
      debugPrint('✅ Transaction data sent successfully');

      // Disconnect
      await device.disconnect();
      debugPrint('🔌 Disconnected from ${device.platformName}');

      return true;
    } catch (e) {
      debugPrint('❌ Error sending transaction: $e');
      try {
        await device.disconnect();
      } catch (_) {}
      return false;
    }
  }

  /// Cleanup resources
  void dispose() {
    _scanSubscription?.cancel();
    _devicesController.close();
    _isInitialized = false;
    _isScanning = false;
  }
}
