# 📱 OnSpot Wallet - Complete App Navigation Guide

## 🏠 App Structure

```
┌─────────────────────────────────────────┐
│           OnSpot Wallet                 │
├─────────────────────────────────────────┤
│                                         │
│         📄  CURRENT SCREEN              │
│                                         │
│         (Content varies by tab)         │
│                                         │
│                                         │
│            ┌───────────┐                │
│            │ 📷 SCAN  │  ← Floating     │
│            └───────────┘                │
├─────────────────────────────────────────┤
│  [🏠]  [📄]  [💬]  [👤]  ← Bottom Nav  │
│  Home  State Support Profile            │
└─────────────────────────────────────────┘
```

---

## Tab 1: 🏠 HOME

```
╔═══════════════════════════════════════╗
║  OnSpot Wallet                        ║
╠═══════════════════════════════════════╣
║                                       ║
║  ┌─────────────────────────────────┐ ║
║  │ Balance          👁 🔄          │ ║
║  │                                 │ ║
║  │      XXXXX                      │ ║
║  │                                 │ ║
║  │ [🛜 ONLINE]                     │ ║
║  └─────────────────────────────────┘ ║
║                                       ║
║  Services                             ║
║                                       ║
║  ┌─────┐ ┌─────┐ ┌─────┐            ║
║  │ 💸  │ │ 🏦  │ │ ⚡  │            ║
║  │Money│ │Bank │ │Util │            ║
║  └─────┘ └─────┘ └─────┘            ║
║                                       ║
║  ┌─────┐ ┌─────┐ ┌─────┐            ║
║  │ 📄  │ │ 🏛️  │ │ ✈️  │            ║
║  │Bills│ │Govt │ │Trav │            ║
║  └─────┘ └─────┘ └─────┘            ║
║                                       ║
║  ┌─────┐ ┌─────┐ ┌─────┐            ║
║  │ 🛡️  │ │ 📈  │ │ 🎓  │            ║
║  │Insur│ │Fin  │ │ Edu │            ║
║  └─────┘ └─────┘ └─────┘            ║
║                                       ║
║  ┌─────┐ ┌─────┐ ┌─────┐            ║
║  │ 🏥  │ │ 📺  │ │ 🛍️  │            ║
║  │Hlth │ │Subs │ │Shop │            ║
║  └─────┘ └─────┘ └─────┘            ║
║                                       ║
║         ┌─────────────┐               ║
║         │  📷 SCAN   │                ║
║         └─────────────┘               ║
╠═══════════════════════════════════════╣
║  [🏠]  [📄]  [💬]  [👤]              ║
║  Home  State Support Profile          ║
╚═══════════════════════════════════════╝
```

### Features:

- **Balance Card**: Hidden by default (XXXXX), tap 👁 to reveal
- **12 Payment Categories**: Tap to see services
- **Floating SCAN**: Always accessible for QR payments
- **No Logout**: Moved to Profile tab

---

## Tab 2: 📄 STATEMENT

```
╔═══════════════════════════════════════╗
║  Statement                            ║
╠═══════════════════════════════════════╣
║  ┌─────────────────────────────────┐ ║
║  │ 🔍 Search transactions...       │ ║
║  └─────────────────────────────────┘ ║
║                                       ║
║  [All] [Sent] [Received]  ← Filters  ║
║                                       ║
║  ┌─────────────────────────────────┐ ║
║  │ [↑] Sent            -$25.00     │ ║
║  │     abc123456789   Confirmed    │ ║
║  │     2025-10-13 10:30            │ ║
║  └─────────────────────────────────┘ ║
║                                       ║
║  ┌─────────────────────────────────┐ ║
║  │ [↓] Received        +$50.00     │ ║
║  │     xyz987654321   Pending      │ ║
║  │     2025-10-13 09:15            │ ║
║  └─────────────────────────────────┘ ║
║                                       ║
║  ┌─────────────────────────────────┐ ║
║  │ [↑] Sent            -$10.00     │ ║
║  │     def456789012   Confirmed    │ ║
║  │     2025-10-12 18:45            │ ║
║  └─────────────────────────────────┘ ║
║                                       ║
║         ┌─────────────┐               ║
║         │  📷 SCAN   │                ║
║         └─────────────┘               ║
╠═══════════════════════════════════════╣
║  [🏠]  [📄]  [💬]  [👤]              ║
║  Home  State Support Profile          ║
╚═══════════════════════════════════════╝
```

### Features:

- **Search Bar**: Find transactions by device ID or amount
- **Filter Tabs**: All / Sent / Received
- **Transaction Cards**:
  - ↑ Red for sent
  - ↓ Green for received
  - Status: Confirmed or Pending
- **Tap Card**: Opens detail modal

### Transaction Detail Modal:

```
╔═══════════════════════════════════════╗
║  Transaction Details                  ║
╠═══════════════════════════════════════╣
║  Amount:    $25.00                    ║
║  Type:      Sent                      ║
║  Status:    Confirmed                 ║
║  From:      device-abc-123            ║
║  To:        device-xyz-789            ║
║  Created:   2025-10-13 10:30:00       ║
║  TX ID:     tx-123456789              ║
║  Signature: abc123...                 ║
║  Hops:      3                         ║
╚═══════════════════════════════════════╝
```

