# MeshPay Demo - Tokenized Wallet Transfers over Mesh Network

## Overview

MeshPay is a decentralized payment system that uses a **Wi-Fi-hotspot-first mesh network with BLE fallback** for offline, peer-to-peer token transfers. This demo showcases:

- **Cryptographic token creation** (X25519 ECDH + AES-GCM + Ed25519)
- **Wi-Fi gateway mode** for token settlement
- **BLE mesh relay** for token propagation
- **QR code** invoice generation and scanning
- **Multi-device simulation** on a single phone

---

## 🚀 Quick Setup

### 1. Add Dependencies to `pubspec.yaml`

Add these dependencies to your existing `pubspec.yaml`:

```yaml
dependencies:
  # Existing dependencies...

  # MeshPay dependencies
  cryptography: ^2.7.0
  uuid: ^4.5.1
  flutter_blue_plus: ^1.33.4
  audioplayers: ^6.1.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  # Existing dev dependencies...

  hive_generator: ^2.0.1
```

**Note:** The following are already in your `pubspec.yaml`:

- `connectivity_plus: ^5.0.1` ✓
- `shared_preferences: ^2.3.5` ✓
- `qr_flutter: ^4.1.0` ✓
- `qr_code_scanner: ^1.0.1` ✓
- `go_router: ^14.6.2` ✓

### 2. Add Assets

Add to your `pubspec.yaml` under `flutter:`:

```yaml
flutter:
  assets:
    - assets/sounds/send.mp3
    - assets/sounds/recv.mp3
```

**Create placeholder sound files:**

```bash
mkdir -p assets/sounds
# Add your sound files or use silent placeholders
```

### 3. Add Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)

Already added:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

Add these for BLE:

```xml
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"
    android:usesPermissionFlags="neverForLocation"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

#### iOS (`ios/Runner/Info.plist`)

Already added:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes</string>
```

Add for BLE:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth for mesh network communication</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app uses Bluetooth to broadcast payment tokens</string>
```

### 4. Install Dependencies

```bash
./fvm-flutter.sh pub get
```

---

## 📂 Files Created

All new files under `lib/`:

```
lib/
├── models/
│   └── token_model.dart           # Token data model with JSON serialization
├── services/
│   ├── crypto_service.dart        # X25519 ECDH, AES-GCM, Ed25519 signatures
│   ├── gateway_service.dart       # Wi-Fi detection, token upload simulation
│   └── ble_service.dart           # BLE mesh scanning & advertising
├── widgets/
│   └── qr_widgets.dart            # QR generation and scanning widgets
├── pages/
│   ├── meshpay_wallet_page.dart   # Main wallet UI (TO BE CREATED)
│   └── meshpay_network_monitor_page.dart # Network monitoring UI (TO BE CREATED)
└── meshpay_routes.dart            # Route configuration (TO BE CREATED)
```

---

## 🔌 Integration with Existing App

### Add Routes to Your `main.dart`

Find your existing `GoRouter` configuration and add these routes:

```dart
// In your app_routes.dart or wherever you define routes

import 'package:your_app/pages/meshpay_wallet_page.dart';
import 'package:your_app/pages/meshpay_network_monitor_page.dart';

