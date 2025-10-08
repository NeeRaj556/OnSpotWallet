# OnSpot Wallet - Flutter Application

A secure wallet application with QR code scanning, PIN authentication, and offline access capabilities.

## Features

- **Login & Signup**: User authentication with email and password
- **Demo Login**: Quick demo access without creating an account
- **PIN Security**: 4-digit PIN for quick and secure access
- **Offline Access**: Use PIN to access the app when offline
- **QR Code Scanner**: Scan QR codes for transactions
- **QR Code Display**: Show your personal QR code for receiving payments
- **Balance Display**: View your current wallet balance
- **Modern UI**: Clean and intuitive user interface

## Project Structure

```
lib/
├── app/
│   ├── config/          # App configuration
│   ├── const/           # Constants and keys
│   ├── routes/          # Navigation routes
│   └── services/        # Services (SharedPreferences, Connectivity)
├── core/
│   ├── apis/            # API clients
│   ├── model/           # Data models
│   └── notifiers/       # State management
├── presentation/
│   ├── screens/
│   │   ├── login_screen/
│   │   ├── signup_screen/
│   │   ├── pin_screen/
│   │   └── home_screen/
│   └── widgets/         # Reusable UI components
└── main.dart            # App entry point
```

## Setup Instructions

### Prerequisites

- Flutter SDK 3.27.1 (managed via FVM)
- Dart 3.6.0
- FVM (Flutter Version Manager)

### Using FVM (Recommended)

This project uses FVM to manage Flutter versions. FVM is already configured with Flutter 3.27.1.

1. **Install FVM globally** (if not already installed):

   ```bash
   dart pub global activate fvm
   ```

2. **Install dependencies**:

   ```bash
   .fvm/flutter_sdk/bin/flutter pub get
   ```

   Or use the provided script:

   ```bash
   ./fvm-flutter.sh pub get
   ```

3. **Run the app**:

   ```bash
   .fvm/flutter_sdk/bin/flutter run
   ```

   Or use the provided script:

   ```bash
   ./fvm-flutter.sh run
   ```

### Alternative: Configure your IDE to use FVM

#### VS Code

Add to `.vscode/settings.json`:

```json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk"
}
```

#### Android Studio / IntelliJ

1. Go to: `Settings > Languages & Frameworks > Flutter`
2. Set Flutter SDK path to: `<project-root>/.fvm/flutter_sdk`

## Running the Application

### Using FVM Script (Easiest)

```bash
# Get dependencies
./fvm-flutter.sh pub get

# Run the app
./fvm-flutter.sh run

# Build APK
./fvm-flutter.sh build apk

# Run tests
./fvm-flutter.sh test
```

### Direct FVM Commands

```bash
# Get dependencies
.fvm/flutter_sdk/bin/flutter pub get

# Run the app
.fvm/flutter_sdk/bin/flutter run

# Build APK
.fvm/flutter_sdk/bin/flutter build apk
```

## App Flow

### First-Time Users

1. Open app → Login/Signup screen
2. **Option 1**: Create account via Signup
   - Enter name, email, and password
   - Account created successfully
3. **Option 2**: Use Demo Login
   - Instant access with demo credentials
4. Set up 4-digit PIN
5. Access Dashboard

### Returning Users (Online)

1. Open app → Login screen
2. Enter credentials or use Demo Login
3. Access Dashboard (PIN already set)

### Returning Users (Offline)

1. Open app → PIN Verification screen
2. Enter 4-digit PIN
3. Access Dashboard

## Dashboard Features

- **Balance Card**: Displays current wallet balance with gradient design
- **Scan QR**: Opens camera to scan QR codes
- **My QR**: Shows your personal QR code for receiving payments
- **Quick Actions**:
  - Add Money
  - Send Money
  - Transaction History
  - Settings

## Demo Login Credentials

- **Email**: demo@example.com
- **Initial Balance**: $1000.00

## Dependencies

### Main Dependencies

- `flutter`: SDK
- `qr_code_scanner`: QR code scanning functionality
- `qr_flutter`: QR code generation and display
- `shared_preferences`: Local data storage
- `go_router`: Navigation
- `provider`: State management
- `dio`: HTTP client
- `connectivity_plus`: Network connectivity detection
- `flex_color_scheme`: Theming
- `permission_handler`: Handle camera permissions

### Dev Dependencies

- `flutter_test`: Testing framework
- `flutter_lints`: Linting rules
- `build_runner`: Code generation
- `json_serializable`: JSON serialization

## Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## iOS Permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes</string>
```

## Local Storage Keys

The app stores the following data locally:

- `user_name`: User's full name
- `user_email`: User's email
- `user_password`: User's password (for demo purposes)
- `user_pin`: 4-digit PIN (encrypted in production)
- `is_logged_in`: Login status
- `user_balance`: Current wallet balance

## Security Notes

⚠️ **Important**: This is a demo application. In a production environment:

- Never store passwords in plain text
- Implement proper encryption for PIN storage
- Use secure backend authentication
- Implement token-based authentication
- Add biometric authentication option
- Use HTTPS for all API calls

## Troubleshooting

### FVM Issues

If FVM is not working:

```bash
# Reactivate FVM
dart pub global activate fvm

# Verify Flutter version
.fvm/flutter_sdk/bin/flutter --version
```

### Dependency Issues

```bash
# Clean and reinstall
.fvm/flutter_sdk/bin/flutter clean
.fvm/flutter_sdk/bin/flutter pub get
```

### Build Issues

```bash
# Clean build cache
.fvm/flutter_sdk/bin/flutter clean

# Rebuild
.fvm/flutter_sdk/bin/flutter build apk --release
```

## Future Enhancements

- [ ] Backend API integration
- [ ] Real transaction processing
- [ ] Transaction history
- [ ] Biometric authentication (fingerprint/face ID)
- [ ] Multiple currency support
- [ ] Push notifications
- [ ] User profile management
- [ ] Dark mode support
- [ ] Multi-language support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License.

## Contact

For questions or support, please contact the development team.

---

**Built with Flutter 3.27.1 using FVM**