---

## Tab 3: 💬 SUPPORT

```
╔═══════════════════════════════════════╗
║  Support                              ║
╠═══════════════════════════════════════╣
║  ┌─────────────────────────────────┐ ║
║  │  🎧                             │ ║
║  │  How can we help you?           │ ║
║  │  We're here 24/7 to assist      │ ║
║  └─────────────────────────────────┘ ║
║                                       ║
║  Quick Actions                        ║
║                                       ║
║  ┌─────────────────────────────────┐ ║
║  │ 📧 Email Support             →  │ ║
║  │    support@onspotwallet.com     │ ║
║  └─────────────────────────────────┘ ║
║                                       ║
║  ┌─────────────────────────────────┐ ║
║  │ 📞 Call Us                   →  │ ║
║  │    1-800-ONSPOT-WALLET          │ ║
║  └─────────────────────────────────┘ ║
║                                       ║
║  ┌─────────────────────────────────┐ ║
║  │ 💬 Live Chat                 →  │ ║
║  │    Chat with support team       │ ║
║  └─────────────────────────────────┘ ║
║                                       ║
║  ┌─────────────────────────────────┐ ║
║  │ ❓ FAQs                      →  │ ║
║  │    Common questions             │ ║
║  └─────────────────────────────────┘ ║
║                                       ║
║  Resources                            ║
║  • User Guide                         ║
║  • Security Tips                      ║
║  • Terms & Privacy                    ║
║  • Report a Bug                       ║
║                                       ║
║  Connect: [FB] [TW] [IG] [LI]        ║
║                                       ║
║         ┌─────────────┐               ║
║         │  📷 SCAN   │                ║
║         └─────────────┘               ║
╠═══════════════════════════════════════╣
║  [🏠]  [📄]  [💬]  [👤]              ║
║  Home  State Support Profile          ║
╚═══════════════════════════════════════╝
```

### Features:

- **Email Support**: Opens mail app
- **Call Support**: Opens phone dialer
- **Live Chat**: Coming soon dialog
- **FAQs**: Expandable Q&A list
- **Resources**: Help docs & policies
- **Social Links**: Connect on social media

### FAQs Screen:

```
╔═══════════════════════════════════════╗
║  ← FAQs                               ║
╠═══════════════════════════════════════╣
║  ▼ How do I send money?               ║
║    Tap SCAN button, scan QR code,     ║
║    enter amount, confirm payment.     ║
║                                       ║
║  ▶ What are transaction limits?       ║
║                                       ║
║  ▶ Is my money safe?                  ║
║                                       ║
║  ▶ How does offline mode work?        ║
║                                       ║
║  ▶ Can I cancel a transaction?        ║
╚═══════════════════════════════════════╝
```

---

## Tab 4: 👤 PROFILE

```
╔═══════════════════════════════════════╗
║  Profile                              ║
╠═══════════════════════════════════════╣
║  ┌─────────────────────────────────┐ ║
║  │    ┌─────────┐                  │ ║
║  │    │  👤    │                  │ ║
║  │    └─────────┘                  │ ║
║  │                                 │ ║
║  │   User Name                     │ ║
║  │   user@example.com              │ ║
║  │   +1 (555) 123-4567            │ ║
║  │                                 │ ║
║  │   [● ACTIVE]                    │ ║
║  │                                 │ ║
║  │   [Edit Profile]                │ ║
║  └─────────────────────────────────┘ ║
║                                       ║
║  Settings                             ║
║  • 🎨 Appearance                      ║
║  • 🔔 Notifications        [ON]       ║
║                                       ║
║  Payment                              ║
║  • 💳 My Payments                     ║
║  • 📜 Payment History                 ║
║  • 🏦 Linked Accounts                 ║
║                                       ║
║  Security                             ║
║  • 🔒 Change PIN                      ║
║  • 👆 Biometric Auth                  ║
║  • 🛡️ Security Settings               ║
║                                       ║
║  Other                                ║
║  • 🎁 Special Offers          [3]     ║
║  • ℹ️ About                           ║
║  • 🔄 Check for Updates               ║
║  • 📞 Contact Us                      ║
║                                       ║
║  ┌─────────────────────────────────┐ ║
║  │      🚪 Logout                  │ ║
║  └─────────────────────────────────┘ ║
║                                       ║
║         ┌─────────────┐               ║
║         │  📷 SCAN   │                ║
║         └─────────────┘               ║
╠═══════════════════════════════════════╣
║  [🏠]  [📄]  [💬]  [👤]              ║
║  Home  State Support Profile          ║
╚═══════════════════════════════════════╝
```

### Profile Info:

- **Avatar**: Circular profile picture
- **Name**: User's display name
- **Email**: Contact email
- **Phone**: Phone number
- **Status**: Active/Inactive indicator
- **Edit Button**: Update profile info

### Settings Categories:

#### ⚙️ Settings

- **Appearance** → Light/Dark mode
- **Notifications** → Toggle ON/OFF

