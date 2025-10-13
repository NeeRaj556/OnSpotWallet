import 'package:flutter/material.dart';
import '../../app/theme/neon_theme.dart';
import '../../core/apis/user_api.dart';
import '../../core/apis/transaction_api.dart';
import '../../models/user_model.dart';
import '../../models/transaction_model.dart';

class ProfileModal extends StatefulWidget {
  final VoidCallback? onSettingsTap;

  const ProfileModal({
    super.key,
    this.onSettingsTap,
  });

  @override
  State<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<ProfileModal> {
  final UserApi _userApi = UserApi();
  final TransactionApi _transactionApi = TransactionApi();

  bool _isLoading = true;
  double _availableBalance = 0.0;
  String _currency = '₹';
  Map<String, int> _monthlyOnlineTransactions = {};
  Map<String, int> _monthlyOfflineTransactions = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // For now, use mock data (ready for API integration)
      final userProfile = await _userApi.getUserProfileMock();
      final transactions = await _transactionApi.getTransactionsMock();

      // Calculate monthly transaction stats
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      int onlineCount = 0;
      int offlineCount = 0;

      for (var tx in transactions) {
        final txDate = tx.transactedAt ?? tx.sentAt ?? tx.receivedAt;
        if (txDate != null &&
            txDate.month == currentMonth &&
            txDate.year == currentYear) {
          if (tx.mode == TransactionMode.online) {
            onlineCount++;
          } else {
            offlineCount++;
          }
        }
      }

      setState(() {
        _availableBalance = userProfile.balance;
        _currency = userProfile.currency;
        _monthlyOnlineTransactions = {'current': onlineCount};
        _monthlyOfflineTransactions = {'current': offlineCount};
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to static data
      setState(() {
        _availableBalance = UserModel.mockUser.balance;
        _currency = UserModel.mockUser.currency;
        _monthlyOnlineTransactions = {'current': 2};
        _monthlyOfflineTransactions = {'current': 1};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Available Balance Card
                _buildBalanceCard(),

                const SizedBox(height: 20),

                // Transaction Charts
                _buildTransactionCharts(),

                const SizedBox(height: 20),

                // Settings Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onSettingsTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: NeonBlueTheme.neonGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: NeonBlueTheme.neonBlue.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.settings, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Open Settings',
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

                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Balance',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _currency,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _availableBalance.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCharts() {
    final onlineTotal =
        _monthlyOnlineTransactions.values.fold(0, (a, b) => a + b);
    final offlineTotal =
        _monthlyOfflineTransactions.values.fold(0, (a, b) => a + b);
    final total = onlineTotal + offlineTotal;

    final onlinePercentage = total > 0 ? (onlineTotal / total) * 100 : 0.0;
    final offlinePercentage = total > 0 ? (offlineTotal / total) * 100 : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Transaction Type Legend and Stats
          Row(
            children: [
              Expanded(
                child: _buildTransactionStat(
                  'Online',
                  onlineTotal,
                  NeonBlueTheme.neonBlue,
                  onlinePercentage,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTransactionStat(
                  'Offline',
                  offlineTotal,
                  NeonBlueTheme.electricBlue,
                  offlinePercentage,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                if (onlinePercentage > 0)
                  Expanded(
                    flex: onlineTotal,
                    child: Container(
                      decoration: BoxDecoration(
                        color: NeonBlueTheme.neonBlue,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                if (offlinePercentage > 0)
                  Expanded(
                    flex: offlineTotal,
                    child: Container(
                      decoration: BoxDecoration(
                        color: NeonBlueTheme.electricBlue,
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(offlineTotal > 0 ? 4 : 0),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionStat(
    String label,
    int count,
    Color color,
    double percentage,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
