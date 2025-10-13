# 🎨 OnSpot Wallet - Logo Quick Reference

## Logo Files Location

```
📁 assets/images/
   ├── 📄 logo.png           (Main logo - 512x512px recommended)
   ├── 📄 logo_icon.png      (App icon - used in UI)
   └── 📄 PLACE_LOGO_HERE.txt
```

---

## Where Logos Appear

### 1. 📱 App Header

```
┌─────────────────────────────────────────┐
│ [🎨LOGO] OnSpot Wallet    🔔 👤        │ ← Logo appears here
├─────────────────────────────────────────┤
│                                         │
│         App Content                     │
```

- **File:** `custom_app_header.dart`
- **Path:** `assets/images/logo_icon.png`
- **Size:** 36x36 px
- **Style:** White background, rounded corners

---

### 2. 📊 My QR Code

```
┌─────────────────────────────────────────┐
│  MY QR CODE                             │
│                                         │
│  ┌─────────────────────┐               │
│  │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │               │
│  │ ▓▓┌─────────┐▓▓  │               │
│  │ ▓▓│ 🎨LOGO │▓▓  │ ← Logo in center │
│  │ ▓▓└─────────┘▓▓  │               │
│  │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │               │
│  └─────────────────────┘               │
│                                         │
│  User Name: John Doe                    │
│  User ID: USR123456                     │
└─────────────────────────────────────────┘
```

- **File:** `qr_transaction_widget.dart` (line 267)
- **Path:** `assets/images/logo_icon.png`
- **Size:** 40x40 px embedded in QR
- **Purpose:** User's permanent receiving QR code

---

### 3. 💰 Payment QR Code

```
┌─────────────────────────────────────────┐
│  PAYMENT QR GENERATED                   │
│                                         │
│  ┌─────────────────────┐               │
│  │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │               │
│  │ ▓▓┌─────────┐▓▓  │               │
│  │ ▓▓│ 🎨LOGO │▓▓  │ ← Logo in center │
│  │ ▓▓└─────────┘▓▓  │               │
│  │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │               │
│  └─────────────────────┘               │
│                                         │
│  Amount: ₹500.00                        │
│  Purpose: Coffee payment                │
│  Transaction ID: abc123...              │
└─────────────────────────────────────────┘
```

- **File:** `qr_transaction_widget.dart` (line 515)
- **Path:** `assets/images/logo_icon.png`
- **Size:** 40x40 px embedded in QR
- **Purpose:** Generated payment request QR code

---

### 4. 📲 App Launcher Icon

```
┌──────────────────────────────────┐
│  📱 Home Screen / App Drawer     │
│                                  │
│  ┌────┐  ┌────┐  ┌────┐        │
│  │App1│  │App2│  │🎨  │        │ ← OnSpot Wallet Icon
│  └────┘  └────┘  └────┘        │
│                                  │
│  On Spot Wallet                  │
└──────────────────────────────────┘
```

- **Files:** All `android/app/src/main/res/mipmap-*/ic_launcher.png`
- **Source:** `assets/images/logo.png`
- **Sizes Generated:**
  - mdpi: 48x48 px
  - hdpi: 72x72 px
  - xhdpi: 96x96 px
  - xxhdpi: 144x144 px
  - xxxhdpi: 192x192 px
  - Adaptive icon (Android 8.0+)

---

## Code References

### Header Logo (custom_app_header.dart)

```dart
Image.asset(
  'assets/images/logo_icon.png',
  width: 36,
  height: 36,
  fit: BoxFit.contain,
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.account_balance_wallet); // Fallback
  },
)
```

### My QR Logo (qr_transaction_widget.dart - Line 267)

```dart
QrImageView(
  data: 'onspot://user/${user.id}/${user.name}',
  embeddedImage: const AssetImage('assets/images/logo_icon.png'),
  embeddedImageStyle: const QrEmbeddedImageStyle(
    size: Size(40, 40),
  ),
)
```

### Payment QR Logo (qr_transaction_widget.dart - Line 515)

```dart
QrImageView(
  data: _generatedQRData!.toQRString(),
  embeddedImage: const AssetImage('assets/images/logo_icon.png'),
  embeddedImageStyle: const QrEmbeddedImageStyle(
    size: Size(40, 40),
  ),
)
```

### App Icon Config (pubspec.yaml)

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/logo.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/images/logo_icon.png"
```

---

## Testing Checklist

Use this checklist to verify all logos are working:

### Visual Tests:

- [ ] Open app and see logo in header (top left)
- [ ] Navigate to QR scanner
- [ ] Switch to "My QR" tab
- [ ] Verify logo appears in center of QR code
- [ ] Enter amount and purpose
- [ ] Generate payment QR
- [ ] Verify logo appears in payment QR
- [ ] Close app and check home screen
- [ ] Verify OnSpot logo as app icon

### Technical Tests:

- [ ] Logo loads without errors
- [ ] No "asset not found" warnings in console
- [ ] QR codes scan successfully with embedded logo
- [ ] App icon displays on all Android versions
- [ ] Adaptive icon works on Android 8.0+

---

## Quick Commands

### Build Debug APK:

```bash
cd "/home/btwneeraj/Desktop/Projects/OnSpotWallet/application "
fvm flutter build apk --debug
```

### Regenerate Icons (if logo changes):

```bash
fvm flutter pub run flutter_launcher_icons
```

### Run on Device:

```bash
fvm flutter run
```

---

## Troubleshooting

### Logo Not Showing?

1. Check file exists: `assets/images/logo_icon.png`
2. Check pubspec.yaml has: `- assets/images/`
3. Run: `fvm flutter clean && fvm flutter pub get`
4. Rebuild app

### App Icon Not Updated?

1. Uninstall old app from device
2. Run icon generation again
3. Rebuild and install fresh

### QR Logo Missing?

1. Verify file path: `assets/images/logo_icon.png`
2. Check QrImageView has `embeddedImage` property
3. Ensure logo size is 40x40 or smaller

---

## Summary

✅ **4 Logo Locations Implemented:**

1. Header (36x36 px)
2. My QR Code (40x40 px)
3. Payment QR Code (40x40 px)
4. App Icon (48-192 px)

✅ **All logos using correct path:**

- `assets/images/logo_icon.png` for UI
- `assets/images/logo.png` for icon generation

✅ **Build Status:** SUCCESS ✓

**Your OnSpot Wallet now has consistent branding across all screens! 🎉**