// Add to your GoRouter routes list:
GoRoute(
  path: '/meshpay/wallet',
  builder: (context, state) => const MeshPayWalletPage(),
),
GoRoute(
  path: '/meshpay/monitor',
  builder: (context, state) => const MeshPayNetworkMonitorPage(),
),
```

**Or copy-paste this into your existing routes map:**

```dart
'/meshpay/wallet': (context) => const MeshPayWalletPage(),
'/meshpay/monitor': (context) => const MeshPayNetworkMonitorPage(),
```

### Access from Your Existing Dashboard

Add a button in your existing home/dashboard:

```dart
ElevatedButton(
  onPressed: () {
    context.go('/meshpay/wallet'); // if using go_router
    // OR
    Navigator.pushNamed(context, '/meshpay/wallet');
  },
  child: const Text('MeshPay Demo'),
),
```

---

## 🎮 Demo Scenarios

### Scenario A: Single Device Offline Payment

1. Open app → Navigate to **MeshPay Wallet**
2. Your balance starts at **1000 tokens**
3. Enable **"Act as Gateway"** toggle
4. Click **"Generate Invoice (QR)"**
   - Leave "To" blank (uses own device ID)
   - Enter amount: `50`
   - Click **Generate**
5. Note QR code displayed
6. Click **"Scan QR"**
7. Scan the QR you just generated
8. App creates token, broadcasts via BLE (simulated)
9. Gateway receives and confirms
10. Balance updates: **1000 → 950** (sent) → **1000** (received)

**Result:** Demonstrates token creation, encryption, and gateway confirmation.

### Scenario B: Multi-Device Simulation (Relay)

1. In **MeshPay Wallet**, find **"Device Profile"** dropdown (top-right)
2. Switch to **"Device B"** profile
3. Note: Each profile has separate balance (starts at 1000)
4. Switch back to **"Device A"**
5. Enable **"Allow Relay"** on both devices
6. Device A: Generate invoice for Device B
7. Device A: Create token (amount: 100, TTL: 5)
8. Observe in **Network Monitor**:
   - Token broadcast by A
   - Token relayed (TTL decrements)
   - Token received by B
9. Switch to Device B profile → See balance increased

**Result:** Demonstrates mesh relay with TTL countdown.

### Scenario C: Network Monitor

1. Navigate to **MeshPay Network Monitor**
2. Click **"Simulate Network"**
3. Enters test mode with 5 synthetic relay nodes
4. Watch tokens propagate:
   - Node1 → Node2 → Node3 → Node4 → Gateway
   - TTL countdown visualization
   - Hop counter increments
5. View token lifecycle:
   - PENDING → RELAYED → UPLOADED → CONFIRMED

**Result:** Visualizes mesh network behavior and token propagation.

---

## 🔐 Security Notes (DEMO ONLY)

⚠️ **This is educational demo code. DO NOT use in production without:**

1. **Key Management:**

   - Replace hardcoded demo server keypair with HSM/KMS
   - Implement proper PKI for device key distribution
   - Use device-specific secure enclaves (iOS Keychain, Android KeyStore)

2. **Token Encryption:**

   - Current implementation uses simulated server key
   - Production: Use actual server public key from certificate
   - Implement key rotation policies

3. **Signature Verification:**

   - Demo skips sender public key verification
   - Production: Fetch sender's public key from distributed ledger or PKI
   - Implement certificate pinning

4. **Replay Protection:**

   - Current: Simple timestamp + 5-min expiry
   - Production: Use nonce database or blockchain for replay prevention

5. **Balance Management:**

   - Demo: Local balance tracking only
   - Production: Centralized ledger with consensus mechanism
   - Implement double-spend prevention

6. **PIN Storage:**
   - Current: SharedPreferences (plain text)
   - Production: Encrypt with device biometrics (iOS Face ID, Android BiometricPrompt)

---

## 📱 Platform Limitations

### iOS

- **BLE Advertising:** Not supported without MFi license
- **Background BLE:** Requires specific service UUIDs
- **Alternative:** Consider Multipeer Connectivity framework
- **Solution:** Demo uses event simulation for advertising

### Android

- **BLE Peripheral Mode:** Requires Android 5.0+
- **Advertising Payload:** Limited to ~22-31 bytes
- **Background Restrictions:** Android 8.0+ limits background execution
- **Solution:** Use `flutter_ble_peripheral` for real advertising

### Token Size Issue

- Full token JSON: ~200-300 bytes
- BLE advertising limit: ~22 bytes
- **Current solution:** Advertise token_ref (tx_id), fetch via GATT
- **Production solutions:**
  - Use BLE Extended Advertising (255 bytes, Android 8+)
  - Fragment token across multiple advertisements
  - Use protobuf/MessagePack for compact serialization

---

## 🧪 Testing Checklist

- [ ] Create account / Demo login
- [ ] Navigate to MeshPay Wallet
- [ ] Generate invoice QR
- [ ] Scan invoice QR
- [ ] Token creation and encryption
- [ ] Balance deduction (optimistic)
- [ ] Gateway upload (if Wi-Fi available)
- [ ] Token confirmation
- [ ] Balance update
- [ ] Play send/receive sounds
- [ ] Switch device profiles
- [ ] Test offline mode (disable Wi-Fi)
- [ ] Enable/disable relay
- [ ] View network monitor
- [ ] Simulate network propagation
- [ ] Check transaction history

---

## 🛠️ Development Tips

### Debug Mode

Enable detailed logging:

```dart
// In crypto_service.dart, gateway_service.dart, ble_service.dart
// Uncomment print() statements for verbose logging
```

### Testing BLE Without Multiple Devices

Use the **Device Profile Switcher** in the wallet UI to simulate multiple logical devices on one physical device.

### Inspecting Tokens

In **Network Monitor**, tap any token row to see full details:

- Transaction ID
- Encrypted payload (base64)
- Signature
- Timestamp & TTL
- Relay path

### Performance Optimization

- **Seen Cache:** Currently uses `Map<String, DateTime>`

  - For 10,000+ tokens, use Bloom filter
  - Implementation: Add `flutter_bloom_filter` package

- **Token Storage:** Currently in-memory
  - For persistence: Use Hive (already included)
  - Implement: Token database with LRU eviction

---

## 📊 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     MeshPay Architecture                    │
└─────────────────────────────────────────────────────────────┘

┌──────────────┐
│   UI Layer   │  pages/meshpay_wallet_page.dart
└──────┬───────┘       pages/meshpay_network_monitor_page.dart
       │
       │ User Actions (Create, Scan, Relay)
       ▼
┌──────────────┐
│ Service Layer│  services/crypto_service.dart (Encrypt/Sign)
└──────┬───────┘       services/gateway_service.dart (Upload)
       │               services/ble_service.dart (Broadcast/Scan)
       │
       │ Token Flow
       ▼
┌──────────────────────────────────────────────────────────┐
│  Network Layer                                           │
├──────────────────────────────────────────────────────────┤
│  Wi-Fi (Gateway)    │   BLE Mesh (Relay)                │
│  ─────────────────  │   ───────────────                 │
│  Token → Gateway    │   Token → BLE Adv → Peer Devices  │
│  Gateway decrypts   │   Peers relay if TTL > 0          │
│  Gateway confirms   │   Gateway uploads when received   │
└──────────────────────────────────────────────────────────┘
```