#### 💰 Payment

- **My Payments** → Saved payment methods
- **Payment History** → All transactions
- **Linked Accounts** → Bank connections

#### 🔐 Security

- **Change PIN** → Update 4-digit PIN
- **Biometric** → Face/Fingerprint (Coming Soon)
- **Security Settings** → Advanced options

#### 📦 Other

- **Special Offers** → Deals & rewards (Badge: 3)
- **About** → Version info (v1.0.0)
- **Check Updates** → Update check
- **Contact Us** → Support info

#### 🚪 Logout

- Red button at bottom
- Shows confirmation dialog
- Clears all data
- Returns to login

---

## 🔄 Navigation Flows

### Flow 1: Make a Payment

```
Home → Tap SCAN → QR Scanner →
Enter Amount → Confirm → Payment Success
```

### Flow 2: View Transaction

```
Statement → Search/Filter → Tap Card →
View Details → Close
```

### Flow 3: Get Support

```
Support → Tap Email/Call →
Contact Opens → Send Message/Call
```

### Flow 4: Change Settings

```
Profile → Tap Setting → Adjust →
Auto-saves → Return
```

### Flow 5: Logout

```
Profile → Scroll Down → Tap Logout →
Confirm → Login Screen
```

---

## 🎨 Visual Theme

### Bottom Navigation States

**Inactive Tab** (Grey)

```
  📄
State
```

**Active Tab** (Neon Gradient)

```
┌─────────┐
│   📄   │
│  State  │
└─────────┘
  (Glowing)
```

### Color Coding

| Element   | Color      | Usage                   |
| --------- | ---------- | ----------------------- |
| Sent      | Red/Orange | Outgoing payments       |
| Received  | Green      | Incoming payments       |
| Confirmed | Green      | Completed transactions  |
| Pending   | Orange     | Processing transactions |
| Online    | Blue       | Connected to internet   |
| Offline   | Grey       | BLE mesh mode           |
| Active    | Green      | Profile active status   |

---

## ⌨️ Quick Actions

### Keyboard Shortcuts (Future)

- `Ctrl+1` → Home
- `Ctrl+2` → Statement
- `Ctrl+3` → Support
- `Ctrl+4` → Profile
- `Ctrl+S` → Open SCAN
- `Ctrl+F` → Search (in Statement)

---

## 📊 Screen States

### Empty States

**Statement (No Transactions)**

```
┌─────────────────────┐
│    📄              │
│                     │
│ No Transactions Yet │
│                     │
│ Your history will   │
│ appear here         │
└─────────────────────┘
```

**Support (Feature Coming Soon)**

```
┌─────────────────────┐
│    Coming Soon!     │
│                     │
│ This feature will   │
│ be available in     │
│ the next update     │
│                     │
│    [  OK  ]         │
└─────────────────────┘
```

---

## 🎯 Pro Tips

### Home Tab

💡 **Tip**: Double-tap balance card to quick toggle visibility

### Statement Tab

💡 **Tip**: Pull down to refresh transaction list

### Support Tab

💡 **Tip**: Save support email to contacts for quick access

### Profile Tab

💡 **Tip**: Enable notifications for real-time payment alerts

---

## 🔔 Notifications

### When Enabled (in Profile)

- ✅ Payment received
- ✅ Payment sent
- ✅ Payment confirmed
- ✅ Special offers
- ✅ App updates

### Badge Indicators

- **Special Offers**: Red badge with count (3)
- **New Messages**: Blue dot (Coming Soon)
- **Unread Notifications**: Red dot (Coming Soon)

---

## 📱 Responsive Design

### Mobile (Default)

- 3 columns for payment categories
- Full-width transaction cards
- Stacked profile sections

### Tablet (Future)

- 4-5 columns for payment categories
- 2-column transaction cards
- Side-by-side profile sections

---

## 🌍 Accessibility

### Features

- ✅ High contrast mode (neon colors)
- ✅ Large touch targets (48x48 minimum)
- ✅ Clear labels and icons
- ✅ Screen reader support (Future)
- ✅ Font scaling support (Future)

---

## ⚡ Performance

### Optimization

- `IndexedStack` for instant tab switching
- Lazy loading for transaction history
- Cached profile data
- Optimized images and icons
- Smooth animations (60fps)

---

## 🎉 Summary

**Total Screens**: 5 (Main Nav + 4 Tabs + FAQs)  
**Navigation Tabs**: 4  
**Quick Actions**: 12  
**Settings Options**: 12  
**Support Channels**: 4

**User Journey**:
Login → Home (with balance privacy) → Explore categories →
View transactions → Get support → Manage profile → Logout

**Key Features**:
✅ Bottom navigation with 4 tabs  
✅ Hidden balance with eye toggle  
✅ Transaction filtering & search  
✅ Complete support system  
✅ Comprehensive profile settings  
✅ Floating QR button on all tabs  
✅ Consistent neon theme

---

**Date**: October 13, 2025  
**Version**: 1.0.0  
**Build**: 100  
**Status**: ✅ Production Ready

**📱 Complete Navigation System Implemented Successfully! 📱**
