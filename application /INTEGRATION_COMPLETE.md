# MeshPay Integration Complete ✅

## Overview

The home screen has been successfully integrated with the MeshPay demo feature, which demonstrates tokenized wallet transfers over a Wi-Fi-hotspot-first mesh with fallback to unpaired BLE mesh networking.

## What Was Implemented

### 1. Home Screen (`lib/presentation/screens/home_screen/home_screen.dart`)

- **Balance Management**: Starts with 1000 tokens, updates optimistically on send/receive
- **QR Code Generation**: Creates encrypted payment invoices that can be scanned
- **QR Code Scanning**: Processes scanned QR codes to:
  - Parse invoice data and create tokens
  - Broadcast existing tokens to the mesh network
  - Automatically deduct balance on send
  - Automatically increase balance on receive
- **BLE Integration**: Background scanning and broadcasting of payment tokens
- **Transaction History**: Real-time tracking of all payments with status updates
- **Gateway Mode**: Optional online mode to settle transactions via Wi-Fi
- **Audio Feedback**: Play sounds on send/receive (when audio files are added)

### 2. Services

#### CryptoService (`lib/services/crypto_service.dart`)

- X25519 ECDH key exchange
- AES-GCM encryption with 12-byte nonce
- Ed25519 digital signatures
- Token creation and verification
- Keypair persistence in SharedPreferences

#### BLEService (`lib/services/ble_service.dart`)

- BLE scanning and advertising
- Token broadcast and relay
- Seen cache for deduplication (5-minute expiry)
- TTL-based hop limiting
- Event stream for UI updates

#### GatewayService (`lib/services/gateway_service.dart`)

- Wi-Fi connectivity monitoring
- Token upload simulation
- Transaction confirmation tracking
- Event stream for status updates

### 3. Data Model

#### Token Model (`lib/models/token_model.dart`)

- Complete token structure with encryption fields
- JSON serialization
- Base64 compact format for BLE transmission
- TxRecord for tracking with TxStatus enum
- Support for transaction lifecycle:
  - Pending → Relayed → Uploaded → Confirmed/Failed

## Dependencies Added

```yaml
cryptography: ^2.7.0 # Encryption and signatures
uuid: ^4.5.1 # Transaction IDs
flutter_blue_plus: ^1.33.4 # BLE mesh networking
audioplayers: ^6.1.0 # Sound effects
hive: ^2.2.3 # Fast local storage
hive_flutter: ^1.1.0 # Hive Flutter integration
```

## Android Permissions Added

```xml
<!-- BLE Permissions -->
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

## How It Works

### Sending a Payment

1. User taps "Generate Invoice" button
2. Enters recipient device ID and amount
3. App generates QR code with invoice data
4. When scanned by payer:
   - Creates encrypted token using CryptoService
   - Deducts balance locally (optimistic update)
   - Broadcasts token via BLE mesh
   - Plays send sound
   - Updates transaction status (Pending → Relayed → Uploaded → Confirmed)

### Receiving a Payment

1. App continuously scans for BLE advertisements
2. When token received via BLE:
   - Verifies token signature
   - Checks if recipient matches device ID
   - Increases balance locally
   - Plays receive sound
   - Adds to transaction history
   - Relays token to other devices (if TTL > 0)

### QR Code Scanning

1. User taps "Scan QR" button
2. Camera opens with QR scanner overlay
3. Two types of QR codes supported:
   - **Invoice QR**: JSON with payment details → Creates and sends token
   - **Token QR**: Base64 encoded token → Broadcasts to network
4. Balance updates automatically based on transaction type

## File Structure

```
lib/
├── models/
│   └── token_model.dart          # Token and transaction data structures
├── services/
│   ├── crypto_service.dart       # Encryption and signing
│   ├── ble_service.dart          # BLE mesh networking
│   └── gateway_service.dart      # Wi-Fi settlement
├── presentation/
│   └── screens/
│       └── home_screen/
│           └── home_screen.dart  # Main wallet UI
└── widgets/
    └── qr_widgets.dart           # QR generation/scanning (existing)
