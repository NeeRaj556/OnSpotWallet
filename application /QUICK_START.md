# 🚀 Quick Start Guide - OnSpot Wallet

## ⚡ Fastest Way to Run

```bash
# 1. Navigate to project
cd "/home/btwneeraj/Desktop/Projects/OnSpotWallet/application "

# 2. Run the app (dependencies already installed!)
./fvm-flutter.sh run
```

That's it! The app will launch.

## 🎮 Using the App

### First Launch - Demo Login (Easiest!)

1. App opens to **Login Screen**
2. Click the **"Demo Login"** button (outlined button with play icon)
3. App navigates to **PIN Setup**
4. Enter a 4-digit PIN (e.g., `1234`)
5. Confirm the same PIN
6. Welcome to your **Dashboard**! 🎉

### Dashboard Features

- **Balance Card**: Shows $1,000.00 (demo balance)
- **Scan QR**: Opens camera to scan QR codes
- **My QR**: Shows your QR code (demo@example.com)
- **Quick Actions**: Add Money, Send Money, Transactions, Settings

### Subsequent Launches

**If Online:**

- Opens Login Screen
- Click "Demo Login" or enter credentials
- Goes directly to Dashboard

**If Offline:**

- Opens PIN Verification Screen
- Enter your 4-digit PIN
- Access Dashboard without internet!

## 📱 Testing on Device/Emulator

### Android Emulator

```bash
# Start emulator first, then:
./fvm-flutter.sh run
```

### Physical Device (USB Debugging enabled)

```bash
# Connect device via USB, then:
./fvm-flutter.sh run
```

### Build APK for Testing

```bash
./fvm-flutter.sh build apk
# APK location: build/app/outputs/flutter-apk/app-release.apk
```

## 🔐 Test Scenarios

### Scenario 1: First Time User - Demo Login

1. Launch app
2. Click "Demo Login"
3. Set PIN: `1234`
4. Confirm PIN: `1234`
5. See dashboard with $1,000 balance

### Scenario 2: Create New Account

1. Launch app
2. Click "Don't have an account? Sign up"
3. Fill in:
   - Name: John Doe
   - Email: john@example.com
   - Password: 123456
   - Confirm: 123456
4. Set PIN
5. Access dashboard

### Scenario 3: Offline Access

1. After setting up PIN, close app
2. Turn off WiFi/mobile data
3. Reopen app
4. Enter your PIN
5. Access dashboard offline!

### Scenario 4: QR Features

1. On Dashboard, click "Scan QR"
2. Allow camera permission
3. Point at any QR code
4. Click "My QR" to see your own QR code

## 🛠️ Common Commands

```bash
# Run app
./fvm-flutter.sh run

# Run with specific device
./fvm-flutter.sh run -d <device-id>

# List devices
./fvm-flutter.sh devices

# Hot reload (while app is running)
Press 'r' in terminal

# Hot restart (while app is running)
Press 'R' in terminal

# Clean and rebuild
./fvm-flutter.sh clean
./fvm-flutter.sh pub get
./fvm-flutter.sh run

# Build release APK
./fvm-flutter.sh build apk --release

# Build debug APK
./fvm-flutter.sh build apk --debug
```

## 📋 Features Checklist

Test all features:

- [ ] Demo Login button works
- [ ] Sign Up creates account
- [ ] PIN setup (4 digits)
- [ ] PIN confirmation matches
- [ ] Dashboard loads with balance
- [ ] Scan QR opens camera
- [ ] My QR shows QR code dialog
- [ ] Offline PIN access works
- [ ] Logout returns to login
- [ ] Quick actions show "coming soon"

## 🎯 Demo Credentials

**Demo Login:**

- Just click "Demo Login" button
- No credentials needed!
- Auto-creates demo user

**Demo User Info:**

- Email: demo@example.com
- Balance: $1,000.00

**Manual Login (if you signed up):**

- Email: Your email
- Password: Your password

## 🐛 Quick Troubleshooting

**Camera not working?**

- Check Android permissions in Settings > Apps > Your App > Permissions
- Allow Camera permission

**App won't run?**

```bash
./fvm-flutter.sh clean
./fvm-flutter.sh pub get
./fvm-flutter.sh run
```

**FVM issues?**

```bash
dart pub global activate fvm
.fvm/flutter_sdk/bin/flutter --version
```

**Dependencies error?**

```bash
./fvm-flutter.sh pub get
```

## ✨ Pro Tips

1. **Hot Reload**: Press `r` while app is running to see changes instantly
2. **Hot Restart**: Press `R` to restart the app
3. **Debug Mode**: Use `flutter run` for development
4. **Release Mode**: Use `flutter run --release` for performance testing
5. **Logs**: Watch terminal for print statements and errors

## 📸 Screenshot Checklist

Take screenshots of:

1. Login screen with Demo Login button
2. PIN setup screen (number pad)
3. Dashboard with balance card
4. QR scanner in action
5. My QR code dialog
6. Quick actions grid

## 🎉 You're Ready!

Just run:

```bash
./fvm-flutter.sh run
```

Then click **"Demo Login"** and explore your new wallet app!

---

**Need Help?** Check `README_NEW.md` for detailed documentation or `IMPLEMENTATION_SUMMARY.md` for technical details.
