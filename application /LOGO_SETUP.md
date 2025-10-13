# Logo Setup Instructions

## 1. Save Your Logo Files

Place your OnSpot Wallet logo image in:

```
/home/btwneeraj/Desktop/Projects/OnSpotWallet/application/assets/images/
```

Required files:

- `logo.png` - Main logo (recommended: 512x512 px, transparent PNG)
- `logo_icon.png` - App icon version (optional, can be same as logo.png)

## 2. App Icon Setup

For Android app icon, you need to create different sizes:

### Manual Method:

Place icon files in these directories:

```
android/app/src/main/res/
├── mipmap-mdpi/ic_launcher.png (48x48)
├── mipmap-hdpi/ic_launcher.png (72x72)
├── mipmap-xhdpi/ic_launcher.png (96x96)
├── mipmap-xxhdpi/ic_launcher.png (144x144)
└── mipmap-xxxhdpi/ic_launcher.png (192x192)
```

### Automated Method (Recommended):

1. Install flutter_launcher_icons package:

```bash
fvm flutter pub add dev:flutter_launcher_icons
```

2. Add to pubspec.yaml:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/logo.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/images/logo.png"
```

3. Generate icons:

```bash
fvm flutter pub run flutter_launcher_icons
```

## 3. Current Logo Usage

The logo is now used in:

- ✅ App Header (top navigation bar)
- ✅ QR "My QR" section (embedded in QR code)
- ⏳ App Icon (pending icon files)

## 4. Fallback Behavior

If logo.png is not found, the app will show:

- Wallet icon in header (temporary fallback)
- Default QR code without embedded image

## 5. Quick Setup

1. Save your logo as PNG (transparent background recommended)
2. Copy to: `assets/images/logo.png`
3. Rebuild the app:

```bash
cd "/home/btwneeraj/Desktop/Projects/OnSpotWallet/application "
fvm flutter build apk --debug
```

## Logo Specifications

### Header Logo:

- Size: 36x36 px displayed
- Format: PNG with transparency
- Colors: Should work on gradient background

### QR Embedded Logo:

- Size: 40x40 px displayed
- Format: PNG
- Background: Transparent or white
- Will appear in center of QR codes

### App Icon:

- Size: 512x512 px (source)
- Format: PNG
- Background: Can be solid or transparent
- Will be automatically resized for all densities

## Current Status

✅ Code is ready for logo
✅ Assets folder configured
✅ Fallback icons in place
⏳ Waiting for logo.png file

Once you place logo.png in assets/images/, rebuild and the logo will appear automatically!
