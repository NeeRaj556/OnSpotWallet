import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/theme/neon_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'User';
  String _userPhone = '+1 (555) 123-4567';
  String _userEmail = 'user@example.com';
  bool _isActive = true;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? 'User';
        _userPhone = prefs.getString('user_phone') ?? '+1 (555) 123-4567';
        _userEmail = prefs.getString('user_email') ?? 'user@example.com';
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NeonBlueTheme.offWhite,
      child: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: NeonBlueTheme.almostBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: NeonBlueTheme.neonGradient,
                  ),
                ),
              ],
            ),
          ),

          // Body Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Header Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: NeonBlueTheme.neonGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: NeonBlueTheme.neonGlow,
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  NeonBlueTheme.neonBlue.withOpacity(0.3),
                                  NeonBlueTheme.electricBlue.withOpacity(0.3),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 48,
                              color: NeonBlueTheme.neonBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name
                        Text(
                          _userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Email
                        Text(
                          _userEmail,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Phone
                        Text(
                          _userPhone,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Active Status
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isActive
                                ? NeonBlueTheme.neonGreen.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isActive
                                  ? NeonBlueTheme.neonGreen
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _isActive
                                      ? NeonBlueTheme.neonGreen
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isActive ? 'ACTIVE' : 'INACTIVE',
                                style: TextStyle(
                                  color: _isActive
                                      ? NeonBlueTheme.neonGreen
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Edit Profile Button
                        ElevatedButton(
                          onPressed: () => _editProfile(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: NeonBlueTheme.neonBlue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Settings Section
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: NeonBlueTheme.almostBlack,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSettingCard(
                    icon: Icons.palette_outlined,
                    title: 'Appearance',
                    subtitle: 'Customize app theme',
                    onTap: () => _showAppearanceSettings(),
                  ),

                  _buildSwitchCard(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Push notifications',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                        _saveNotificationSetting(value);
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Payment Section
                  const Text(
                    'Payment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: NeonBlueTheme.almostBlack,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSettingCard(
                    icon: Icons.payment,
                    title: 'My Payments',
                    subtitle: 'View payment methods',
                    onTap: () => _showMyPayments(),
                  ),

                  _buildSettingCard(
                    icon: Icons.history,
                    title: 'Payment History',
                    subtitle: 'View all transactions',
                    onTap: () => _showPaymentHistory(),
                  ),

                  _buildSettingCard(
                    icon: Icons.account_balance_wallet,
                    title: 'Linked Accounts',
                    subtitle: 'Manage bank accounts',
                    onTap: () => _showLinkedAccounts(),
                  ),

                  const SizedBox(height: 24),

                  // Security Section
                  const Text(
                    'Security',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: NeonBlueTheme.almostBlack,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSettingCard(
                    icon: Icons.lock_outline,
                    title: 'Change PIN',
                    subtitle: 'Update your security PIN',
                    onTap: () => _changePIN(),
                  ),

                  _buildSettingCard(
                    icon: Icons.fingerprint,
                    title: 'Biometric Auth',
                    subtitle: 'Face ID / Fingerprint',
                    onTap: () => _setupBiometric(),
                  ),

                  _buildSettingCard(
                    icon: Icons.security,
                    title: 'Security Settings',
                    subtitle: 'Privacy & security options',
                    onTap: () => _showSecuritySettings(),
                  ),

                  const SizedBox(height: 24),

                  // Other Section
                  const Text(
                    'Other',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: NeonBlueTheme.almostBlack,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSettingCard(
                    icon: Icons.card_giftcard,
                    title: 'Special Offers',
                    subtitle: 'Exclusive deals & rewards',
                    onTap: () => _showOffers(),
                    badge: '3',
                  ),

                  _buildSettingCard(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'Version 1.0.0',
                    onTap: () => _showAbout(),
                  ),

                  _buildSettingCard(
                    icon: Icons.system_update,
                    title: 'Check for Updates',
                    subtitle: 'Keep app up to date',
                    onTap: () => _checkForUpdates(),
                  ),

                  _buildSettingCard(
                    icon: Icons.contact_support,
                    title: 'Contact Us',
                    subtitle: 'Get help & support',
                    onTap: () => _contactUs(),
                  ),

                  const SizedBox(height: 24),

                  // Logout Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[400]!, Colors.red[600]!],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleLogout(),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.logout, color: Colors.white),
                              SizedBox(width: 12),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: NeonBlueTheme.neonBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: NeonBlueTheme.neonBlue, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: NeonBlueTheme.neonGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: NeonBlueTheme.neonBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: NeonBlueTheme.neonBlue, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: NeonBlueTheme.neonBlue,
          ),
        ],
      ),
    );
  }

  // Action handlers
  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Profile editing feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAppearanceSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Appearance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light Mode'),
              trailing: Radio(
                value: false,
                groupValue: _darkModeEnabled,
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      _darkModeEnabled = false;
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode (Coming Soon)'),
              trailing: Radio(
                value: true,
                groupValue: _darkModeEnabled,
                onChanged: null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  void _showMyPayments() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('My Payments opening...')),
    );
  }

  void _showPaymentHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment History opening...')),
    );
  }

  void _showLinkedAccounts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Linked Accounts opening...')),
    );
  }

  void _changePIN() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change PIN'),
        content: const Text(
            'PIN change feature coming soon!\nPlease contact support to change your PIN.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _setupBiometric() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Biometric Authentication'),
        content: const Text(
            'Biometric authentication will be available in the next update!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSecuritySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Security Settings opening...')),
    );
  }

  void _showOffers() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Special Offers'),
        content: const Text(
            '🎉 You have 3 special offers waiting!\n\n1. Get 5% cashback on utilities\n2. Refer a friend, get \$10\n3. Free transaction fees this month'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About OnSpot Wallet'),
        content: const Text(
            'Version: 1.0.0\nBuild: 100\n\nOnSpot Wallet - Your secure digital wallet with offline payment capabilities.\n\n© 2025 OnSpot Inc.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _checkForUpdates() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check for Updates'),
        content: const Text(
            'You\'re using the latest version!\n\nVersion 1.0.0 (Build 100)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _contactUs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Us'),
        content: const Text(
            'Email: support@onspotwallet.com\nPhone: 1-800-ONSPOT-WALLET\n\nSupport hours: 24/7'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