```

## Testing Instructions

### 1. Install Dependencies

```bash
cd "/home/btwneeraj/Desktop/Projects/OnSpotWallet/application "
.fvm/flutter_sdk/bin/flutter pub get
```

### 2. Run the App

```bash
.fvm/flutter_sdk/bin/flutter run
```

### 3. Test Scenarios

#### Scenario A: Generate Invoice

1. Open app on Device A
2. Tap "Generate Invoice"
3. Enter amount (e.g., 100 tokens)
4. Leave "To" field blank (uses Device A's ID)
5. Tap "Generate"
6. QR code is displayed

#### Scenario B: Scan and Pay

1. Open app on Device B
2. Tap "Scan QR"
3. Scan the QR from Device A
4. Device B balance decreases by 100
5. Token is broadcast via BLE
6. Transaction appears in history as "Pending"

#### Scenario C: BLE Relay

1. Device C (with app running) is nearby
2. Receives token via BLE
3. If not the recipient, relays token (decreases TTL)
4. Continues until TTL reaches 0 or recipient found

#### Scenario D: Receive Payment

1. Device A receives token via BLE mesh
2. Verifies signature and checks recipient
3. Balance increases by 100 tokens
4. Transaction appears in history as "Confirmed"
5. Play receive sound (if audio file exists)

## Known Limitations

1. **Audio Files**: Sound effects require actual MP3 files in `assets/sounds/`

   - `send.mp3` - Played when sending tokens
   - `receive.mp3` - Played when receiving tokens
   - App gracefully handles missing files

2. **BLE Permissions**: Runtime permission requests need to be handled on first use

3. **Background BLE**: iOS requires special handling for background BLE scanning

4. **Gateway Settlement**: Currently simulated - needs real backend API

5. **Key Persistence**: Uses SharedPreferences - should migrate to secure storage

## Next Steps

### To Make It Production-Ready:

1. **Add Audio Files**

   - Download free sound effects
   - Place in `assets/sounds/` folder
   - Update references in code

2. **Implement Runtime Permissions**

   - Request BLE permissions on app start
   - Request camera permissions before scanning
   - Handle permission denied gracefully

3. **Backend Integration**

   - Replace GatewayService simulation with real HTTP API
   - Add authentication tokens
   - Implement proper transaction confirmation

4. **Security Enhancements**

   - Use flutter_secure_storage for keys
   - Add biometric authentication
   - Implement key rotation
   - Add rate limiting

5. **UI/UX Improvements**

   - Add loading indicators
   - Improve error messages
   - Add transaction details view
   - Implement pull-to-refresh

6. **Testing**
   - Add unit tests for CryptoService
   - Add widget tests for HomeScreen
   - Add integration tests for payment flow
   - Test BLE range and relay behavior

## Troubleshooting

### Build Errors

```bash
# Clean and rebuild
.fvm/flutter_sdk/bin/flutter clean
.fvm/flutter_sdk/bin/flutter pub get
.fvm/flutter_sdk/bin/flutter run
```

### BLE Not Working

- Check Android permissions are granted
- Ensure Bluetooth is enabled
- Verify location services are on (required for BLE scan)

### Camera Permission Denied

- Go to App Settings → Permissions → Camera → Allow

### Balance Not Updating

- Check transaction history for status
- Verify device ID matches recipient
- Check if gateway mode is enabled

## Success! 🎉

Your wallet app now features:
✅ PIN-protected authentication
✅ Offline access with local PIN
✅ QR code invoice generation
✅ QR code scanning with token processing
✅ Automatic balance management (deduct on send, increase on receive)
✅ BLE mesh networking for token relay
✅ Transaction history with real-time updates
✅ Gateway settlement (when online)
✅ End-to-end encryption
✅ Digital signatures for verification

The app is ready for testing and further development!
