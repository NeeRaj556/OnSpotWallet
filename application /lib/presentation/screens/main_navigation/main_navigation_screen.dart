import 'package:flutter/material.dart';
import '../../../app/theme/neon_theme.dart';
import '../home_screen/home_screen.dart';
import '../statement_screen/statement_screen.dart';
import '../support_screen/support_screen.dart';
import '../profile_screen/profile_screen.dart';
import '../../widgets/custom_app_header.dart';
import '../../widgets/profile_modal.dart';
import '../../widgets/qr_transaction_widget.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Reference to statement screen to update transactions
  final GlobalKey<State<StatementScreen>> _statementKey = GlobalKey();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      StatementScreen(key: _statementKey),
      const SupportScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppHeader(
        notificationCount: 3,
        onNotificationTap: _showNotifications,
        onProfileTap: _showProfileModal,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: false,
      bottomNavigationBar: _buildModernBottomNav(isDarkMode: isDarkMode),
      floatingActionButton: _buildFloatingQRButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showNotifications() {
    // TODO: Show notifications screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications feature coming soon!')),
    );
  }

  void _showProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileModal(
        onSettingsTap: () {
          Navigator.pop(context);
          setState(() {
            _currentIndex = 3; // Navigate to Profile tab
          });
        },
      ),
    );
  }

  Widget _buildModernBottomNav({bool isDarkMode = false}) {
    final bgColor = isDarkMode ? Colors.grey[900]! : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;

    // Get the actual bottom padding (for devices with gesture navigation)
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Calculate base height - reduced by 1px to prevent overflow
    final baseHeight = 59.0;

    // Total height includes bottom padding
    final totalHeight = baseHeight + bottomPadding;

    return Container(
      height: totalHeight,
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      // Use padding instead of SafeArea to have more control
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: ClipPath(
        clipper: _BottomNavClipper(),
        child: Container(
          height: baseHeight,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              top: BorderSide(
                width: 0.5, // Reduced border width to prevent overflow
                color: borderColor,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: 'Statement',
                index: 1,
              ),
              const SizedBox(width: 75), // Space for center FAB
              _buildNavItem(
                icon: Icons.support_agent_outlined,
                activeIcon: Icons.support_agent,
                label: 'Support',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingQRButton() {
    // Responsive button size
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = (screenWidth * 0.16).clamp(60.0, 70.0);
    final iconSize = (buttonSize * 0.46).clamp(28.0, 32.0);

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: NeonBlueTheme.neonGradient,
        boxShadow: [
          BoxShadow(
            color: NeonBlueTheme.neonBlue.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: NeonBlueTheme.electricBlue.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showQRScanner,
          customBorder: const CircleBorder(),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showQRScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QRTransactionWidget(
        userId: 'USER123', // TODO: Get from actual user data
        userName: 'User Name', // TODO: Get from actual user data
        onQRScanned: (qrData) {
          debugPrint('QR Scanned: $qrData');
          // TODO: Handle scanned QR data - initiate transaction
        },
        onQRGenerated: (qrData) {
          debugPrint('QR Generated: $qrData');
          // TODO: Handle generated QR data - share with others
        },
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (mounted) {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
                vertical: 3), // Further reduced to prevent overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: isActive ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 1.0 + (value * 0.15),
                      child: Container(
                        padding: const EdgeInsets.all(6), // Reduced padding
                        decoration: BoxDecoration(
                          gradient:
                              isActive ? NeonBlueTheme.neonGradient : null,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color:
                                        NeonBlueTheme.neonBlue.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          isActive ? activeIcon : icon,
                          color: isActive ? Colors.white : inactiveColor,
                          size: 22, // Slightly smaller icon
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 2), // Minimal spacing
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? NeonBlueTheme.neonBlue : inactiveColor,
                    fontSize: 10, // Smaller font
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom clipper for bottom navigation bar with center notch
class _BottomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    const notchRadius = 40.0;
    const notchMargin = 8.0;
    final centerX = size.width / 2;

    // Start from top left
    path.moveTo(0, 0);

    // Draw to the left side of the notch
    path.lineTo(centerX - notchRadius - notchMargin, 0);

    // Create the notch curve
    path.quadraticBezierTo(
      centerX - notchRadius - notchMargin,
      0,
      centerX - notchRadius,
      notchMargin,
    );

    path.arcToPoint(
      Offset(centerX + notchRadius, notchMargin),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    path.quadraticBezierTo(
      centerX + notchRadius + notchMargin,
      0,
      centerX + notchRadius + notchMargin,
      0,
    );

    // Draw to top right
    path.lineTo(size.width, 0);

    // Draw right side
    path.lineTo(size.width, size.height);

    // Draw bottom
    path.lineTo(0, size.height);

    // Close path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
