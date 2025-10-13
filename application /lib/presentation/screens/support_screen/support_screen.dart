import 'package:flutter/material.dart';
import '../../../app/theme/neon_theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

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
                  'Support',
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
                  // Support Header Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: NeonBlueTheme.neonGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: NeonBlueTheme.neonGlow,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.support_agent,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'How can we help you?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We\'re here 24/7 to assist you',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: NeonBlueTheme.almostBlack,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSupportCard(
                    context,
                    icon: Icons.email_outlined,
                    title: 'Email Support',
                    subtitle: 'support@onspotwallet.com',
                    gradientColors: [
                      NeonBlueTheme.neonBlue,
                      NeonBlueTheme.electricBlue
                    ],
                    onTap: () => _launchEmail('support@onspotwallet.com'),
                  ),

                  _buildSupportCard(
                    context,
                    icon: Icons.phone_outlined,
                    title: 'Call Us',
                    subtitle: '1-800-ONSPOT-WALLET',
                    gradientColors: [
                      NeonBlueTheme.neonGreen,
                      Color(0xFF00CC70)
                    ],
                    onTap: () => _launchPhone('18006677689'),
                  ),

                  _buildSupportCard(
                    context,
                    icon: Icons.chat_bubble_outline,
                    title: 'Live Chat',
                    subtitle: 'Chat with our support team',
                    gradientColors: [
                      NeonBlueTheme.neonPurple,
                      Color(0xFF9D4EDD)
                    ],
                    onTap: () => _showLiveChat(context),
                  ),

                  _buildSupportCard(
                    context,
                    icon: Icons.help_outline,
                    title: 'FAQs',
                    subtitle: 'Find answers to common questions',
                    gradientColors: [
                      NeonBlueTheme.neonOrange,
                      Color(0xFFFF8C42)
                    ],
                    onTap: () => _showFAQs(context),
                  ),

                  const SizedBox(height: 24),

                  // Other Resources
                  const Text(
                    'Resources',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: NeonBlueTheme.almostBlack,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildResourceCard(
                    context,
                    icon: Icons.menu_book,
                    title: 'User Guide',
                    subtitle: 'Learn how to use the app',
                    onTap: () => _showUserGuide(context),
                  ),

                  _buildResourceCard(
                    context,
                    icon: Icons.security,
                    title: 'Security Tips',
                    subtitle: 'Keep your account safe',
                    onTap: () => _showSecurityTips(context),
                  ),

                  _buildResourceCard(
                    context,
                    icon: Icons.policy_outlined,
                    title: 'Terms & Privacy',
                    subtitle: 'View our policies',
                    onTap: () => _showPolicies(context),
                  ),

                  _buildResourceCard(
                    context,
                    icon: Icons.bug_report_outlined,
                    title: 'Report a Bug',
                    subtitle: 'Help us improve',
                    onTap: () => _reportBug(context),
                  ),

                  const SizedBox(height: 24),

                  // Social Media
                  const Text(
                    'Connect With Us',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: NeonBlueTheme.almostBlack,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialButton(Icons.facebook,
                          () => _launchURL('https://facebook.com')),
                      _buildSocialButton(Icons.telegram,
                          () => _launchURL('https://twitter.com')),
                      _buildSocialButton(Icons.facebook,
                          () => _launchURL('https://instagram.com')),
                      _buildSocialButton(
                          Icons.link, () => _launchURL('https://linkedin.com')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
                    color: Colors.grey[100],
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
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: NeonBlueTheme.neonGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: NeonBlueTheme.neonBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  // Action handlers
  void _launchEmail(String email) {
    // TODO: Implement email launch
    // final uri = Uri.parse('mailto:$email?subject=Support Request');
    // launchUrl(uri);
  }

  void _launchPhone(String phone) {
    // TODO: Implement phone launch
    // final uri = Uri.parse('tel:$phone');
    // launchUrl(uri);
  }

  void _launchURL(String url) {
    // TODO: Implement URL launch
    // final uri = Uri.parse(url);
    // launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showLiveChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Text(
            'Live chat feature coming soon!\nPlease use email or phone support in the meantime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFAQs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FAQsScreen()),
    );
  }

  void _showUserGuide(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User guide opening...')),
    );
  }

  void _showSecurityTips(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Security tips opening...')),
    );
  }

  void _showPolicies(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms & Privacy opening...')),
    );
  }

  void _reportBug(BuildContext context) {
    _launchEmail('bugs@onspotwallet.com');
  }
}

// FAQs Screen
class FAQsScreen extends StatelessWidget {
  const FAQsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonBlueTheme.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'FAQs',
          style: TextStyle(
            color: NeonBlueTheme.almostBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildFAQItem(
            'How do I send money?',
            'Tap the SCAN button, scan the recipient\'s QR code, enter the amount, and confirm the payment.',
          ),
          _buildFAQItem(
            'What are transaction limits?',
            'Online mode: \$1000 per transaction. Offline (BLE) mode: \$10 per transaction.',
          ),
          _buildFAQItem(
            'Is my money safe?',
            'Yes! We use military-grade encryption and secure BLE mesh technology to protect your funds.',
          ),
          _buildFAQItem(
            'How does offline mode work?',
            'Offline mode uses Bluetooth Low Energy (BLE) mesh networking to transfer funds without internet.',
          ),
          _buildFAQItem(
            'Can I cancel a transaction?',
            'Once confirmed, transactions cannot be cancelled. Always verify recipient details before confirming.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