---

## 🐛 Troubleshooting

### "cryptography package not found"

```bash
./fvm-flutter.sh pub get
```

### "BLE not supported"

- Check device has Bluetooth LE
- Enable Bluetooth in device settings
- Grant Bluetooth permissions

### "Token size exceeds advertising limit"

- This is expected for full tokens
- Production: Use token_ref strategy (see BLE service comments)

### Tokens not confirming

1. Check **"Act as Gateway"** is enabled
2. Verify Wi-Fi is connected
3. Check Network Monitor for upload events

### App crashes on QR scan

- Grant Camera permission in device settings
- Check QR code is valid JSON or base64 token

---

## 📚 Further Reading

- **Cryptography:** https://pub.dev/packages/cryptography
- **BLE Flutter:** https://pub.dev/packages/flutter_blue_plus
- **Mesh Networks:** https://en.wikipedia.org/wiki/Wireless_mesh_network
- **Payment Channels:** Lightning Network, Raiden Network

---

## 🎓 Educational Goals

This demo teaches:

1. **Elliptic Curve Cryptography** (X25519 key exchange, Ed25519 signatures)
2. **Symmetric Encryption** (AES-GCM authenticated encryption)
3. **Mesh Network Protocols** (TTL-based flooding, deduplication)
4. **Mobile Connectivity** (Wi-Fi detection, BLE advertising/scanning)
5. **Offline-First Design** (Optimistic updates, eventual consistency)

---

## License

MIT License - Educational purposes only

---

**Questions?** Check code comments or file an issue.

**Ready to Run:** Complete remaining page implementations, then:

```bash
./fvm-flutter.sh run
```

Navigate to **Dashboard → MeshPay Demo → Wallet**
