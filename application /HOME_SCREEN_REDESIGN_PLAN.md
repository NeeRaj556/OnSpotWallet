# Home Screen Redesign with Payment Categories - Implementation Plan

## ✅ COMPLETED

### 1. Fixed setState Error in Login Screen

- Added `mounted` checks before all `setState()` calls
- Prevents "setState() called after dispose()" error
- Files: `lib/presentation/screens/login_screen/login_screen.dart`

### 2. Added Balance Visibility Toggle

- Added `bool _isBalanceVisible = false` state variable
- Will show/hide balance with eye icon

### 3. Created Payment Categories Model

- File: `lib/models/payment_category.dart`
- 12 USA payment categories:
  1. **Money Transfer**: Send Money, Request Money, Withdraw, Cash Out
  2. **Banking**: Bank Transfer, Direct Deposit, Wire Transfer, ACH
  3. **Utilities**: Electricity, Water, Gas, Internet, Phone, Cable
  4. **Bills**: Credit Card, Loan, Rent, Mortgage, HOA
  5. **Government**: Traffic Fines, Court Fees, Tax, Parking, DMV
  6. **Travel**: Airlines, Hotels, Car Rental, Insurance, Visa
  7. **Insurance**: Health, Auto, Life, Home, Dental, Vision
  8. **Finance**: Investments, Stocks, Crypto, Mutual Funds, 401k
  9. **Education**: Tuition, Student Loans, Books, Fees, Courses
  10. **Healthcare**: Doctor, Pharmacy, Labs, Hospital, Dental
  11. **Subscriptions**: Streaming, Music, News, Apps, Cloud, Gym
  12. **Shopping**: Online, Grocery, Electronics, Clothing, Home

## 📋 TODO - HOME SCREEN REDESIGN

### Required Changes to `lib/presentation/screens/home_screen/home_screen.dart`:

#### 1. Remove Device Info Card

Remove the `_buildDeviceInfoCard()` method (lines 765+)

#### 2. Update Balance Card with Toggle

```dart
Widget _buildBalanceCardWithToggle() {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: NeonBlueTheme.neonGradient,
      borderRadius: BorderRadius.circular(24),
      boxShadow: NeonBlueTheme.neonGlow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Balance',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              icon: Icon(
                _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.95)],
          ).createShader(bounds),
          child: Text(
            _isBalanceVisible
                ? '\$${_balance.toStringAsFixed(2)}'
                : 'XXXXX',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isOnline ? Icons.wifi : Icons.wifi_off,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                _isOnline ? 'ONLINE' : 'OFFLINE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

#### 3. Add Payment Categories Grid

```dart
Widget _buildPaymentCategories() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          'Services',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: NeonBlueTheme.almostBlack,
          ),
        ),
      ),
      const SizedBox(height: 16),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: paymentCategories.length,
        itemBuilder: (context, index) {
          final category = paymentCategories[index];
          return _buildCategoryCard(category);
        },
      ),
    ],
  );
}

Widget _buildCategoryCard(PaymentCategory category) {
  return GestureDetector(
    onTap: () => _showCategoryServices(category),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: category.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: category.gradientColors[0].withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              category.icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}
```

#### 4. Add Category Services Bottom Sheet

```dart
void _showCategoryServices(PaymentCategory category) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with icon
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: category.gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  category.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Services list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: category.services.length,
              itemBuilder: (context, index) {
                final service = category.services[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Navigate to service
                        Navigator.pop(context);
                        _handleServiceSelection(category, service);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey[200]!,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: category.gradientColors.map(
                                    (c) => c.withOpacity(0.2)
                                  ).toList(),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.payment,
                                color: category.gradientColors[0],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                service,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

void _handleServiceSelection(PaymentCategory category, String service) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: $service'),
        backgroundColor: category.gradientColors[0],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  // TODO: Navigate to payment screen with service details
}
```

#### 5. Update Build Method

```dart
@override
Widget build(BuildContext context) {
  if (_isLoading) {
    return // ... loading screen
  }

  return Scaffold(
    backgroundColor: NeonBlueTheme.offWhite,
    appBar: AppBar(
      title: Text('Hi, $_userName'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: _handleLogout,
        ),
      ],
    ),
    extendBody: true,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: 120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance Card with Toggle (XXXXX by default)
            _buildBalanceCardWithToggle(),
            const SizedBox(height: 24),

            // Payment Categories Grid
            _buildPaymentCategories(),
            const SizedBox(height: 24),

            // Recent Transactions (optional)
            if (_transactions.isNotEmpty)
              _buildNeonTransactionHistory(),
          ],
        ),
      ),
    ),

    // Floating QR Button
    floatingActionButton: _buildAnimatedQRButton(),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  );
}
```

#### 6. Add Import

```dart
import '../../../models/payment_category.dart';
```

## 📊 UI STRUCTURE

```
HOME SCREEN
├── AppBar
│   ├── Title: "Hi, [Name]"
│   ├── Notifications icon
│   └── Settings icon
│
├── Balance Card (Gradient)
│   ├── "Balance" label
│   ├── Eye icon (toggle visibility)
│   ├── XXXXX or $100.00
│   └── ONLINE/OFFLINE badge
│
├── Payment Categories Grid (3 columns)
│   ├── Money Transfer
│   ├── Banking
│   ├── Utilities
│   ├── Bills
│   ├── Government
│   ├── Travel
│   ├── Insurance
│   ├── Finance
│   ├── Education
│   ├── Healthcare
│   ├── Subscriptions
│   └── Shopping
│
├── Recent Transactions (if any)
│
└── Floating QR Button (bottom center)
```

## 🎨 DESIGN FEATURES

1. **Balance Privacy**

   - Shows "XXXXX" by default
   - Eye icon to toggle visibility
   - Smooth animation

2. **Category Cards**

   - Gradient backgrounds
   - Icons with circular bg
   - Shadow effects
   - Tap to show services

3. **Service Selection**

   - Bottom sheet with services list
   - Each service has icon
   - Smooth navigation

4. **Responsive Grid**
   - 3 columns on mobile
   - Auto-adjusts height
   - Consistent spacing

## 📱 USER FLOW

1. User sees balance as "XXXXX"
2. Taps eye icon → Balance shows $100.00
3. Taps category (e.g., Utilities)
4. Bottom sheet opens with services
5. Taps service (e.g., Electricity)
6. Navigates to payment screen

## ✅ NEXT STEPS

1. Apply changes to home_screen.dart
2. Test balance toggle
3. Test category navigation
4. Add service-specific screens
5. Integrate with payment flow

---

**Status**: Plan Complete - Ready for Implementation
**Date**: October 12, 2025
